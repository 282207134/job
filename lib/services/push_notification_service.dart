import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../firebase_options.dart';
import 'push_payload_router.dart';

/// 消息类（私信、好友、日历等）：`res/raw/message.wav`，系统通知只响一次。
const String androidMessageChannelId = 'kantankanri_msg_sfx';
const String androidMessageChannelName = '消息与提醒';

/// 来电推送：`res/raw/notify.wav`；全屏接听界面另用 [AssetSource] 循环播放同一文件。
const String androidCallChannelId = 'kantankanri_call_sfx';
const String androidCallChannelName = '语音视频来电';

bool _isIncomingCallPayload(Map<String, dynamic> data) {
  final t = data['type'];
  if (t == null) return false;
  return '$t' == 'incoming_call';
}

Future<void> _ensureAndroidNotifyChannels(
  AndroidFlutterLocalNotificationsPlugin? android,
) async {
  if (android == null) return;
  await android.createNotificationChannel(
    AndroidNotificationChannel(
      androidMessageChannelId,
      androidMessageChannelName,
      description: '私信、好友与日历等（自定义短提示音，每条一次）',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('message'),
      enableVibration: true,
      showBadge: true,
    ),
  );
  await android.createNotificationChannel(
    AndroidNotificationChannel(
      androidCallChannelId,
      androidCallChannelName,
      description: '语音/视频来电推送',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notify'),
      enableVibration: true,
      showBadge: true,
    ),
  );
}

NotificationDetails _notificationDetailsForPayload(
  Map<String, dynamic> data, {
  String? tag,
}) {
  final call = _isIncomingCallPayload(data);
  return NotificationDetails(
    android: AndroidNotificationDetails(
      call ? androidCallChannelId : androidMessageChannelId,
      call ? androidCallChannelName : androidMessageChannelName,
      channelDescription:
          call ? '语音或视频来电' : '消息、好友与日历等',
      importance: Importance.max,
      priority: Priority.max,
      category: call
          ? AndroidNotificationCategory.call
          : AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(call ? 'notify' : 'message'),
      onlyAlertOnce: false,
      tag: tag,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      sound: call ? 'notify.wav' : 'message.wav',
    ),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    'FCM background: id=${message.messageId} '
    'hasNotification=${message.notification != null} data=${message.data}',
  );

  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  final androidImpl = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await _ensureAndroidNotifyChannels(androidImpl);

  final title = _fcmTitle(message);
  final body = _fcmBody(message);
  if (title.isEmpty && body.isEmpty) {
    debugPrint('FCM background: skip show (no title/body in data or notification)');
    return;
  }

  final dataMap = Map<String, dynamic>.from(message.data);
  final nid = (message.messageId ?? '${message.hashCode}').hashCode & 0x7fffffff;
  await plugin.show(
    id: nid,
    title: title.isEmpty ? '通知' : title,
    body: body,
    notificationDetails: _notificationDetailsForPayload(
      dataMap,
      tag: message.messageId ?? 'kantankanri',
    ),
    payload: jsonEncode(message.data),
  );
}

String _fcmTitle(RemoteMessage m) {
  final d = m.data['title'];
  if (d is String && d.isNotEmpty) return d;
  return m.notification?.title ?? '';
}

String _fcmBody(RemoteMessage m) {
  final d = m.data['body'];
  if (d is String && d.isNotEmpty) return d;
  return m.notification?.body ?? '';
}

/// 将 FCM token 写入 `users/{uid}.fcm_token`，供 Cloud Functions 发推送。
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> syncTokenNow() async {
    if (kIsWeb) return;
    await _syncTokenToFirestore();
  }

  static Future<void> onAppResumed() async {
    if (kIsWeb) return;
    await _syncTokenToFirestore();
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;
    _initialized = true;

    await _ensureLocalNotifications();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      var n = await Permission.notification.status;
      if (!n.isGranted) {
        n = await Permission.notification.request();
      }
      debugPrint(
        'Android notification: status=$n granted=${n.isGranted} '
        'provisional=${n.isProvisional} limited=${n.isLimited}',
      );
      final bat = await Permission.ignoreBatteryOptimizations.status;
      if (!bat.isGranted) {
        final r = await Permission.ignoreBatteryOptimizations.request();
        debugPrint('Android ignore battery optimizations: $r');
      }
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _syncTokenToFirestore();
      }
    });

    await Future<void>.delayed(Duration.zero);
    await _syncTokenToFirestore();

    FirebaseMessaging.instance.onTokenRefresh.listen(_persistToken);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _onOpened(initial);
    }
  }

  static Future<void> _ensureLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await _ensureAndroidNotifyChannels(androidPlugin);
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    final p = response.payload;
    if (p == null || p.isEmpty) return;
    try {
      final map = jsonDecode(p) as Map<String, dynamic>;
      debugPrint('Local notification tap: $map');
      PushPayloadRouter.scheduleHandle(map);
    } catch (_) {}
  }

  static Future<void> _syncTokenToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('FCM sync skipped: no signed-in user');
      return;
    }
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _persistToken(token);
        debugPrint('FCM token saved for uid=$uid (len=${token.length})');
      } else {
        debugPrint('FCM getToken returned null');
      }
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
    }
  }

  static Future<void> _persistToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fcm_token': token,
          'fcm_token_updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FCM save token to Firestore failed: $e');
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final t = _fcmTitle(message);
    final title = t.isEmpty ? '通知' : t;
    final body = _fcmBody(message);
    final dataMap = Map<String, dynamic>.from(message.data);

    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: _notificationDetailsForPayload(dataMap),
      payload: jsonEncode(message.data),
    );
  }

  static void _onOpened(RemoteMessage message) {
    debugPrint('FCM notification opened: ${message.data}');
    PushPayloadRouter.scheduleHandle(message.data);
  }
}
