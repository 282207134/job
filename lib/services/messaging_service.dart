import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'chat_media_service.dart';

/// Firestore:
/// - `friend_links/{pairId}` — `uids`[2 sorted], `status`: pending|active, `requested_by`, `names` map
/// - `directChats/{pairId}` — `participants`, `updated_at`
/// - `directChats/{pairId}/messages/{id}` — `text` または `kind`+`image_url`、`sender_id`、`sender_name`、`timestamp`
class MessagingService {
  MessagingService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 2人の UID から常に同じドキュメント ID
  static String pairId(String uidA, String uidB) {
    final u = [uidA, uidB]..sort();
    return '${u[0]}__${u[1]}';
  }

  static String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  /// メールは登録時に小文字化される想定。古いデータで大文字混在の場合に備え二段で検索。
  static Future<DocumentSnapshot<Map<String, dynamic>>?> findUserByEmail(
    String email,
  ) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return null;
    final lower = trimmed.toLowerCase();
    QuerySnapshot<Map<String, dynamic>> snap = await _db
        .collection('users')
        .where('email', isEqualTo: lower)
        .limit(1)
        .get();
    if (snap.docs.isEmpty && trimmed != lower) {
      snap = await _db
          .collection('users')
          .where('email', isEqualTo: trimmed)
          .limit(1)
          .get();
    }
    if (snap.docs.isEmpty) return null;
    return snap.docs.first;
  }

  /// 友だち申請。戻り値は成功時 null、失敗時は [AppLanguageProvider.tr] 用キー。
  /// 相手から既に pending ならその場で active にする（相互承認）。
  static Future<String?> sendFriendRequest({
    required String targetUid,
    required String targetName,
    required String myName,
  }) async {
    final me = _myUid;
    if (me == null) return 'contacts_login_required';
    if (me == targetUid) return 'add_friend_cannot_add_self';

    final sorted = [me, targetUid]..sort();
    final uids = sorted;
    final pid = '${uids[0]}__${uids[1]}';
    final ref = _db.collection('friend_links').doc(pid);
    try {
      final doc = await ref.get();

      if (doc.exists) {
        final d = doc.data()!;
        final status = d['status'] as String? ?? '';
        if (status == 'active') return 'add_friend_already_friends';
        final by = d['requested_by'] as String? ?? '';
        if (status == 'pending' && by == me) return 'add_friend_already_sent';
        if (status == 'pending' && by != me) {
          await ref.update({
            'status': 'active',
            'accepted_at': FieldValue.serverTimestamp(),
          });
          return null;
        }
      }

      await ref.set({
        'uids': uids,
        'status': 'pending',
        'requested_by': me,
        'names': {me: myName, targetUid: targetName},
        'created_at': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      debugPrint('sendFriendRequest: ${e.code} ${e.message}');
      return 'add_friend_send_failed';
    }
  }

  static Future<String?> acceptRequest(String pairDocId) async {
    final me = _myUid;
    if (me == null) return 'ログインが必要です';
    final ref = _db.collection('friend_links').doc(pairDocId);
    final doc = await ref.get();
    if (!doc.exists) return 'データが見つかりません';
    final d = doc.data()!;
    final uids = List<String>.from(d['uids'] as List? ?? []);
    if (!uids.contains(me)) return '権限がありません';
    final by = d['requested_by'] as String? ?? '';
    if (by == me) return '自分の申請は承認できません';
    await ref.update({
      'status': 'active',
      'accepted_at': FieldValue.serverTimestamp(),
    });
    return null;
  }

  static Future<void> declineRequest(String pairDocId) async {
    final me = _myUid;
    if (me == null) return;
    final ref = _db.collection('friend_links').doc(pairDocId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final d = doc.data()!;
    final uids = List<String>.from(d['uids'] as List? ?? []);
    if (!uids.contains(me)) return;
    await ref.delete();
  }

  static Future<void> cancelOutgoing(String pairDocId) async {
    final me = _myUid;
    if (me == null) return;
    final ref = _db.collection('friend_links').doc(pairDocId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final d = doc.data()!;
    if (d['requested_by'] != me) return;
    if (d['status'] != 'pending') return;
    await ref.delete();
  }

  static Future<void> ensureDirectChatDoc(String pairDocId) async {
    final parts = pairDocId.split('__');
    if (parts.length != 2) return;
    await _db.collection('directChats').doc(pairDocId).set(
      {
        'participants': parts,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// [text] と [imageUrl] のどちらか一方以上が必要。画像のみのときは [text] を省略可。
  static Future<void> sendDirectMessage({
    required String pairDocId,
    required String senderName,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    final t = text?.trim() ?? '';
    final img = imageUrl?.trim() ?? '';
    if (t.isEmpty && img.isEmpty) return;
    final parts = pairDocId.split('__');
    if (parts.length != 2) return;

    final chatRef = _db.collection('directChats').doc(pairDocId);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _db.batch();
    batch.set(
      chatRef,
      {
        'participants': parts,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    final payload = <String, dynamic>{
      'sender_name': senderName,
      'sender_id': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (img.isNotEmpty) {
      payload['kind'] = 'image';
      payload['image_url'] = img;
      if (t.isNotEmpty) payload['text'] = t;
    } else {
      payload['text'] = t;
    }
    batch.set(msgRef, payload);
    await batch.commit();
  }

  /// `uids` に自分が含まれる `friend_links` のみ（単一 where のみ＝複合インデックス不要）。
  /// 呼び出し側で `status` や `requested_by` を絞る。
  static Stream<QuerySnapshot<Map<String, dynamic>>> friendLinksForUser(
    String myUid,
  ) {
    return _db
        .collection('friend_links')
        .where('uids', arrayContains: myUid)
        .snapshots(includeMetadataChanges: true);
  }

  static String peerUid(Map<String, dynamic> data, String myUid) {
    final uids = List<String>.from(data['uids'] as List? ?? []);
    for (final u in uids) {
      if (u != myUid) return u;
    }
    return '';
  }

  static String peerName(Map<String, dynamic> data, String myUid) {
    final peer = peerUid(data, myUid);
    final names = data['names'];
    if (names is Map && peer.isNotEmpty && names[peer] != null) {
      return '${names[peer]}';
    }
    return peer;
  }

  /// 一覧用：最終メッセージのプレビュー文言
  static String previewFromMessage(Map<String, dynamic> m) {
    final kind = m['kind'] as String?;
    if (kind == 'image') {
      final cap = '${m['text'] ?? ''}'.trim();
      if (cap.isNotEmpty) {
        return cap.length > 40 ? '${cap.substring(0, 40)}…' : '画像: $cap';
      }
      return '画像';
    }
    final t = '${m['text'] ?? ''}'.trim();
    if (t.isEmpty) return 'メッセージ';
    return t.length > 50 ? '${t.substring(0, 50)}…' : t;
  }

  /// `directChats/{pairDocId}/messages` の最新 1 件（一覧のプレビュー用）
  static Stream<QuerySnapshot<Map<String, dynamic>>> directChatLastMessageStream(
    String pairDocId,
  ) {
    return _db
        .collection('directChats')
        .doc(pairDocId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> _deleteSubcollectionInBatches(
    CollectionReference<Map<String, dynamic>> col,
  ) async {
    while (true) {
      final snap = await col.limit(500).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  /// アクティブな友だちを解除し、`directChats/{pairDocId}` のメッセージ／通話シグナルとチャット文書を削除。
  /// Storage はルールにより自分の `directChats/{pairId}/{自分UID}/...` のみベストエフォート削除。
  /// 失敗時は `AppLanguageProvider.tr` 用キー文字列を返す。
  static Future<String?> removeFriendAndClearChat(String pairDocId) async {
    final me = _myUid;
    if (me == null) return 'contacts_login_required';

    final linkRef = _db.collection('friend_links').doc(pairDocId);
    final linkSnap = await linkRef.get();
    if (!linkSnap.exists) return 'contacts_remove_friend_not_found';
    final d = linkSnap.data()!;
    final uids = List<String>.from(d['uids'] as List? ?? []);
    if (!uids.contains(me)) return 'contacts_remove_friend_forbidden';
    if ((d['status'] as String? ?? '') != 'active') {
      return 'contacts_remove_friend_forbidden';
    }

    try {
      await ChatMediaService.tryDeleteMyChatFilesForPair(pairDocId);
      final chatRef = _db.collection('directChats').doc(pairDocId);
      await _deleteSubcollectionInBatches(chatRef.collection('messages'));
      await _deleteSubcollectionInBatches(chatRef.collection('call_signals'));
      await chatRef.delete();
      await linkRef.delete();
      return null;
    } catch (e, st) {
      debugPrint('removeFriendAndClearChat: $e\n$st');
      return 'contacts_remove_friend_failed';
    }
  }
}
