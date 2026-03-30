import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../services/shared_calendar_service.dart';

class SharedCalendarSheet extends StatelessWidget {
  const SharedCalendarSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SharedCalendarSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<UserProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '共享日历',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: '创建共享日历',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showCreateDialog(context, prov.userName),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('我的日历房间'),
            const SizedBox(height: 8),
            StreamBuilder<List<CalendarRoom>>(
              stream: SharedCalendarService.myRoomsStream(),
              builder: (context, snap) {
                final rooms = snap.data ?? const <CalendarRoom>[];
                if (rooms.isEmpty) {
                  return const Text('暂无可用日历');
                }
                return ValueListenableBuilder<CalendarRoom>(
                  valueListenable: SharedCalendarService.selectedRoomNotifier,
                  builder: (context, current, _) {
                    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    return Column(
                      children: rooms.map((r) {
                        final selected = r.id == current.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(r.isPersonal
                              ? Icons.calendar_month_outlined
                              : Icons.group_add_outlined),
                          title: Text(r.displayName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.check_circle, color: Colors.green),
                                ),
                              if (!r.isPersonal)
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    try {
                                      if (v == 'invite') {
                                        await _showInviteDialog(
                                          context,
                                          roomId: r.id,
                                          roomName: r.name,
                                          myName: prov.userName,
                                        );
                                      } else if (v == 'delete') {
                                        await SharedCalendarService.deleteRoomAsOwner(
                                          roomId: r.id,
                                        );
                                      } else if (v == 'leave') {
                                        await SharedCalendarService.leaveRoom(roomId: r.id);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('$e')),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (ctx) {
                                    final isOwner = r.ownerUid == myUid;
                                    if (isOwner) {
                                      return const [
                                        PopupMenuItem(value: 'invite', child: Text('邀请成员')),
                                        PopupMenuItem(value: 'delete', child: Text('删除共享日历')),
                                      ];
                                    }
                                    return const [
                                      PopupMenuItem(value: 'leave', child: Text('退出共享日历')),
                                    ];
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            SharedCalendarService.selectRoom(r);
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text('收到的邀请'),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: SharedCalendarService.pendingInvitesStream(),
              builder: (context, snap) {
                final docs = (snap.data?.docs ?? [])
                    .where((d) => d.data()['status'] == 'pending')
                    .toList();
                if (docs.isEmpty) {
                  return const Text('暂无邀请');
                }
                return Column(
                  children: docs.map((d) {
                    final m = d.data();
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${m['from_name'] ?? ''} 邀请你加入：${m['room_name'] ?? ''}',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await SharedCalendarService.respondInvite(
                                  inviteId: d.id,
                                  accept: false,
                                  myName: prov.userName,
                                );
                              },
                              child: const Text('拒绝'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                await SharedCalendarService.respondInvite(
                                  inviteId: d.id,
                                  accept: true,
                                  myName: prov.userName,
                                );
                              },
                              child: const Text('加入'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, String myName) async {
    final ctrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('创建共享日历'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: '请输入房间名称'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await SharedCalendarService.createRoom(
                      name: ctrl.text,
                      ownerName: myName,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                child: const Text('创建'),
              ),
            ],
          );
        },
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _showInviteDialog(
    BuildContext context, {
    required String roomId,
    required String roomName,
    required String myName,
  }) async {
    final ctrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('邀请成员'),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: '输入对方注册邮箱'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await SharedCalendarService.inviteByEmail(
                      roomId: roomId,
                      roomName: roomName,
                      fromName: myName,
                      email: ctrl.text,
                    );
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('邀请已发送')),
                      );
                      Navigator.of(ctx).pop();
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                child: const Text('发送'),
              ),
            ],
          );
        },
      );
    } finally {
      ctrl.dispose();
    }
  }
}
