import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // 导入闪屏动画库
import 'package:flutter/material.dart'; // 导入 Flutter Material 组件库
import 'package:kantankanri/app/home_page.dart'; // 导入主页
import '../pages/jobPage/job_page.dart'; // 导入工作页面
import '../pages/jobPage/staff_page.dart'; // 导入员工页面
import 'OnBoardingPageState.dart'; // 导入引导页

class SplashScreen extends StatelessWidget { // 闪屏类(无状态组件)
  @override // 重写父类方法
  Widget build(BuildContext context) { // 构建方法
    return MaterialApp( // 返回 Material 应用
      debugShowCheckedModeBanner: false, // 隐藏调试横幅
      home: FlutterSplashScreen.fadeIn( // 淡入式闪屏
        backgroundColor: Colors.cyan, // 背景颜色:青色
        duration: Duration(seconds: 5), // 显示持续时间:5秒
        animationDuration: Duration(seconds: 10), // 动画持续时间:10秒
        onInit: () { // 初始化回调
          debugPrint("On Init"); // 打印日志
        },
        onEnd: () { // 结束回调
          debugPrint("On End"); // 打印日志
        },
        childWidget: SizedBox( // 子组件:固定尺寸容器
          height: double.infinity, // 高度:无限
          width: double.infinity, // 宽度:无限
          child: Image.asset("assets/0.jpg"), // 图片资源
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"), // 动画结束回调
        nextScreen: OnBoardingPage(), // 下一个屏幕:引导页
      ),
      routes: { // 路由表
        '/login': (BuildContext context) => SplashScreen(), // 登录路由
        '/home': (BuildContext context) => HomePage(), // 主页路由
        '/job': (BuildContext context) => JobPage(), // 工作页面路由
        '/staff': (BuildContext context) => StaffPage(), // 员工页面路由
      },
    );
  }
}
