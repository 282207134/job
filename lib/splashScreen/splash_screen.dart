import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../pages/jobPage/job_page.dart';
import '../pages/managementTools/timer.dart';
import '../pages/jobPage/staff_page.dart';
import '../pages/managementTools/management_tools.dart';
import 'OnBoardingPageState.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.cyan,
        duration: Duration(seconds: 5),
        animationDuration: Duration(seconds: 10),
        onInit: () {
          debugPrint("On Init");
        },
        onEnd: () {
          debugPrint("On End");
        },
        childWidget: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset("assets/0.jpg"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: OnBoardingPage(),
      ),
      routes: {
        '/login': (BuildContext context) => SplashScreen(),
        '/home': (BuildContext context) => HomePage(), // 修改此处为正确的类名
        '/job': (BuildContext context) => JobPage(), //
        '/staff': (BuildContext context) => StaffPage(), //
        '/management_tools': (BuildContext context) => management_tools(),
      },
    );
  }
}
