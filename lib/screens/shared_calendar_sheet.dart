import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_language_provider.dart';
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
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
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
                Expanded(
                  child: Text(
                    t('shared_calendar'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: t('create_shared_calendar'),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showCreateDialog(context, prov.userName),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t('my_calendar_rooms')),
            const SizedBox(height: 8),
            StreamBuilder<List<CalendarRoom>>(
              stream: SharedCalendarService.myRoomsStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text(
                      '${t('read_calendar_rooms_failed')}: ${snap.error}');
                }
                final rooms = snap.data ?? const <CalendarRoom>[];
                if (rooms.isEmpty) {
                  return Text(t('no_shared_calendar_created'));
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
                          title: Text(
                            r.isPersonal
                                ? t('my_calendar')
                                : (r.ownerName.trim().isEmpty
                                    ? r.name
                                    : '${r.ownerName.trim()} · ${r.name}'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.check_circle,
                                      color: Colors.green),
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
                                        await SharedCalendarService
                                            .deleteRoomAsOwner(
                                          roomId: r.id,
                                        );
                                      } else if (v == 'leave') {
                                        await SharedCalendarService.leaveRoom(
                                            roomId: r.id);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('$e')),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (ctx) {
                                    final isOwner = r.ownerUid == myUid;
                                    if (isOwner) {
                                      return [
                                        PopupMenuItem(
                                          value: 'invite',
                                          child: Text(t('invite_member')),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child:
                                              Text(t('delete_shared_calendar')),
                                        ),
                                      ];
                                    }
                                    return [
                                      PopupMenuItem(
                                        value: 'leave',
                                        child: Text(t('leave_shared_calendar')),
                                      ),
                                    ];
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            SharedCalendarService.selectRoomSafely(r).then((_) {
                              if (context.mounted) Navigator.of(context).pop();
                            }).catchError((e) {
                              if (!context.mounted) return;
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(t('shared_calendar_notice')),
                                  content: Text(
                                      '$e'.replaceFirst('Exception: ', '')),
                                  actions: [
                                    FilledButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text(t('got_it')),
                                    ),
                                  ],
                                ),
                              );
                            });
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
            Text(t('incoming_invites')),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: SharedCalendarService.pendingInvitesStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text('${t('read_invites_failed')}: ${snap.error}');
                }
                final docs = (snap.data?.docs ?? [])
                    .where((d) => d.data()['status'] == 'pending')
                    .toList();
                if (docs.isEmpty) {
                  return Text(t('no_invites'));
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
                                '${m['from_name'] ?? ''} ${t('invite_message')}: ${m['room_name'] ?? ''}',
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
                              child: Text(t('reject')),
                            ),
                            FilledButton(
                              onPressed: () async {
                                await SharedCalendarService.respondInvite(
                                  inviteId: d.id,
                                  accept: true,
                                  myName: prov.userName,
                                );
                              },
                              child: Text(t('join')),
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
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CreateSharedCalendarDialog(ownerName: myName),
    );
  }

  Future<void> _showInviteDialog(
    BuildContext context, {
    required String roomId,
    required String roomName,
    required String myName,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _InviteMemberDialog(
        roomId: roomId,
        roomName: roomName,
        fromName: myName,
      ),
    );
  }
}

/// 在路由真正卸载后再 dispose [TextEditingController]；不得在 `showDialog` 的 `finally` 里立刻 dispose，
/// 否则关闭动画期间 TextField 仍会访问已释放的 controller，并可能连带触发 `_dependents.isEmpty`。
class _CreateSharedCalendarDialog extends StatefulWidget {
  const _CreateSharedCalendarDialog({required this.ownerName});

  final String ownerName;

  @override
  State<_CreateSharedCalendarDialog> createState() =>
      _CreateSharedCalendarDialogState();
}

class _CreateSharedCalendarDialogState extends State<_CreateSharedCalendarDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    return AlertDialog(
      title: Text(t('create_shared_calendar')),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: t('enter_room_name')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await SharedCalendarService.createRoom(
                name: _controller.text,
                ownerName: widget.ownerName,
              );
              if (context.mounted) Navigator.of(context).pop();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            }
          },
          child: Text(t('create_shared_calendar')),
        ),
      ],
    );
  }
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog({
    required this.roomId,
    required this.roomName,
    required this.fromName,
  });

  final String roomId;
  final String roomName;
  final String fromName;

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    return AlertDialog(
      title: Text(t('invite_member')),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(hintText: t('enter_registered_email')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await SharedCalendarService.inviteByEmail(
                roomId: widget.roomId,
                roomName: widget.roomName,
                fromName: widget.fromName,
                email: _controller.text,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('invite_sent'))),
                );
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            }
          },
          child: Text(t('send')),
        ),
      ],
    );
  }
}
