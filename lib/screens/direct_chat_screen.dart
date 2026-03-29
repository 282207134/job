import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../services/chat_media_service.dart';
import '../services/messaging_service.dart';

/// 1対1チャット（`directChats/{pairId}/messages`）
class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({
    super.key,
    required this.pairId,
    required this.peerName,
  });

  final String pairId;
  final String peerName;

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _db = FirebaseFirestore.instance;
  final _messageText = TextEditingController();
  bool _uploading = false;

  String _currentUid(BuildContext context) =>
      FirebaseAuth.instance.currentUser?.uid ??
      Provider.of<UserProvider>(context, listen: false).userId;

  @override
  void dispose() {
    _messageText.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendText() async {
    final text = _messageText.text;
    if (text.trim().isEmpty) return;
    final prov = Provider.of<UserProvider>(context, listen: false);
    final senderId =
        FirebaseAuth.instance.currentUser?.uid ?? prov.userId;
    final senderName = prov.userName;
    _messageText.clear();
    try {
      await MessagingService.sendDirectMessage(
        pairDocId: widget.pairId,
        senderName: senderName,
        senderId: senderId,
        text: text,
      );
    } catch (e) {
      _toast('送信に失敗しました: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_uploading) return;
    final prov = Provider.of<UserProvider>(context, listen: false);
    final senderId =
        FirebaseAuth.instance.currentUser?.uid ?? prov.userId;
    final senderName = prov.userName;
    XFile? x;
    try {
      final picker = ImagePicker();
      x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
    } on PlatformException catch (e) {
      _toast('写真へのアクセスに失敗しました: ${e.message ?? e.code}');
      return;
    } catch (e) {
      _toast('画像の選択に失敗しました: $e');
      return;
    }
    if (x == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ChatMediaService.uploadChatImage(
        pairId: widget.pairId,
        xFile: x,
      );
      await MessagingService.sendDirectMessage(
        pairDocId: widget.pairId,
        senderName: senderName,
        senderId: senderId,
        imageUrl: url,
      );
    } catch (e) {
      var msg = '$e';
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring('Exception: '.length);
      } else {
        msg = ChatMediaService.messageForStorageError(e);
      }
      _toast('画像の送信に失敗しました: $msg');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _bubble({
    required String senderName,
    required String senderId,
    required String text,
    required String? imageUrl,
    required Timestamp? timestamp,
  }) {
    final mine = senderId == _currentUid(context);
    final dt = timestamp?.toDate() ?? DateTime.now();
    final time = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    final url = imageUrl ?? '';
    final hasImage = url.isNotEmpty;
    final hasText = text.isNotEmpty;

    return Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(senderName, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: mine ? Colors.grey.shade200 : Colors.blueGrey.shade800,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: mine ? Colors.black54 : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Text('画像を表示できません'),
                  ),
                ),
              if (hasImage && hasText) const SizedBox(height: 8),
              if (hasText)
                Text(
                  text,
                  style: TextStyle(
                    color: mine ? Colors.black87 : Colors.white,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.peerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('directChats')
                  .doc(widget.pairId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'メッセージがありません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final m = docs[index].data();
                    final kind = m['kind'] as String?;
                    final imageUrl = kind == 'image'
                        ? m['image_url'] as String?
                        : null;
                    return _bubble(
                      senderName: '${m['sender_name'] ?? ''}',
                      text: '${m['text'] ?? ''}',
                      imageUrl: imageUrl,
                      senderId: '${m['sender_id'] ?? ''}',
                      timestamp: m['timestamp'] as Timestamp?,
                    );
                  },
                );
              },
            ),
          ),
          Material(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  if (_uploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: _pickAndSendImage,
                      tooltip: '画像',
                    ),
                  Expanded(
                    child: TextField(
                      controller: _messageText,
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力…',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
