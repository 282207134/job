import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/screens/contacts_messages_screen.dart';
import 'package:kantankanri/screens/direct_chat_screen.dart';
import 'package:kantankanri/screens/shared_calendar_sheet.dart';

/// Cloud Functions / OneSignal / FCM の data ペイロード（`type`, `pair_id` 等）から画面へ遷移する。
class PushPayloadRouter {
  PushPayloadRouter._();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static Map<String, String>? _queued;
  static int _drainAttempt = 0;
  static const int _maxDrainAttempts = 25;

  static void attachNavigator(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static Map<String, String> _normalize(Map<dynamic, dynamic>? raw) {
    final out = <String, String>{};
    if (raw == null) return out;
    for (final e in raw.entries) {
      final k = '${e.key}'.trim();
      if (k.isEmpty) continue;
      if (e.value == null) continue;
      final v = '${e.value}'.trim();
      if (v.isEmpty) continue;
      out[k] = v;
    }
    return out;
  }

  /// ナビゲータとログインが揃うまで数回リトライする（コールドスタート時）。
  static void scheduleHandle(Object? raw) {
    if (raw is! Map) {
      debugPrint('PushPayloadRouter: skip (payload is not a Map)');
      return;
    }
    final norm = _normalize(Map<dynamic, dynamic>.from(raw));
    if (norm['type'] == null && norm.isEmpty) {
      debugPrint('PushPayloadRouter: skip (empty payload)');
      return;
    }
    _queued = norm;
    _drainAttempt = 0;
    _pumpDrain();
  }

  static void _pumpDrain() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final nav = _navigatorKey;
      final ctx = nav?.currentContext;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (ctx == null || uid == null || !ctx.mounted) {
        if (_drainAttempt++ < _maxDrainAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          _pumpDrain();
        } else {
          debugPrint('PushPayloadRouter: gave up (no context or user)');
          _queued = null;
        }
        return;
      }
      final pending = _queued;
      _queued = null;
      if (pending != null) {
        await _openForPayload(ctx, pending);
      }
    });
  }

  static Future<String> _peerDisplayName(String pairId) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return 'Chat';
    final parts = pairId.split('__');
    if (parts.length != 2) return 'Chat';
    final other = parts[0] == myUid ? parts[1] : parts[0];
    try {
      final link = await FirebaseFirestore.instance
          .collection('friend_links')
          .doc(pairId)
          .get();
      final names = link.data()?['names'];
      if (names is Map) {
        final n = names[other];
        if (n is String && n.trim().isNotEmpty) return n.trim();
      }
      final u = await FirebaseFirestore.instance
          .collection('users')
          .doc(other)
          .get();
      final d = u.data();
      if (d != null) {
        for (final k in ['displayName', 'name', 'userName', 'email']) {
          final v = d[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    } catch (e) {
      debugPrint('PushPayloadRouter: peer name: $e');
    }
    return 'Chat';
  }

  static Future<void> _openForPayload(
    BuildContext context,
    Map<String, String> data,
  ) async {
    final type = data['type'];
    if (type == null) return;

    switch (type) {
      case 'chat_message':
      case 'incoming_call':
        final pairId = data['pair_id'];
        if (pairId == null) return;
        final name = await _peerDisplayName(pairId);
        if (!context.mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => DirectChatScreen(
              pairId: pairId,
              peerName: name,
            ),
          ),
        );
        break;
      case 'friend_request':
        if (!context.mounted) return;
        final lang = Provider.of<AppLanguageProvider>(context, listen: false);
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (ctx2) => Scaffold(
              appBar: AppBar(
                title: Text(lang.tr('contacts')),
              ),
              body: const ContactsMessagesScreen(),
            ),
          ),
        );
        break;
      case 'calendar_invite':
        if (!context.mounted) return;
        await SharedCalendarSheet.show(context);
        break;
      default:
        debugPrint('PushPayloadRouter: unknown type=$type');
    }
  }
}
