import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CalendarRoom {
  const CalendarRoom({
    required this.id,
    required this.name,
    required this.isPersonal,
    required this.ownerUid,
    required this.ownerName,
  });

  final String id;
  final String name;
  final bool isPersonal;
  final String ownerUid;
  final String ownerName;

  bool isOwner(String uid) => ownerUid == uid;

  String get displayName {
    if (isPersonal) return name;
    final owner = ownerName.trim();
    return owner.isEmpty ? name : '$owner · $name';
  }

  String get titleText {
    if (isPersonal) return name;
    final owner = ownerName.trim().isEmpty ? '未知用户' : ownerName.trim();
    return '共享日历$name:由$owner共享';
  }
}

class SharedCalendarService {
  SharedCalendarService._();

  static final _db = FirebaseFirestore.instance;
  static final selectedRoomNotifier = ValueNotifier<CalendarRoom>(
    const CalendarRoom(
      id: '',
      name: '我的日历',
      isPersonal: true,
      ownerUid: '',
      ownerName: '',
    ),
  );

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static String personalCalendarId(String uid) => 'personal_$uid';

  static Future<void> ensurePersonalSelected() async {
    final uid = _uid;
    if (uid == null) return;
    final current = selectedRoomNotifier.value;
    final personalId = personalCalendarId(uid);

    // 未选择时默认回到个人日历
    if (current.id.isEmpty) {
      selectedRoomNotifier.value = CalendarRoom(
        id: personalId,
        name: '我的日历',
        isPersonal: true,
        ownerUid: uid,
        ownerName: '',
      );
      return;
    }

    // 已是当前账号的个人日历，保持不变
    if (current.id == personalId) return;

    // 若是其他账号的个人日历，强制切回当前账号个人日历
    if (current.id.startsWith('personal_') && current.id != personalId) {
      selectedRoomNotifier.value = CalendarRoom(
        id: personalId,
        name: '我的日历',
        isPersonal: true,
        ownerUid: uid,
        ownerName: '',
      );
      return;
    }

    // 若是共享房间，需确认当前账号确实已在成员中；否则切回个人日历
    try {
      final roomDoc = await _db.collection('shared_calendars').doc(current.id).get();
      final members =
          List<String>.from(roomDoc.data()?['member_uids'] as List? ?? const []);
      if (!roomDoc.exists || !members.contains(uid)) {
        selectedRoomNotifier.value = CalendarRoom(
          id: personalId,
          name: '我的日历',
          isPersonal: true,
          ownerUid: uid,
          ownerName: '',
        );
      }
    } catch (_) {
      selectedRoomNotifier.value = CalendarRoom(
        id: personalId,
        name: '我的日历',
        isPersonal: true,
        ownerUid: uid,
        ownerName: '',
      );
    }
  }

  static void selectRoom(CalendarRoom room) {
    selectedRoomNotifier.value = room;
  }

