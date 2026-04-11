import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import 'package:kantankanri/config/livekit_config.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/services/direct_call_signal_service.dart';
import 'package:kantankanri/utils/livekit_token_generator.dart';

/// 友だちとのビデオ通話（LiveKit）
class DirectVideoCallPage extends StatefulWidget {
  const DirectVideoCallPage({
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
  State<DirectVideoCallPage> createState() => _DirectVideoCallPageState();
}

class _DirectVideoCallPageState extends State<DirectVideoCallPage> {
  Room? _room;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;
  String? _errorMessage;
  List<RemoteParticipant> _remoteParticipants = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _signalSub;
  bool _localEnding = false;
  bool _showLocalPip = true;

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

  /// LiveKit の切断のみ（状態は _hangUp / リモート終了側で処理）
  Future<void> _disconnectRoomOnly() async {
    if (_room != null) {
      await _room!.disconnect();
      _room = null;
    }
    if (mounted) {
      setState(() {
        _isConnected = false;
        _isCameraEnabled = false;
        _isMicrophoneEnabled = false;
        _remoteParticipants = [];
      });
    }
  }

  @override
  void dispose() {
    _signalSub?.cancel();
    unawaited(_room?.disconnect());
    super.dispose();
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
        await room.localParticipant?.setCameraEnabled(true);
        setState(() {
          _isCameraEnabled = true;
        });
      } catch (e) {
        debugPrint('camera: $e');
      }

      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
        setState(() {
          _isMicrophoneEnabled = true;
        });
      } catch (e) {
        debugPrint('mic: $e');
      }

      setState(() {
        _room = room;
        _isConnected = true;
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isConnecting = false;
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_room == null || _room!.localParticipant == null) return;
    try {
      final enabled = !_isCameraEnabled;
      await _room!.localParticipant!.setCameraEnabled(enabled);
      setState(() {
        _isCameraEnabled = enabled;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
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

  Widget _buildVideoTrack(VideoTrack track) {
    return VideoTrackRenderer(track);
  }

  VideoTrack? _localVideoTrack() {
    final lp = _room?.localParticipant;
    if (lp == null) return null;
    final pubs = lp.videoTrackPublications;
    if (pubs.isEmpty) return null;
    return pubs.first.track as VideoTrack?;
  }

  Widget _buildLocalVideo() {
    if (_room == null || _room!.localParticipant == null || !_isCameraEnabled) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.person, size: 48, color: Colors.white54),
        ),
      );
    }

    final videoTrack = _localVideoTrack();

    if (videoTrack == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return _buildVideoTrack(videoTrack);
  }

  VideoTrack? _remoteVideoTrack(RemoteParticipant participant) {
    final pubs = participant.videoTrackPublications;
    if (pubs.isEmpty) return null;
    return pubs.first.track as VideoTrack?;
  }

  /// 相手映像を画面いっぱいに近いサイズでクロップ表示（16:9 想定）
  Widget _remoteCover(VideoTrack track) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cw = constraints.maxWidth;
        final ch = constraints.maxHeight;
        const ar = 16 / 9;
        var vw = cw;
        var vh = cw / ar;
        if (vh < ch) {
          vh = ch;
          vw = ch * ar;
        }
        return ClipRect(
          child: OverflowBox(
            maxWidth: vw,
            maxHeight: vh,
            alignment: Alignment.center,
            child: SizedBox(
              width: vw,
              height: vh,
              child: _buildVideoTrack(track),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemoteVideo(RemoteParticipant participant) {
    final videoTrack = _remoteVideoTrack(participant);

    if (videoTrack == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 80, color: Colors.white54),
              const SizedBox(height: 8),
              Text(
                participant.identity,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return _remoteCover(videoTrack);
  }

  Widget _remoteLayer(String waiting) {
    if (_remoteParticipants.isEmpty) {
      return Positioned.fill(
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: Text(
              waiting,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }
    if (_remoteParticipants.length == 1) {
      return Positioned.fill(
        child: _buildRemoteVideo(_remoteParticipants.first),
      );
    }
    return Positioned.fill(
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.72,
        ),
        itemCount: _remoteParticipants.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildRemoteVideo(_remoteParticipants[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.peerLabel ?? widget.roomName;
    final connecting = widget.connectingHint ?? 'Connecting…';
    final waiting = widget.waitingPeerHint ?? 'Waiting…';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _hangUp();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(title),
          actions: [
            if (_isConnected)
              IconButton(
                icon: const Icon(Icons.call_end),
                onPressed: _hangUp,
              ),
          ],
        ),
        body: _isConnecting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(connecting, style: const TextStyle(color: Colors.white70)),
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
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _connectToRoom,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isConnected
                    ? Builder(
                        builder: (ctx) {
                          final lang = Provider.of<AppLanguageProvider>(
                            ctx,
                            listen: false,
                          );
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                          _remoteLayer(waiting),
                          if (_showLocalPip)
                            Positioned(
                              bottom: 108,
                              right: 12,
                              child: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(10),
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.28,
                                  constraints: const BoxConstraints(
                                    maxWidth: 132,
                                    minHeight: 120,
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white54),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: _buildLocalVideo(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ColoredBox(
                              color: Colors.black87,
                              child: SafeArea(
                                top: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _showLocalPip
                                              ? Icons.picture_in_picture_alt
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        tooltip: _showLocalPip
                                            ? lang.tr('call_hide_self_preview')
                                            : lang.tr('call_show_self_preview'),
                                        onPressed: () => setState(
                                            () => _showLocalPip = !_showLocalPip),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isCameraEnabled
                                              ? Icons.videocam
                                              : Icons.videocam_off,
                                          color: _isCameraEnabled
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        iconSize: 28,
                                        onPressed: _toggleCamera,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isMicrophoneEnabled
                                              ? Icons.mic
                                              : Icons.mic_off,
                                          color: _isMicrophoneEnabled
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        iconSize: 28,
                                        onPressed: _toggleMicrophone,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.call_end,
                                            color: Colors.red),
                                        iconSize: 32,
                                        onPressed: _hangUp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                            ],
                          );
                        },
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}
