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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  return Text('${t('read_calendar_rooms_failed')}: ${snap.error}');
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
                                      return [
                                        PopupMenuItem(
                                          value: 'invite',
                                          child: Text(t('invite_member')),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(t('delete_shared_calendar')),
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
                            SharedCalendarService.selectRoomSafely(r)
                                .then((_) {
                              if (context.mounted) Navigator.of(context).pop();
                            }).catchError((e) {
                              if (!context.mounted) return;
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(t('shared_calendar_notice')),
                                  content: Text('$e'.replaceFirst('Exception: ', '')),
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
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    final ctrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(t('create_shared_calendar')),
            content: TextField(
              controller: ctrl,
              decoration: InputDecoration(hintText: t('enter_room_name')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(t('cancel')),
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
                child: Text(t('create_shared_calendar')),
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
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    final ctrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(t('invite_member')),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: t('enter_registered_email')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(t('cancel')),
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
                        SnackBar(content: Text(t('invite_sent'))),
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
                child: Text(t('send')),
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
