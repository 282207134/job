import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 数据库库

/// 1对1聊天用的通话信令(`directChats/{pairId}/call_signals/{id}`)
class DirectCallSignalService { // 直拨呼叫信号服务类
  DirectCallSignalService._(); // 私有构造函数,防止实例化

  static CollectionReference<Map<String, dynamic>> _signals(String pairId) => // 获取信令集合引用
      FirebaseFirestore.instance // Firestore 实例
          .collection('directChats') // directChats 集合
          .doc(pairId) // 配对 ID 文档
          .collection('call_signals'); // call_signals 子集合

  /// 房间名按照 LiveKit 的限制以英数字为中心
  static String _sanitizeRoomSegment(String raw) { // 清理房间名称段
    var s = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_'); // 替换非字母数字字符为下划线
    if (s.length > 80) { // 如果长度超过 80
      s = s.substring(0, 80); // 截取前 80 个字符
    }
    return s; // 返回清理后的字符串
  }

  /// 发起呼叫:创建 pending 文档并返回其引用
  static Future<DocumentReference<Map<String, dynamic>>> createOutgoing({ // 创建呼出信令
    required String pairId, // 必需:配对 ID
    required String fromUid, // 必需:发起人 UID
    required String toUid, // 必需:接收人 UID
    required String fromName, // 必需:发起人名称
    required String callType, // 必需:通话类型(voice/video)
  }) async { // 异步方法
    final docRef = _signals(pairId).doc(); // 创建新文档引用
    final roomName =
        'dk_${_sanitizeRoomSegment(pairId)}_${docRef.id}'.toLowerCase(); // 生成房间名
    await docRef.set({ // 设置文档数据
      'from_uid': fromUid, // 发起人 UID
      'to_uid': toUid, // 接收人 UID
      'from_name': fromName, // 发起人名称
      'call_type': callType, // 通话类型
      'room_name': roomName, // 房间名称
      'status': 'pending', // 状态:待处理
      'created_at': FieldValue.serverTimestamp(), // 创建时间戳
      'updated_at': FieldValue.serverTimestamp(), // 更新时间戳
    });
    return docRef; // 返回文档引用
  }

  /// 发给自己的信令(客户端侧过滤 status==pending)
  static Stream<QuerySnapshot<Map<String, dynamic>>> incomingForUser( // 获取用户的来电信令流
    String pairId, // 配对 ID
    String myUid, // 我的 UID
  ) {
    return _signals(pairId).where('to_uid', isEqualTo: myUid).snapshots(); // 查询发给我且未处理的信令
  }

  /// `collectionGroup` 用(需要 COLLECTION_GROUP 索引)。应用推荐按每个好友订阅 [incomingForUser] 的方式。
  static Stream<QuerySnapshot<Map<String, dynamic>>> incomingForUserGlobal( // 全局获取用户来电信令流
    String myUid, // 我的 UID
  ) {
    return FirebaseFirestore.instance // Firestore 实例
        .collectionGroup('call_signals') // 跨集合组查询 call_signals
        .where('to_uid', isEqualTo: myUid) // 条件:接收人为我
        .snapshots(); // 返回实时流
  }

  /// 从 `directChats/{pairId}/call_signals/{id}` 获取 pairId
  static String pairIdFromSignalRef(DocumentReference ref) { // 从信令引用提取配对 ID
    final segs = ref.path.split('/'); // 分割路径
    if (segs.length >= 4 && // 如果路径段数>=4
        segs[0] == 'directChats' && // 第 1 段是 directChats
        segs[2] == 'call_signals') { // 第 3 段是 call_signals
      return segs[1]; // 返回第 2 段(pairId)
    }
    return ''; // 否则返回空字符串
  }

  static Future<void> markCancelled(DocumentReference<Map<String, dynamic>> r) => // 标记为已取消
      r.update({ // 更新文档
        'status': 'cancelled', // 状态:已取消
        'updated_at': FieldValue.serverTimestamp(), // 更新时间戳
      });

  static Future<void> markRejected(DocumentReference<Map<String, dynamic>> r) => // 标记为已拒绝
      r.update({ // 更新文档
        'status': 'rejected', // 状态:已拒绝
        'updated_at': FieldValue.serverTimestamp(), // 更新时间戳
      });

  static Future<void> markAccepted(DocumentReference<Map<String, dynamic>> r) => // 标记为已接受
      r.update({ // 更新文档
        'status': 'accepted', // 状态:已接受
        'updated_at': FieldValue.serverTimestamp(), // 更新时间戳
      });

  /// 通话结束(双方监控并关闭画面)
  static Future<void> markEnded(DocumentReference<Map<String, dynamic>> r) => // 标记为已结束
      r.update({ // 更新文档
        'status': 'ended', // 状态:已结束
        'updated_at': FieldValue.serverTimestamp(), // 更新时间戳
      });
}
