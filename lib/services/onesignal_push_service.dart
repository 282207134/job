import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:kantankanri/services/push_payload_router.dart';

/// [onesignal_flutter](https://pub.dev/packages/onesignal_flutter) 集成，参考官方 demo：
/// `initialize` → `requestPermission` → 前台 `notification.display()` → `login(externalId)` 与 Auth 同步。
///
/// 在 OneSignal 控制台创建应用，将 **App ID** 写入 `.env` 的 `ONESIGNAL_APP_ID`。
/// 服务端用 **REST API Key** + 与客户端相同的 `external_id`（Firebase `uid`）发推送，见 `functions/index.js`。
class OneSignalPushService {
  OneSignalPushService._();

  static bool _initialized = false;
  static bool _sdkReady = false;
  static bool _permissionPromptStarted = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;

    // dotenv.load が失敗すると isInitialized=false のまま env が使えない
    final appId = dotenv.isInitialized
        ? (dotenv.env['ONESIGNAL_APP_ID']?.trim() ?? '')
        : '';
    if (appId.isEmpty) {
      debugPrint('OneSignal: ONESIGNAL_APP_ID 未配置，跳过（可在 .env 中填写）');
      return;
    }

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      await OneSignal.initialize(appId);

      // 与官方 example 一致：前台到达时显式 display，否则部分机型可能不展示
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('OneSignal foreground: ${event.notification.title}');
        event.notification.display();
      });
      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        debugPrint('OneSignal click: $data');
        PushPayloadRouter.scheduleHandle(data);
      });

      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          await OneSignal.login(user.uid);
          debugPrint('OneSignal login external_id=${user.uid}');
        } else {
          await OneSignal.logout();
          debugPrint('OneSignal logout');
        }
      });

      await Future<void>.delayed(Duration.zero);
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        await OneSignal.login(u.uid);
      }

      _sdkReady = true;
      _initialized = true;
      debugPrint('OneSignal initialized (权限请在首帧后调用 promptForPushPermission)');
    } catch (e, st) {
      debugPrint('OneSignal: initialize failed (app continues): $e\n$st');
    }
  }

  /// 在 [MaterialApp] 已挂载、具备 Activity 后再请求（例如在 [WidgetsBinding.instance.addPostFrameCallback] 内调用）。
  static Future<void> promptForPushPermission() async {
    if (kIsWeb || !_sdkReady || _permissionPromptStarted) return;
    _permissionPromptStarted = true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        var n = await Permission.notification.status;
        if (!n.isGranted) {
          n = await Permission.notification.request();
        }
        debugPrint('OneSignal: Android POST_NOTIFICATIONS => $n');
      }

      final ok = await OneSignal.Notifications.requestPermission(true);
      debugPrint('OneSignal: requestPermission(fallbackToSettings=true) => $ok');
    } catch (e, st) {
      debugPrint('OneSignal: promptForPushPermission error: $e\n$st');
    }
  }
}
