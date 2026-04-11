import 'package:cloud_firestore/cloud_firestore.dart';

/// 1対1チャット用の通話シグナル（`directChats/{pairId}/call_signals/{id}`）
class DirectCallSignalService {
  DirectCallSignalService._();

  static CollectionReference<Map<String, dynamic>> _signals(String pairId) =>
      FirebaseFirestore.instance
          .collection('directChats')
          .doc(pairId)
          .collection('call_signals');

  /// ルーム名は LiveKit の制約に合わせて英数字中心にする
  static String _sanitizeRoomSegment(String raw) {
    var s = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (s.length > 80) {
      s = s.substring(0, 80);
    }
    return s;
  }

  /// 発信: pending ドキュメントを作成し、その参照を返す
  static Future<DocumentReference<Map<String, dynamic>>> createOutgoing({
    required String pairId,
    required String fromUid,
    required String toUid,
    required String fromName,
    required String callType,
  }) async {
    final docRef = _signals(pairId).doc();
    final roomName =
        'dk_${_sanitizeRoomSegment(pairId)}_${docRef.id}'.toLowerCase();
    await docRef.set({
      'from_uid': fromUid,
      'to_uid': toUid,
      'from_name': fromName,
      'call_type': callType,
      'room_name': roomName,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef;
  }

  /// 自分宛のシグナル（クライアント側で status==pending を抽出）
  static Stream<QuerySnapshot<Map<String, dynamic>>> incomingForUser(
    String pairId,
    String myUid,
  ) {
    return _signals(pairId).where('to_uid', isEqualTo: myUid).snapshots();
  }

  /// `collectionGroup` 用（要 COLLECTION_GROUP インデックス）。アプリは [incomingForUser] を友だちごとに購読する方式を推奨。
  static Stream<QuerySnapshot<Map<String, dynamic>>> incomingForUserGlobal(
    String myUid,
  ) {
    return FirebaseFirestore.instance
        .collectionGroup('call_signals')
        .where('to_uid', isEqualTo: myUid)
        .snapshots();
  }

  /// `directChats/{pairId}/call_signals/{id}` から pairId を取得
  static String pairIdFromSignalRef(DocumentReference ref) {
    final segs = ref.path.split('/');
    if (segs.length >= 4 &&
        segs[0] == 'directChats' &&
        segs[2] == 'call_signals') {
      return segs[1];
    }
    return '';
  }

  static Future<void> markCancelled(DocumentReference<Map<String, dynamic>> r) =>
      r.update({
        'status': 'cancelled',
        'updated_at': FieldValue.serverTimestamp(),
      });

  static Future<void> markRejected(DocumentReference<Map<String, dynamic>> r) =>
      r.update({
        'status': 'rejected',
        'updated_at': FieldValue.serverTimestamp(),
      });

  static Future<void> markAccepted(DocumentReference<Map<String, dynamic>> r) =>
      r.update({
        'status': 'accepted',
        'updated_at': FieldValue.serverTimestamp(),
      });

  /// 通話終了（双方が監視して画面を閉じる）
  static Future<void> markEnded(DocumentReference<Map<String, dynamic>> r) =>
      r.update({
        'status': 'ended',
        'updated_at': FieldValue.serverTimestamp(),
      });
}
