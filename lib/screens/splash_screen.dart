import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter的基础构架
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符组件
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/userProvider.dart';
import 'login_screen.dart'; // 引入状态管理库

// 定义SplashScreen类，一个有状态的小部件
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // 构造函数

  @override
  State<SplashScreen> createState() => _SplashScreenState(); // 创建状态
}

// 定义_SplashScreenState类，是SplashScreen的状态
class _SplashScreenState extends State<SplashScreen> {
  var user = FirebaseAuth.instance.currentUser; // 获取当前用户

  @override
  void initState() {
    super.initState(); // 调用父类的initState
    // 延迟两秒后检查用户登录状态
    Future.delayed(Duration(seconds: 2), () {
      if (user == null) {
        // 如果用户未登录
        openLogin(); // 打开登录界面
      } else {
        // 如果用户已登录
        openDashboard(); // 打开仪表板界面
      }
    });
  }

  // 打开仪表板界面的方法
  void openDashboard() {
    Provider.of<UserProvider>(context, listen: false)
        .getUserDetails(); // 获取用户详情
    // 导航到仪表板界面，并替换当前页面
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage(); //HomePage/DashboardScreen
    }));
  }

  // 打开登录界面的方法
  void openLogin() {
    // 导航到登录界面，并替换当前页面
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // 构建UI，显示中心的Logo图像
    return Scaffold(
        body: Center(
            child: SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("images/logo.png"))));
  }
}
