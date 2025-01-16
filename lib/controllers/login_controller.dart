import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:kantankanri/screens/dashboard_screen.dart';

import '../screens/splash_screen.dart'; // 引入仪表板屏幕组件

class LoginController {
  // 定义一个静态方法login，用于处理登录操作
  static Future<void> login(
      {required BuildContext context,
        required String email,
        required String password}) async {
    try {
      // 使用Firebase Auth进行邮箱和密码的验证
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // 登录成功后，跳转到SplashScreen页面，并清除之前所有的路由栈
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
            return SplashScreen();
          }), (route) => false);

      print("Login successfully!"); // 控制台打印登录成功的消息
    } catch (e) {
      // 如果登录过程中出现异常，显示一个红色背景的SnackBar提示错误信息
      SnackBar messageSnackBar =
      SnackBar(backgroundColor: Colors.red, content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(messageSnackBar);

      print(e); // 控制台打印异常信息
    }
  }
}