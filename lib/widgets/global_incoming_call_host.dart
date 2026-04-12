import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:characters/characters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kantankanri/config/livekit_config.dart';
import 'package:kantankanri/pages/direct_video_call_page.dart';
import 'package:kantankanri/pages/direct_voice_call_page.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/services/direct_call_signal_service.dart';
import 'package:kantankanri/services/messaging_service.dart';

/// アプリ全体で着信を全画面表示（最小化可能）
class GlobalIncomingCallHost extends StatefulWidget {
  const GlobalIncomingCallHost({super.key, required this.navigatorKey});

  /// [MaterialApp] に渡したルート [Navigator] 用キー（builder 内では [Navigator.of] が使えない）
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<GlobalIncomingCallHost> createState() => _GlobalIncomingCallHostState();
}

class _GlobalIncomingCallHostState extends State<GlobalIncomingCallHost> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _friendsSub;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _pairSubs = {};
  final Map<String, QuerySnapshot<Map<String, dynamic>>> _lastIncomingByPair =
      {};
  String? _listeningUid;
  QueryDocumentSnapshot<Map<String, dynamic>>? _pending;
  bool _minimized = false;
  AudioPlayer? _ringtone;

  Future<void> _syncRingtone(bool play) async {
    if (!play) {
      final p = _ringtone;
      _ringtone = null;
      if (p != null) {
        try {
          await p.stop();
        } catch (_) {}
        await p.dispose();
      }
      return;
    }
    if (_ringtone != null) return;
    try {
      final p = AudioPlayer();
      _ringtone = p;
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource('sounds/notify.wav'));
    } catch (e, st) {
      debugPrint('GlobalIncomingCallHost ringtone: $e\n$st');
      final p = _ringtone;
      _ringtone = null;
      if (p != null) {
        await p.dispose();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final initial = FirebaseAuth.instance.currentUser?.uid;
    if (initial != null && initial.isNotEmpty) {
      _attachIncomingIfNeeded(initial);
    }
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _attachIncomingIfNeeded(user?.uid);
    });
  }

  @override
  void dispose() {
    unawaited(_syncRingtone(false));
    _authSub?.cancel();
    _teardownPairListeners();
    super.dispose();
  }

  void _teardownPairListeners() {
    _friendsSub?.cancel();
    _friendsSub = null;
    for (final s in _pairSubs.values) {
      s.cancel();
    }
    _pairSubs.clear();
    _lastIncomingByPair.clear();
  }

  void _attachIncomingIfNeeded(String? uid) {
    if (uid == null || uid.isEmpty) {
      unawaited(_syncRingtone(false));
      _teardownPairListeners();
      _listeningUid = null;
      if (mounted && (_pending != null || _minimized)) {
        setState(() {
          _pending = null;
          _minimized = false;
        });
      }
      return;
    }
    if (_listeningUid == uid && _friendsSub != null) return;
    _teardownPairListeners();
    _listeningUid = uid;
    _friendsSub = MessagingService.friendLinksForUser(uid).listen(
      _onFriendLinksSnap,
      onError: (Object e, StackTrace st) =>
          debugPrint('GlobalIncomingCallHost friend_links: $e'),
    );
  }

  void _onFriendLinksSnap(QuerySnapshot<Map<String, dynamic>> snap) {
    if (!mounted) return;
    final myUid = _listeningUid;
    if (myUid == null) return;

    final activePairIds = <String>{};
    for (final d in snap.docs) {
      if ((d.data()['status'] as String?) == 'active') {
        activePairIds.add(d.id);
      }
    }

    final toRemove = _pairSubs.keys.where((k) => !activePairIds.contains(k)).toList();
    for (final k in toRemove) {
      _pairSubs.remove(k)?.cancel();
      _lastIncomingByPair.remove(k);
    }

    for (final pairId in activePairIds) {
      if (_pairSubs.containsKey(pairId)) continue;
      _pairSubs[pairId] =
          DirectCallSignalService.incomingForUser(pairId, myUid).listen(
        (s) {
          if (!mounted) return;
          _lastIncomingByPair[pairId] = s;
          _recomputeBestPending();
        },
        onError: (Object e, StackTrace st) => debugPrint(
          'GlobalIncomingCallHost call_signals $pairId: $e',
        ),
      );
    }

    _recomputeBestPending();
  }

  void _recomputeBestPending() {
    if (!mounted) return;
    final now = DateTime.now();
    QueryDocumentSnapshot<Map<String, dynamic>>? best;
    Timestamp? bestTs;
    for (final snap in _lastIncomingByPair.values) {
      for (final d in snap.docs) {
        final data = d.data();
        if ((data['status'] as String?) != 'pending') continue;
        final ts = data['created_at'] as Timestamp?;
        if (ts != null &&
            now.difference(ts.toDate()) > const Duration(minutes: 10)) {
          continue;
        }
        if (best == null) {
          best = d;
          bestTs = ts;
          continue;
        }
        if (ts != null && bestTs != null && ts.compareTo(bestTs) > 0) {
          best = d;
          bestTs = ts;
        } else if (bestTs == null && ts != null) {
          best = d;
          bestTs = ts;
        }
      }
    }
    setState(() {
      _pending = best;
      if (best == null) _minimized = false;
    });
    unawaited(_syncRingtone(best != null));
  }

  Future<void> _accept(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final room = data['room_name'] as String?;
    final type = data['call_type'] as String?;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null || room == null) return;
    if (!LiveKitConfig.isConfigured) {
      if (!mounted) return;
      final msg =
          context.read<AppLanguageProvider>().tr('livekit_not_configured');
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    try {
      await DirectCallSignalService.markAccepted(doc.reference);
    } catch (e) {
      if (!mounted) return;
      final t = context.read<AppLanguageProvider>().tr('call_failed');
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text('$t: $e')));
      return;
    }
    await _syncRingtone(false);
    if (!mounted) return;
    final nav = widget.navigatorKey.currentState;
    if (nav == null) {
      debugPrint('GlobalIncomingCallHost: NavigatorState is null, cannot open call');
      return;
    }
    setState(() {
      _pending = null;
      _minimized = false;
    });
    final lang = context.read<AppLanguageProvider>();
    final fromName = '${data['from_name'] ?? ''}'.trim();
    final peerLabel = fromName.isEmpty ? lang.tr('user_default') : fromName;
    final route = MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => type == 'video'
          ? DirectVideoCallPage(
              roomName: room,
              participantIdentity: myUid,
              peerLabel: peerLabel,
              callSignalRef: doc.reference,
              connectingHint: lang.tr('call_connecting'),
              waitingPeerHint: lang.tr('call_waiting_peer'),
            )
          : DirectVoiceCallPage(
              roomName: room,
              participantIdentity: myUid,
              peerLabel: peerLabel,
              callSignalRef: doc.reference,
              connectingHint: lang.tr('call_connecting'),
              waitingPeerHint: lang.tr('call_waiting_peer'),
            ),
    );
    await nav.push<void>(route);
  }

  Future<void> _reject(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      await DirectCallSignalService.markRejected(doc.reference);
    } catch (_) {}
    if (mounted) {
      final clear = _pending?.id == doc.id;
      setState(() {
        if (clear) {
          _pending = null;
          _minimized = false;
        }
      });
      if (clear) {
        await _syncRingtone(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _pending;
    if (doc == null) return const SizedBox.shrink();

    return Consumer<AppLanguageProvider>(
      builder: (context, lang, _) {
        final data = doc.data();
        final fromName = '${data['from_name'] ?? ''}'.trim();
        final label = fromName.isEmpty ? lang.tr('user_default') : fromName;
        final video = data['call_type'] == 'video';
        final subtitle =
            video ? lang.tr('call_incoming_video') : lang.tr('call_incoming_voice');
        final initial = label.isEmpty
            ? '?'
            : label.characters.first.toUpperCase();

        if (_minimized) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                0,
                8,
                MediaQuery.paddingOf(context).bottom + 8,
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade900,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.open_in_full, color: Colors.white70),
                        onPressed: () => setState(() => _minimized = false),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => _reject(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.greenAccent),
                        onPressed: () => _accept(doc),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return SizedBox.expand(
          child: Material(
            color: Colors.black.withValues(alpha: 0.92),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon:
                              const Icon(Icons.minimize, color: Colors.white70),
                          onPressed: () => setState(() => _minimized = true),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.pink.shade100,
                              child: Text(
                                initial,
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.pink.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _RoundCallAction(
                              color: Colors.red,
                              icon: Icons.call_end,
                              label: lang.tr('call_decline'),
                              onTap: () => _reject(doc),
                            ),
                            _RoundCallAction(
                              color: Colors.green,
                              icon: Icons.call,
                              label: lang.tr('call_accept'),
                              onTap: () => _accept(doc),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoundCallAction extends StatelessWidget {
  const _RoundCallAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
