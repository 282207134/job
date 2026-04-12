import 'dart:async';
import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import 'package:kantankanri/config/livekit_config.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/services/direct_call_signal_service.dart';
import 'package:kantankanri/utils/livekit_token_generator.dart';

/// 友だちとの音声通話（LiveKit）— 1 対 1 向けシンプル UI
class DirectVoiceCallPage extends StatefulWidget {
  const DirectVoiceCallPage({
    super.key,
    required this.roomName,
    required this.participantIdentity,
    this.peerLabel,
    this.connectingHint,
    this.waitingPeerHint,
    this.callSignalRef,
  });

  final String roomName;
  final String participantIdentity;
  final String? peerLabel;
  final String? connectingHint;
  final String? waitingPeerHint;
  final DocumentReference<Map<String, dynamic>>? callSignalRef;

  @override
  State<DirectVoiceCallPage> createState() => _DirectVoiceCallPageState();
}

class _DirectVoiceCallPageState extends State<DirectVoiceCallPage> {
  Room? _room;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isMicrophoneEnabled = false;
  bool _speakerOn = true;
  String? _errorMessage;
  List<RemoteParticipant> _remoteParticipants = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _signalSub;
  bool _localEnding = false;
  Timer? _elapsedTicker;
  DateTime? _connectedAt;

  @override
  void initState() {
    super.initState();
    _connectToRoom();
    _attachSignalListener();
  }

  void _attachSignalListener() {
    final ref = widget.callSignalRef;
    if (ref == null) return;
    _signalSub = ref.snapshots().listen((snap) {
      final s = snap.data()?['status'] as String?;
      if (!mounted || s != 'ended') return;
      if (_localEnding) return;
      unawaited(_handleRemoteEnded());
    });
  }

  Future<void> _handleRemoteEnded() async {
    if (_localEnding) return;
    _localEnding = true;
    _signalSub?.cancel();
    await _disconnectRoomOnly();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _hangUp() async {
    if (_localEnding) return;
    _localEnding = true;
    _signalSub?.cancel();
    await _disconnectRoomOnly();
    final r = widget.callSignalRef;
    if (r != null) {
      try {
        await DirectCallSignalService.markEnded(r);
      } catch (_) {}
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _disconnectRoomOnly() async {
    _elapsedTicker?.cancel();
    _elapsedTicker = null;
    _connectedAt = null;
    if (_room != null) {
      await _room!.disconnect();
      _room = null;
    }
    if (mounted) {
      setState(() {
        _isConnected = false;
        _isMicrophoneEnabled = false;
        _remoteParticipants = [];
      });
    }
  }

  @override
  void dispose() {
    _elapsedTicker?.cancel();
    _signalSub?.cancel();
    unawaited(_room?.disconnect());
    super.dispose();
  }

  void _startElapsedTicker() {
    _connectedAt = DateTime.now();
    _elapsedTicker?.cancel();
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _connectToRoom() async {
    if (_isConnecting || _isConnected) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final token = LivekitTokenGenerator.generateToken(
        roomName: widget.roomName,
        participantIdentity: widget.participantIdentity,
        participantName: widget.participantIdentity,
      );

      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      await room.connect(
        LiveKitConfig.url,
        token,
      );

      room.addListener(() {
        if (mounted) {
          setState(() {
            _remoteParticipants = room.remoteParticipants.values.toList();
          });
        }
      });

      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
        setState(() {
          _isMicrophoneEnabled = true;
        });
      } catch (e) {
        debugPrint('mic enable: $e');
      }

      try {
        await room.setSpeakerOn(true, forceSpeakerOutput: false);
        setState(() {
          _speakerOn = true;
        });
      } catch (e) {
        debugPrint('speaker default: $e');
      }

      setState(() {
        _room = room;
        _isConnected = true;
        _isConnecting = false;
      });
      _startElapsedTicker();
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isConnecting = false;
      });
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_room == null || _room!.localParticipant == null) return;
    try {
      final enabled = !_isMicrophoneEnabled;
      await _room!.localParticipant!.setMicrophoneEnabled(enabled);
      setState(() {
        _isMicrophoneEnabled = enabled;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _toggleSpeaker() async {
    if (_room == null) return;
    final next = !_speakerOn;
    try {
      await _room!.setSpeakerOn(next, forceSpeakerOutput: false);
      setState(() {
        _speakerOn = next;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  String _peerDisplayName(AppLanguageProvider lang) {
    final n = widget.peerLabel?.trim();
    if (n != null && n.isNotEmpty) return n;
    return lang.tr('user_default');
  }

  String _peerInitial(String displayName) {
    if (displayName.isEmpty) return '?';
    return displayName.characters.first.toUpperCase();
  }

  Widget _blurredBackdrop() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a237e),
                Color(0xFF0d1b2a),
                Color(0xFF1b263b),
              ],
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }

  Widget _topBar(String elapsedText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          elapsedText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _bottomAction({
    required Widget iconChild,
    required String label,
    required VoidCallback onTap,
    double buttonSize = 56,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Center(child: iconChild),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _hangUpColumn(AppLanguageProvider lang) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.red.shade600,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _hangUp,
              child: const SizedBox(
                width: 68,
                height: 68,
                child: Center(
                  child: Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang.tr('call_voice_hang_up'),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _connectedBody(AppLanguageProvider lang) {
    final displayName = _peerDisplayName(lang);
    final initial = _peerInitial(displayName);
    final remoteJoined = _remoteParticipants.isNotEmpty;
    final waiting = widget.waitingPeerHint ?? 'Waiting…';
    final elapsed = _connectedAt != null
        ? _formatElapsed(DateTime.now().difference(_connectedAt!))
        : '00:00';

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _blurredBackdrop()),
        SafeArea(
          child: Column(
            children: [
              _topBar(elapsed),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 132,
                        height: 132,
                        color: Colors.white.withValues(alpha: 0.12),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!remoteJoined) ...[
                      const SizedBox(height: 14),
                      Text(
                        waiting,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  MediaQuery.paddingOf(context).bottom + 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bottomAction(
                      iconChild: Icon(
                        _isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
                        color: Colors.black87,
                        size: 28,
                      ),
                      label: _isMicrophoneEnabled
                          ? lang.tr('call_voice_mic_on')
                          : lang.tr('call_voice_mic_off'),
                      onTap: _toggleMicrophone,
                    ),
                    _hangUpColumn(lang),
                    _bottomAction(
                      iconChild: Icon(
                        _speakerOn ? Icons.volume_up : Icons.volume_off,
                        color: Colors.black87,
                        size: 28,
                      ),
                      label: _speakerOn
                          ? lang.tr('call_voice_speaker_on')
                          : lang.tr('call_voice_speaker_off'),
                      onTap: _toggleSpeaker,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>();
    final connecting = widget.connectingHint ?? 'Connecting…';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _hangUp();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isConnecting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white70),
                    const SizedBox(height: 16),
                    Text(
                      connecting,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _connectToRoom,
                            child: Text(lang.tr('call_retry')),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isConnected
                    ? _connectedBody(lang)
                    : const SizedBox.shrink(),
      ),
    );
  }
}
