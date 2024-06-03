import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/splash_screen.dart'; // 引入Cloud Firestore库

class SignupController {
  // 定义静态方法createAccount，用于创建用户账户
  static Future<void> createAccount(
      {required BuildContext context,
      required String email,
      required String password,
      required String name,
      required String country}) async {
    try {
      // 使用Firebase Auth创建用户账号
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 获取当前用户的UID
      var userId = FirebaseAuth.instance.currentUser!.uid;

      // 获取Firestore实例
      var db = FirebaseFirestore.instance;

      // 准备要保存到数据库的用户数据
      Map<String, dynamic> data = {
        "name": name,
        "country": country,
        "email": email,
        "id": userId
      };

      try {
        // 在Firestore的users集合中，使用用户UID作为文档ID来保存用户数据
        await db.collection("users").doc(userId).set(data);
      } catch (e) {
        print(e); // 打印出任何在保存数据时发生的错误
      }

      // 用户注册成功后，重定向到启动屏幕，并清除导航堆栈
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return SplashScreen();
      }), (route) => false);

      print("Account created successfully!"); // 打印账户创建成功的消息
    } catch (e) {
      // 如果创建账户过程中出错，显示一个SnackBar提示错误信息
      SnackBar messageSnackBar =
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(messageSnackBar);

      print(e); // 打印错误信息
    }
  }
}
