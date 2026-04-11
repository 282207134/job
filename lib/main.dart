import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kantankanri/app/app_routes.dart';
import 'package:kantankanri/app/home_page.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/providers/app_lock_provider.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:kantankanri/screens/app_lock_gate_screen.dart';
import 'package:kantankanri/splashScreen/OnBoardingPageState.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppLanguageProvider, AppLockProvider>(
      builder: (context, lang, lock, _) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => lock.recordActivity(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: lang.locale,
          supportedLocales: const [
            Locale('zh'),
            Locale('ja'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final hasUser = FirebaseAuth.instance.currentUser != null;
            final showLockGate = hasUser && lock.ready && lock.shouldRequireUnlock;
            return Stack(
              children: [
                if (child != null) child,
                if (showLockGate) const Positioned.fill(child: AppLockGateScreen()),
              ],
            );
          },
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return FutureBuilder<void>(
                  future: lock.ensureSynced(snapshot.data!.uid),
                  builder: (context, lockSnap) {
                    if (lockSnap.connectionState != ConnectionState.done ||
                        !lock.ready) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const HomePage();
                  },
                );
              }
              return FutureBuilder<void>(
                future: lock.ensureSynced(null),
                builder: (context, lockSnap) {
                  if (lockSnap.connectionState != ConnectionState.done ||
                      !lock.ready) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return FlutterSplashScreen.fadeIn(
                    backgroundColor: Colors.cyan,
                    duration: const Duration(seconds: 5),
                    animationDuration: const Duration(seconds: 10),
                    onInit: () => debugPrint('On Init'),
                    onEnd: () => debugPrint('On End'),
                    childWidget: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Image.asset('assets/0.jpg'),
                    ),
                    onAnimationEnd: () => debugPrint('On Fade In End'),
                    nextScreen: const OnBoardingPage(),
                  );
                },
              );
            },
          ),
          routes: buildAppRoutes(),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (context) => AppLockProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
