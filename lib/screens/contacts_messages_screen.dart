import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null) {
      return const Center(child: Text('ログインが必要です'));
    }

    return ColoredBox(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: MessagingService.friendLinksForUser(authUid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '読み込みエラー: ${snap.error}',
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
          final pendingDocs = allDocs
              .where((d) => d.data()['status'] == 'pending')
              .toList();
          final incoming = pendingDocs
              .where((d) => d.data()['requested_by'] != authUid)
              .toList();
          final outgoing = pendingDocs
              .where((d) => d.data()['requested_by'] == authUid)
              .toList();
          final activeDocs =
              allDocs.where((d) => d.data()['status'] == 'active').toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    '申請・友だち',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (incoming.isNotEmpty) ...[
                  const _SectionTitle('受け取った申請'),
                  ...incoming.map((d) => _IncomingTile(
                        docId: d.id,
                        data: d.data(),
                      )),
                ],
                if (outgoing.isNotEmpty) ...[
                  const _SectionTitle('送った申請（承認待ち）'),
                  ...outgoing.map((d) => _OutgoingTile(
                        docId: d.id,
                        data: d.data(),
                        myUid: authUid,
                      )),
                ],
                const _SectionTitle('友だち'),
                if (activeDocs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Text(
                      '友だちがいません。右上の＋から追加できます。',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  ...activeDocs.map((d) {
                    final data = d.data();
                    final name = MessagingService.peerName(data, authUid);
                    return _FriendChatListTile(
                      pairId: d.id,
                      peerName: name,
                    );
                  }),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: MessagingService.directChatLastMessageStream(pairId),
      builder: (context, msgSnap) {
        var subtitle = 'メッセージがありません';
        if (msgSnap.hasError) {
          subtitle = 'プレビューを読めません';
        } else if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
          subtitle = MessagingService.previewFromMessage(
            msgSnap.data!.docs.first.data(),
          );
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
    if (_busy) return;
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールを入力してください')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final userSnap = await MessagingService.findUserByEmail(email);
      if (userSnap == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ユーザーが見つかりません')),
          );
        }
        return;
      }
      final data = userSnap.data()!;
      final targetUid = userSnap.id;
      final targetName = '${data['name'] ?? 'ユーザー'}';
      if (!mounted) return;
      final prov = Provider.of<UserProvider>(context, listen: false);
      final err = await MessagingService.sendFriendRequest(
        targetUid: targetUid,
        targetName: targetName,
        myName: prov.userName,
      );
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('送信しました')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            '友だちを追加',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '相手の登録メールアドレスを入力',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'メールアドレス',
              border: OutlineInputBorder(),
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
                : const Text('申請を送る'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
    final from = data['requested_by'] as String? ?? '';
    final names = data['names'];
    var fromName = 'ユーザー';
    if (names is Map && names[from] != null) fromName = '${names[from]}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                            const SnackBar(content: Text('承認しました')),
                          );
                        }
                      }
                    },
                    child: const Text('承認'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        MessagingService.declineRequest(docId),
                    child: const Text('却下'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final name = MessagingService.peerName(data, myUid);
    return ListTile(
      leading: const Icon(Icons.hourglass_empty_rounded),
      title: Text(name.isEmpty ? '承認待ち' : name),
      subtitle: const Text('相手の承認を待っています'),
      trailing: TextButton(
        onPressed: () => MessagingService.cancelOutgoing(docId),
        child: const Text('取り消し'),
      ),
    );
  }
}