  static Future<void> selectRoomSafely(CalendarRoom room) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    if (room.isPersonal) {
      selectRoom(room);
      return;
    }
    final doc = await _db.collection('shared_calendars').doc(room.id).get();
    final members = List<String>.from(doc.data()?['member_uids'] as List? ?? const []);
    if (!doc.exists || !members.contains(uid)) {
      throw Exception('改共享日历不存在');
    }
    selectRoom(room);
  }

  static Stream<List<CalendarRoom>> myRoomsStream() async* {
    final uid = _uid;
    if (uid == null) {
      yield const [];
      return;
    }
    await for (final snap in _db
        .collection('shared_calendars')
        .where('member_uids', arrayContains: uid)
        .snapshots()) {
      final rooms = <CalendarRoom>[
        CalendarRoom(
          id: personalCalendarId(uid),
          name: '我的日历',
          isPersonal: true,
          ownerUid: uid,
          ownerName: '',
        ),
      ];
      for (final d in snap.docs) {
        final m = d.data();
        final roomName = '${m['name'] ?? '共享日历'}';
        final ownerName = '${m['owner_name'] ?? ''}';
        rooms.add(CalendarRoom(
          id: d.id,
          name: roomName,
          isPersonal: false,
          ownerUid: '${m['owner_uid'] ?? ''}',
          ownerName: ownerName,
        ));
      }
      yield rooms;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> pendingInvitesStream() {
    final uid = _uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _db
        .collection('calendar_invites')
        .where('to_uid', isEqualTo: uid)
        .snapshots();
  }

  static Future<void> createRoom({
    required String name,
    required String ownerName,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    final title = name.trim();
    if (title.isEmpty) throw Exception('请输入共享日历名称');
    await _db.collection('shared_calendars').add({
      'name': title,
      'owner_uid': uid,
      'owner_name': ownerName,
      'member_uids': [uid],
      'member_names': {uid: ownerName},
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> inviteByEmail({
    required String roomId,
    required String roomName,
    required String fromName,
    required String email,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    final raw = email.trim();
    if (raw.isEmpty) throw Exception('请输入邮箱');
    final q = raw.toLowerCase();
    QuerySnapshot<Map<String, dynamic>> userSnap = await _db
        .collection('users')
        .where('email', isEqualTo: q)
        .limit(1)
        .get();
    // 兼容旧数据：历史账号邮箱可能未小写化
    if (userSnap.docs.isEmpty && raw != q) {
      userSnap = await _db
          .collection('users')
          .where('email', isEqualTo: raw)
          .limit(1)
          .get();
    }
    if (userSnap.docs.isEmpty) throw Exception('未找到该用户');
    final target = userSnap.docs.first;
    final toUid = target.id;
    final toName = '${target.data()['name'] ?? '用户'}';
    if (toUid == uid) throw Exception('不能邀请自己');

    try {
      final roomDoc = await _db.collection('shared_calendars').doc(roomId).get();
      if (!roomDoc.exists) throw Exception('改共享日历不存在');
      final members =
          List<String>.from(roomDoc.data()?['member_uids'] as List? ?? const []);
      if (members.contains(toUid)) throw Exception('该用户已在共享日历中');

      final inviteId = '${roomId}_$toUid';
      final existed = await _db.collection('calendar_invites').doc(inviteId).get();
      if (existed.exists && existed.data()?['status'] == 'pending') {
        throw Exception('邀请已发送');
      }

      await _db.collection('calendar_invites').doc(inviteId).set({
        'room_id': roomId,
        'room_name': roomName,
        'from_uid': uid,
        'from_name': fromName,
        'to_uid': toUid,
        'to_name': toName,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('权限不足：请先在 Firebase 发布最新 firestore.rules');
      }
      throw Exception(e.message ?? e.code);
    }
  }

  static Future<void> inviteByUid({
    required String roomId,
    required String roomName,
    required String fromName,
    required String toUid,
    required String toName,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    final targetUid = toUid.trim();
    if (targetUid.isEmpty) throw Exception('未找到该用户');
    if (targetUid == uid) throw Exception('不能邀请自己');

    try {
      final roomDoc = await _db.collection('shared_calendars').doc(roomId).get();
      if (!roomDoc.exists) throw Exception('改共享日历不存在');
      final ownerUid = '${roomDoc.data()?['owner_uid'] ?? ''}';
      if (ownerUid != uid) throw Exception('只有创建者可以邀请成员');
      final members =
          List<String>.from(roomDoc.data()?['member_uids'] as List? ?? const []);
      if (members.contains(targetUid)) throw Exception('该用户已在共享日历中');

      final inviteId = '${roomId}_$targetUid';
      final existed = await _db.collection('calendar_invites').doc(inviteId).get();
      if (existed.exists && existed.data()?['status'] == 'pending') {
        throw Exception('邀请已发送');
      }

      await _db.collection('calendar_invites').doc(inviteId).set({
        'room_id': roomId,
        'room_name': roomName,
        'from_uid': uid,
        'from_name': fromName,
        'to_uid': targetUid,
        'to_name': toName,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('权限不足：请先在 Firebase 发布最新 firestore.rules');
      }
      throw Exception(e.message ?? e.code);
    }
  }

  static Future<void> respondInvite({
    required String inviteId,
    required bool accept,
    required String myName,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    await _db.runTransaction((tx) async {
      final inviteRef = _db.collection('calendar_invites').doc(inviteId);
      final inviteDoc = await tx.get(inviteRef);
      if (!inviteDoc.exists) throw Exception('邀请不存在');
      final invite = inviteDoc.data()!;
      if (invite['to_uid'] != uid) throw Exception('无权限');
      if (invite['status'] != 'pending') return;

      if (accept) {
        final roomRef = _db.collection('shared_calendars').doc('${invite['room_id']}');
        // 直接尝试加入，规则会校验 pending 邀请
        tx.update(roomRef, {
          'member_uids': FieldValue.arrayUnion([uid]),
          'member_names.$uid': myName,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
      tx.update(inviteRef, {
        'status': accept ? 'accepted' : 'rejected',
        'resolved_at': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> deleteRoomAsOwner({
    required String roomId,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    final roomRef = _db.collection('shared_calendars').doc(roomId);
    final roomDoc = await roomRef.get();
    if (!roomDoc.exists) throw Exception('改共享日历不存在');
    final ownerUid = '${roomDoc.data()?['owner_uid'] ?? ''}';
    if (ownerUid != uid) throw Exception('只有创建者可以删除');

    final invites = await _db
        .collection('calendar_invites')
        .where('room_id', isEqualTo: roomId)
        .get();
    for (final d in invites.docs) {
      await d.reference.delete();
    }

    final events = await _db
        .collection('events')
        .where('calendar_id', isEqualTo: roomId)
        .get();
    for (final d in events.docs) {
      await d.reference.delete();
    }

    await roomRef.delete();
    await ensurePersonalSelected();
  }

  static Future<void> leaveRoom({
    required String roomId,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('未登录');
    final roomRef = _db.collection('shared_calendars').doc(roomId);
    await _db.runTransaction((tx) async {
      final roomDoc = await tx.get(roomRef);
      if (!roomDoc.exists) return;
      final ownerUid = '${roomDoc.data()?['owner_uid'] ?? ''}';
      if (ownerUid == uid) {
        throw Exception('创建者不能退出，请使用删除功能');
      }
      final members =
          List<String>.from(roomDoc.data()?['member_uids'] as List? ?? const []);
      if (!members.contains(uid)) return;
      tx.update(roomRef, {
        'member_uids': FieldValue.arrayRemove([uid]),
        'member_names.$uid': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
    await ensurePersonalSelected();
  }
}
