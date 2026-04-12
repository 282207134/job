import 'package:firebase_auth/firebase_auth.dart'; // 引入 Firebase 认证库
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // 引入 Flutter 材料设计库

import '../screens/splash_screen.dart'; // 引入仪表板屏幕组件
import '../services/push_notification_service.dart';
import '../utils/firebase_auth_messages.dart';

class LoginController {
  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    required String Function(String key) tr,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (!kIsWeb) {
        await PushNotificationService.syncTokenNow();
      }

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (context) => const SplashScreen()),
        (route) => false,
      );
      debugPrint('Login successfully!');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = tr(FirebaseAuthMessages.loginErrorKey(e));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(msg)),
      );
      debugPrint('Login FirebaseAuthException: ${e.code}');
    } catch (e, st) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(tr('auth_login_failed')),
        ),
      );
      debugPrint('Login error: $e\n$st');
    }
  }
}