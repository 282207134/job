// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kantankanri/main.dart';
import 'package:provider/provider.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/providers/app_lock_provider.dart';
import 'package:kantankanri/providers/userProvider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock Firebase initialization
    await Firebase.initializeApp();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
          ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
