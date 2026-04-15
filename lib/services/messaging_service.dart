import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 数据库库
import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具库

import 'chat_media_service.dart'; // 导入聊天媒体服务

/// Firestore 数据结构:
/// - `friend_links/{pairId}` — 好友关系: `uids`[2个排序], `status`: pending|active, `requested_by`, `names` map
/// - `directChats/{pairId}` — 私聊: `participants`, `updated_at`
/// - `directChats/{pairId}/messages/{id}` — 消息: `text` 或 `kind`+`image_url`、`sender_id`、`sender_name`、`timestamp`
class MessagingService { // 消息服务类
  MessagingService._(); // 私有构造函数,防止实例化

  static final FirebaseFirestore _db = FirebaseFirestore.instance; // Firestore 实例

  /// 2人的 UID 从始终生成相同的文档 ID
  static String pairId(String uidA, String uidB) { // 生成配对 ID
    final u = [uidA, uidB]..sort(); // 排序两个 UID
    return '${u[0]}__${u[1]}'; // 返回格式化的 ID
  }

  static String? get _myUid => FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID

  /// 邮箱在注册时已转为小写。为兼容旧数据可能有大写字母,进行两次搜索。
  static Future<DocumentSnapshot<Map<String, dynamic>>?> findUserByEmail( // 通过邮箱查找用户
    String email, // 邮箱地址
  ) async { // 异步方法
    final trimmed = email.trim(); // 去除前后空格
    if (trimmed.isEmpty) return null; // 如果为空,返回 null
    final lower = trimmed.toLowerCase(); // 转为小写
    QuerySnapshot<Map<String, dynamic>> snap = await _db // 查询 Firestore
        .collection('users') // users 集合
        .where('email', isEqualTo: lower) // 条件:邮箱等于小写值
        .limit(1) // 限制 1 条
        .get(); // 执行查询
    if (snap.docs.isEmpty && trimmed != lower) { // 如果没找到且原始值不等于小写值
      snap = await _db // 再次查询
          .collection('users') // users 集合
          .where('email', isEqualTo: trimmed) // 条件:邮箱等于原始值
          .limit(1) // 限制 1 条
          .get(); // 执行查询
    }
    if (snap.docs.isEmpty) return null; // 如果没找到,返回 null
    return snap.docs.first; // 返回第一个文档
  }

  /// 发送好友申请。成功时返回 null,失败时返回 [AppLanguageProvider.tr] 用密钥。
  /// 如果对方已经 pending,则直接变为 active(相互确认)。
  static Future<String?> sendFriendRequest({ // 发送好友申请
    required String targetUid, // 目标用户 ID
    required String targetName, // 目标用户名称
    required String myName, // 我的名称
  }) async { // 异步方法
    final me = _myUid; // 获取当前用户 ID
    if (me == null) return 'contacts_login_required'; // 如果未登录,返回错误
    if (me == targetUid) return 'add_friend_cannot_add_self'; // 不能添加自己

    final sorted = [me, targetUid]..sort(); // 排序两个 UID
    final uids = sorted; // 赋值给 uids
    final pid = '${uids[0]}__${uids[1]}'; // 生成配对 ID
    final ref = _db.collection('friend_links').doc(pid); // 引用 friend_links 文档
    try { // 尝试执行
      final doc = await ref.get(); // 获取文档

      if (doc.exists) { // 如果文档存在
        final d = doc.data()!; // 获取数据
        final status = d['status'] as String? ?? ''; // 获取状态
        if (status == 'active') return 'add_friend_already_friends'; // 已是好友
        final by = d['requested_by'] as String? ?? ''; // 获取申请人
        if (status == 'pending' && by == me) return 'add_friend_already_sent'; // 已发送申请
        if (status == 'pending' && by != me) { // 如果对方已申请
          await ref.update({ // 更新文档
            'status': 'active', // 状态改为 active
            'accepted_at': FieldValue.serverTimestamp(), // 接受时间
          });
          return null; // 成功
        }
      }

      await ref.set({ // 创建新文档
        'uids': uids, // 用户 ID 列表
        'status': 'pending', // 状态:待处理
        'requested_by': me, // 申请人
        'names': {me: myName, targetUid: targetName}, // 名称映射
        'created_at': FieldValue.serverTimestamp(), // 创建时间
      });
      return null; // 成功
    } on FirebaseException catch (e) { // 捕获 Firebase 异常
      debugPrint('sendFriendRequest: ${e.code} ${e.message}'); // 打印错误
      return 'add_friend_send_failed'; // 返回错误密钥
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
