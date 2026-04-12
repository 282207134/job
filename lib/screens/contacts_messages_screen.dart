import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_language_provider.dart';
import '../providers/userProvider.dart';
import '../services/messaging_service.dart';
import 'direct_chat_screen.dart';

/// 友だち一覧・申請の受信/送信・メッセージへ遷移
class ContactsMessagesScreen extends StatelessWidget {
  const ContactsMessagesScreen({super.key});

  static Future<void> showAddFriendDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const _AddFriendBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    String t(String key) => lang.tr(key);
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null) {
      return Center(child: Text(t('contacts_login_required')));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: MessagingService.friendLinksForUser(authUid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '${t('contacts_load_error')}: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting &&
            (snap.data?.docs ?? []).isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snap.data?.docs ?? [];
        final pendingDocs =
            allDocs.where((d) => d.data()['status'] == 'pending').toList();
        final incoming = pendingDocs
            .where((d) => d.data()['requested_by'] != authUid)
            .toList();
        final outgoing = pendingDocs
            .where((d) => d.data()['requested_by'] == authUid)
            .toList();
        final activeDocs =
            allDocs.where((d) => d.data()['status'] == 'active').toList();

        final hasRequests = incoming.isNotEmpty || outgoing.isNotEmpty;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  t('contacts_section_requests_friends'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1),
              ),
              if (hasRequests) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _ContactsPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (incoming.isNotEmpty) ...[
                          _SectionTitle(t('contacts_incoming_requests')),
                          for (var i = 0; i < incoming.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Colors.grey.shade200,
                              ),
                            _IncomingTile(
                              docId: incoming[i].id,
                              data: incoming[i].data(),
                            ),
                          ],
                        ],
                        if (outgoing.isNotEmpty) ...[
                          if (incoming.isNotEmpty)
                            Divider(height: 1, color: Colors.grey.shade200),
                          _SectionTitle(t('contacts_outgoing_pending')),
                          ..._outgoingTilesWithDividers(outgoing, authUid),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  t('contacts_friends'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (activeDocs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: _ContactsPanel(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Text(
                        t('contacts_empty_friends_hint'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _ContactsPanel(
                    child: Column(
                      children: [
                        for (var i = 0; i < activeDocs.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                              color: Colors.grey.shade200,
                            ),
                          _FriendChatListTile(
                            pairId: activeDocs[i].id,
                            peerName: MessagingService.peerName(
                              activeDocs[i].data(),
                              authUid,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

/// 友だち 1 件：`directChats/{pairId}/messages` の最新 1 件を副題に表示
class _FriendChatListTile extends StatelessWidget {
  const _FriendChatListTile({
    required this.pairId,
    required this.peerName,
  });

  final String pairId;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: MessagingService.directChatLastMessageStream(pairId),
      builder: (context, msgSnap) {
        var subtitle = t('no_messages');
        if (msgSnap.hasError) {
          subtitle = t('contacts_preview_unavailable');
        } else if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
          subtitle = _previewFromMessage(msgSnap.data!.docs.first.data(), t);
        }
        return ListTile(
          leading: CircleAvatar(
            child: Text(peerName.isNotEmpty ? peerName[0] : '?'),
          ),
          title: Text(peerName),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          trailing: const Icon(Icons.chat_bubble_outline_rounded),
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => DirectChatScreen(
                  pairId: pairId,
                  peerName: peerName,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _previewFromMessage(
    Map<String, dynamic> m,
    String Function(String) t,
  ) {
    final kind = m['kind'] as String?;
    if (kind == 'image') {
      final cap = '${m['text'] ?? ''}'.trim();
      if (cap.isNotEmpty) {
        return cap.length > 40
            ? '${cap.substring(0, 40)}…'
            : '${t('image')}: $cap';
      }
      return t('image');
    }
    final text = '${m['text'] ?? ''}'.trim();
    if (text.isEmpty) return t('message');
    return text.length > 50 ? '${text.substring(0, 50)}…' : text;
  }
}

class _AddFriendBottomSheet extends StatefulWidget {
  const _AddFriendBottomSheet();

  @override
  State<_AddFriendBottomSheet> createState() => _AddFriendBottomSheetState();
}

class _AddFriendBottomSheetState extends State<_AddFriendBottomSheet> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    if (_busy) return;
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('add_friend_email_required'))),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final userSnap = await MessagingService.findUserByEmail(email);
      if (userSnap == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('user_not_found'))),
          );
        }
        return;
      }
      final data = userSnap.data()!;
      final targetUid = userSnap.id;
      final targetName = '${data['name'] ?? t('user_default')}';
      if (!mounted) return;
      final prov = Provider.of<UserProvider>(context, listen: false);
      final err = await MessagingService.sendFriendRequest(
        targetUid: targetUid,
        targetName: targetName,
        myName: prov.userName,
      );
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('request_sent'))),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('add_friend'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t('enter_registered_email'),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: t('email_address'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t('send_request')),
          ),
        ],
      ),
    );
  }
}

class _ContactsPanel extends StatelessWidget {
  const _ContactsPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

Iterable<Widget> _outgoingTilesWithDividers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  String myUid,
) sync* {
  for (var i = 0; i < docs.length; i++) {
    if (i > 0) {
      yield Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.shade200,
      );
    }
    yield _OutgoingTile(
      docId: docs[i].id,
      data: docs[i].data(),
      myUid: myUid,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _IncomingTile extends StatelessWidget {
  const _IncomingTile({
    required this.docId,
    required this.data,
  });

  final String docId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    final from = data['requested_by'] as String? ?? '';
    final names = data['names'];
    var fromName = t('user_default');
    if (names is Map && names[from] != null) fromName = '${names[from]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fromName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final err = await MessagingService.acceptRequest(docId);
                    if (context.mounted) {
                      if (err != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('request_approved'))),
                        );
                      }
                    }
                  },
                  child: Text(t('approve')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () => MessagingService.declineRequest(docId),
                  child: Text(t('decline')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutgoingTile extends StatelessWidget {
  const _OutgoingTile({
    required this.docId,
    required this.data,
    required this.myUid,
  });

  final String docId;
  final Map<String, dynamic> data;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr;
    final name = MessagingService.peerName(data, myUid);
    return ListTile(
      leading: const Icon(Icons.hourglass_empty_rounded),
      title: Text(name.isEmpty ? t('pending_approval') : name),
      subtitle: Text(t('waiting_for_approval')),
      trailing: TextButton(
        onPressed: () => MessagingService.cancelOutgoing(docId),
        child: Text(t('cancel_request')),
      ),
    );
  }
}
