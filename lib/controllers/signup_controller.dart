import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../services/push_notification_service.dart';
import '../utils/firebase_auth_messages.dart';

class SignupController {
  static Future<void> createAccount({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String Function(String key) tr,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;

      final emailNorm = email.trim().toLowerCase();
      final data = <String, dynamic>{
        'name': name,
        'email': emailNorm,
        'id': userId,
      };

      try {
        await db.collection('users').doc(userId).set(data);
      } catch (e) {
        debugPrint('$e');
      }

      if (!kIsWeb) {
        await PushNotificationService.syncTokenNow();
      }

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const SplashScreen(),
        ),
        (route) => false,
      );
      debugPrint('Account created successfully!');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = tr(FirebaseAuthMessages.signupErrorKey(e));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red.shade700, content: Text(msg)),
      );
      debugPrint('Signup FirebaseAuthException: ${e.code}');
    } catch (e, st) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(tr('auth_signup_failed')),
        ),
      );
      debugPrint('Signup error: $e\n$st');
    }
  }
}
