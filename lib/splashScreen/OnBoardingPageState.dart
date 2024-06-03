//更新内容滚动提示界面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../screens/login_screen.dart';

class OnBoardingPage extends StatefulWidget {
  // 引导页类
  const OnBoardingPage({Key? key}) : super(key: key); // 构造函数

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState(); // 创建状态
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  // 引导页状态类
  final introKey = GlobalKey<IntroductionScreenState>(); // 引导屏幕的全局键

  void _onIntroEnd(BuildContext context) {
    // 引导结束处理函数
    Navigator.of(context).pushReplacement(
      // 替换导航路由
      MaterialPageRoute(builder: (_) => LoginScreen()), // 跳转到主页
    );
  }

  Widget _buildFullscreenImage(int index) {
    // 构建全屏图像
    return Image.asset(
      // 图像小部件
      'assets/$index.jpg', // 图像路径
      fit: BoxFit.cover, // 图像填充方式
      height: double.infinity, // 高度充满屏幕
      width: double.infinity, // 宽度充满屏幕
      alignment: Alignment.center, // 图像居中对齐
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    // 构建图像
    return Image.asset('assets/$assetName', width: width); // 图像小部件
  }

  @override
  Widget build(BuildContext context) {
    // 构建函数
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.white); // 正文样式

    var pageDecoration = PageDecoration(
      // 页面装饰
      titleTextStyle: TextStyle(
          // 标题文本样式
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: Colors.white),
      bodyTextStyle: bodyStyle,
      // 正文文本样式
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      // 正文内边距
      pageColor: null,
      // 页面颜色为null
      boxDecoration: BoxDecoration(
        // 盒子装饰
        color: Colors.black.withOpacity(0.5), // 背景颜色为半透明黑色
        borderRadius: BorderRadius.circular(10), // 圆角
      ),
      imagePadding: EdgeInsets.zero, // 图像内边距
    );

    return IntroductionScreen(
      // 引导屏幕小部件
      key: introKey,
      // 全局键
      globalBackgroundColor: Colors.white,
      // 全局背景颜色
      allowImplicitScrolling: true,
      // 允许隐式滚动
      autoScrollDuration: 5000,
      // 自动滚动持续时间
      infiniteAutoScroll: true,
      // 无限自动滚动
      pages: [
        // 页面列表
        PageViewModel(
          // 页面视图模型
          title: "便利性", // 标题
          body: "気軽いスタッフを管理できます.", // 正文
          image: _buildFullscreenImage(1), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
        PageViewModel(
          // 页面视图模型
          title: "安全性", // 标题
          body: "個人情報を漏洩を防ぐ.", // 正文
          image: _buildFullscreenImage(2), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
        PageViewModel(
          // 页面视图模型
          title: "可用性", // 标题
          body: "いつ、どこでも使います.", // 正文
          image: _buildFullscreenImage(3), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      // 完成时的回调函数
      done: const Text('初めて', // 完成按钮文本
          style:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.cyanAccent)),
      showNextButton: true,
      // 显示下一个按钮
      next: const Icon(
        // 下一个按钮
        Icons.arrow_forward,
        color: Colors.cyanAccent, // 图标颜色
      ),
      showSkipButton: true,
      // 显示跳过按钮
      skip: const Text(
        // 跳过按钮文本
        'スキップ',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.cyanAccent),
      ),
      onSkip: () => _onIntroEnd(context),
      // 跳过时的回调函数
      curve: Curves.fastLinearToSlowEaseIn,
      // 动画曲线
      controlsMargin: const EdgeInsets.all(16),
      // 控制按钮外边距
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      // 控制按钮内边距
      dotsDecorator: const DotsDecorator(
        // 点装饰
        size: Size(10.0, 10.0), // 大小
        color: Colors.white, // 颜色
        activeSize: Size(22.0, 10.0), // 激活大小
        activeShape: RoundedRectangleBorder(
          // 激活形状
          borderRadius: BorderRadius.all(Radius.circular(25.0)), // 圆角
        ),
      ),
    );
  }
}
