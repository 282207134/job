import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../services/push_notification_service.dart';

class SignupController {
  static Future<void> createAccount({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(e.toString()),
        ),
      );
      debugPrint('$e');
    }
  }
}
