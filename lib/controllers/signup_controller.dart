import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 库
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具包
import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库

import '../screens/splash_screen.dart'; // 导入启动屏幕
import '../services/push_notification_service.dart'; // 导入推送通知服务
import '../utils/firebase_auth_messages.dart'; // 导入 Firebase 认证消息工具

class SignupController { // 注册控制器类
  static Future<void> createAccount({ // 静态创建账户方法
    required BuildContext context, // 必需的构建上下文参数
    required String email, // 必需的邮箱参数
    required String password, // 必需的密码参数
    required String name, // 必需的姓名参数
    required String Function(String key) tr, // 必需的翻译函数参数
  }) async { // 异步方法
    try { // 尝试执行注册
      await FirebaseAuth.instance.createUserWithEmailAndPassword( // 使用 Firebase 创建用户
        email: email, // 设置邮箱
        password: password, // 设置密码
      );

      final userId = FirebaseAuth.instance.currentUser!.uid; // 获取当前用户的 ID
      final db = FirebaseFirestore.instance; // 获取 Firestore 实例

      final emailNorm = email.trim().toLowerCase(); // 规范化邮箱(去除空格并转小写)
      final data = <String, dynamic>{ // 准备用户数据
        'name': name, // 姓名
        'email': emailNorm, // 规范化后的邮箱
        'id': userId, // 用户 ID
      };

      try { // 尝试保存用户数据到 Firestore
        await db.collection('users').doc(userId).set(data); // 在 users 集合中创建文档
      } catch (e) { // 捕获异常
        debugPrint('$e'); // 打印错误信息
      }

      if (!kIsWeb) { // 如果不是 Web 平台
        await PushNotificationService.syncTokenNow(); // 同步推送令牌
      }

      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      Navigator.pushAndRemoveUntil( // 导航并移除所有之前的路由
        context, // 当前上下文
        MaterialPageRoute<void>( // 创建 Material 页面路由
          builder: (context) => const SplashScreen(), // 跳转到启动屏幕
        ),
        (route) => false, // 移除所有之前的路由
      );
      debugPrint('Account created successfully!'); // 打印成功创建账户日志
    } on FirebaseAuthException catch (e) { // 捕获 Firebase 认证异常
      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      final msg = tr(FirebaseAuthMessages.signupErrorKey(e)); // 获取错误消息的翻译
      ScaffoldMessenger.of(context).showSnackBar( // 显示 SnackBar 提示
        SnackBar(backgroundColor: Colors.red.shade700, content: Text(msg)), // 深红色背景的 SnackBar
      );
      debugPrint('Signup FirebaseAuthException: ${e.code}'); // 打印异常代码日志
    } catch (e, st) { // 捕获其他异常
      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      ScaffoldMessenger.of(context).showSnackBar( // 显示 SnackBar 提示
        SnackBar( // SnackBar 组件
          backgroundColor: Colors.red.shade700, // 深红色背景
          content: Text(tr('auth_signup_failed')), // 显示注册失败消息
        ),
      );
      debugPrint('Signup error: $e\n$st'); // 打印错误信息和堆栈跟踪
    }
  }
}
