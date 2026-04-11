import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/livekit_config.dart';
import '../pages/direct_video_call_page.dart';
import '../pages/direct_voice_call_page.dart';
import '../providers/app_language_provider.dart';
import '../providers/userProvider.dart';
import '../services/chat_media_service.dart';
import '../services/direct_call_signal_service.dart';
import '../services/messaging_service.dart';
import '../services/shared_calendar_service.dart';

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

  Future<void> _startOutgoingCall(bool video) async {
    if (_uploading) return;
    if (!LiveKitConfig.isConfigured) {
      _toast(_t('livekit_not_configured'));
      return;
    }
    final myUid = FirebaseAuth.instance.currentUser?.uid ??
        Provider.of<UserProvider>(context, listen: false).userId;
    if (myUid.isEmpty) {
      _toast(_t('not_logged_in'));
      return;
    }
    final peerUid = _peerUid();
    if (peerUid.isEmpty) {
      _toast(_t('unknown_friend'));
      return;
    }
    final senderName = Provider.of<UserProvider>(context, listen: false).userName;
    try {
      final ref = await DirectCallSignalService.createOutgoing(
        pairId: widget.pairId,
        fromUid: myUid,
        toUid: peerUid,
        fromName: senderName,
        callType: video ? 'video' : 'voice',
      );
      if (!mounted) return;
      final result = await showDialog<_CallOutcome>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _OutgoingCallDialog(
          signalRef: ref,
          titleText: video ? _t('call_calling_video') : _t('call_calling_voice'),
          tr: (k) =>
              Provider.of<AppLanguageProvider>(ctx, listen: false).tr(k),
        ),
      );
      if (!mounted) return;
      if (result == _CallOutcome.accepted) {
        final snap = await ref.get();
        final room = snap.data()?['room_name'] as String?;
        if (room == null) return;
        if (!mounted) return;
        final nav = Navigator.of(context);
        final route = MaterialPageRoute<void>(
          builder: (_) => video
              ? DirectVideoCallPage(
                  roomName: room,
                  participantIdentity: myUid,
                  peerLabel: widget.peerName,
                  callSignalRef: ref,
                  connectingHint: _t('call_connecting'),
                  waitingPeerHint: _t('call_waiting_peer'),
                )
              : DirectVoiceCallPage(
                  roomName: room,
                  participantIdentity: myUid,
                  peerLabel: widget.peerName,
                  callSignalRef: ref,
                  connectingHint: _t('call_connecting'),
                  waitingPeerHint: _t('call_waiting_peer'),
                ),
        );
        await nav.push(route);
      } else if (result == _CallOutcome.rejected) {
        _toast(_t('call_rejected'));
      }
    } catch (e) {
      _toast('${_t('call_failed')}: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _t(String key) =>
      Provider.of<AppLanguageProvider>(context, listen: false).tr(key);

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
      _toast('${_t('chat_send_failed')}: $e');
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
      _toast('${_t('photo_access_failed')}: ${e.message ?? e.code}');
      return;
    } catch (e) {
      _toast('${_t('image_pick_failed')}: $e');
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
      _toast('${_t('image_send_failed')}: $msg');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _peerUid() {
    final my = _currentUid(context);
    final parts = widget.pairId.split('__');
    if (parts.length != 2) return '';
    return parts[0] == my ? parts[1] : parts[0];
  }

  Future<void> _sendCalendarInvite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) {
      _toast(_t('not_logged_in'));
      return;
    }
    final peerUid = _peerUid();
    if (peerUid.isEmpty) {
      _toast(_t('unknown_friend'));
      return;
    }

    final roomsSnap = await FirebaseFirestore.instance
        .collection('shared_calendars')
        .where('owner_uid', isEqualTo: myUid)
        .get();
    if (!mounted) return;
    if (roomsSnap.docs.isEmpty) {
      _toast(_t('no_shared_calendar_created'));
      return;
    }

    final items = roomsSnap.docs
        .map(
          (d) => (
            id: d.id,
            name: '${d.data()['name'] ?? _t('default_shared_calendar_name')}',
          ),
        )
        .toList();
    String selectedRoomId = items.first.id;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState) {
            return AlertDialog(
              title: Text('${_t('send_to')} ${widget.peerName}'),
              content: DropdownButtonFormField<String>(
                value: selectedRoomId,
                decoration: InputDecoration(
                  labelText: _t('select_shared_calendar'),
                  border: OutlineInputBorder(),
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedRoomId = v);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: Text(_t('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final selected = items.firstWhere((e) => e.id == selectedRoomId);
                      final myName =
                          Provider.of<UserProvider>(context, listen: false).userName;
                      await SharedCalendarService.inviteByUid(
                        roomId: selected.id,
                        roomName: selected.name,
                        fromName: myName,
                        toUid: peerUid,
                        toName: widget.peerName,
                      );
                      if (!ctx2.mounted) return;
                      Navigator.of(ctx2).pop();
                      _toast(_t('invite_sent'));
                    } catch (e) {
                      if (!ctx2.mounted) return;
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  },
                  child: Text(_t('send')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openPlusActions() async {
    if (_uploading) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(_t('send_image')),
              onTap: () => Navigator.of(ctx).pop('image'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: Text(_t('send_calendar')),
              onTap: () => Navigator.of(ctx).pop('calendar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'image') {
      await _pickAndSendImage();
    } else if (action == 'calendar') {
      await _sendCalendarInvite();
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
                    errorBuilder: (_, __, ___) => Text(_t('image_display_failed')),
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
                  return Center(
                    child: Text('${_t('chat_error_prefix')}: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      _t('no_messages'),
                      style: const TextStyle(color: Colors.grey),
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
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => _startOutgoingCall(false),
                      tooltip: _t('call_voice_tooltip'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam_outlined),
                      onPressed: () => _startOutgoingCall(true),
                      tooltip: _t('call_video_tooltip'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _openPlusActions,
                      tooltip: _t('more'),
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: _messageText,
                      decoration: InputDecoration(
                        hintText: _t('message_input_hint'),
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

enum _CallOutcome { accepted, rejected, cancelled }

/// 発信側：相手が accept / reject するまで待つダイアログ
class _OutgoingCallDialog extends StatefulWidget {
  const _OutgoingCallDialog({
    required this.signalRef,
    required this.titleText,
    required this.tr,
  });

  final DocumentReference<Map<String, dynamic>> signalRef;
  final String titleText;
  final String Function(String key) tr;

  @override
  State<_OutgoingCallDialog> createState() => _OutgoingCallDialogState();
}

class _OutgoingCallDialogState extends State<_OutgoingCallDialog> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.signalRef.snapshots().listen((doc) {
      final s = doc.data()?['status'] as String?;
      if (!mounted || s == null) return;
      if (!context.mounted) return;
      if (s == 'accepted') {
        Navigator.of(context).pop(_CallOutcome.accepted);
      } else if (s == 'rejected') {
        Navigator.of(context).pop(_CallOutcome.rejected);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleText),
      content: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.tr('call_waiting_peer_answer'))),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await DirectCallSignalService.markCancelled(widget.signalRef);
            if (!context.mounted) return;
            Navigator.of(context).pop(_CallOutcome.cancelled);
          },
          child: Text(widget.tr('cancel')),
        ),
      ],
    );
  }
}
