import 'package:firebase_auth/firebase_auth.dart'; // 引入 Firebase 认证库
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具包
import 'package:flutter/material.dart'; // 引入 Flutter 材料设计库

import '../screens/splash_screen.dart'; // 引入启动屏幕组件
import '../services/push_notification_service.dart'; // 引入推送通知服务
import '../utils/firebase_auth_messages.dart'; // 引入 Firebase 认证消息工具

class LoginController { // 登录控制器类
  static Future<void> login({ // 静态登录方法
    required BuildContext context, // 必需的构建上下文参数
    required String email, // 必需的邮箱参数
    required String password, // 必需的密码参数
    required String Function(String key) tr, // 必需的翻译函数参数
  }) async { // 异步方法
    try { // 尝试执行登录
      await FirebaseAuth.instance // 等待 Firebase 认证实例
          .signInWithEmailAndPassword(email: email, password: password); // 使用邮箱和密码登录

      if (!kIsWeb) { // 如果不是 Web 平台
        await PushNotificationService.syncTokenNow(); // 同步推送令牌
      }

      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      Navigator.pushAndRemoveUntil( // 导航并移除所有之前的路由
        context, // 当前上下文
        MaterialPageRoute<void>(builder: (context) => const SplashScreen()), // 跳转到启动屏幕
        (route) => false, // 移除所有之前的路由
      );
      debugPrint('Login successfully!'); // 打印成功登录日志
    } on FirebaseAuthException catch (e) { // 捕获 Firebase 认证异常
      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      final msg = tr(FirebaseAuthMessages.loginErrorKey(e)); // 获取错误消息的翻译
      ScaffoldMessenger.of(context).showSnackBar( // 显示 SnackBar 提示
        SnackBar(backgroundColor: Colors.red, content: Text(msg)), // 红色背景的 SnackBar
      );
      debugPrint('Login FirebaseAuthException: ${e.code}'); // 打印异常代码日志
    } catch (e, st) { // 捕获其他异常
      if (!context.mounted) return; // 如果上下文未挂载,直接返回
      ScaffoldMessenger.of(context).showSnackBar( // 显示 SnackBar 提示
        SnackBar( // SnackBar 组件
          backgroundColor: Colors.red, // 红色背景
          content: Text(tr('auth_login_failed')), // 显示登录失败消息
        ),
      );
      debugPrint('Login error: $e\n$st'); // 打印错误信息和堆栈跟踪
    }
  }
}