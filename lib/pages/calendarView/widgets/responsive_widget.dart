import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../constants.dart'; // 导入常量

class ResponsiveWidget extends StatelessWidget {
  final double? width; // 定义宽度属性
  final double breakPoint; // 定义断点，用于区分移动端和Web端
  final Widget webWidget; // Web端显示的部件
  final Widget mobileWidget; // 移动端显示的部件

  const ResponsiveWidget({
    super.key,
    this.width,
    this.breakPoint = BreakPoints.web, // 设置默认断点为Web端断点
    required this.webWidget, // 初始化Web端部件
    required this.mobileWidget, // 初始化移动端部件
  });

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? MediaQuery.of(context).size.width; // 获取当前设备的宽度

    if (width < breakPoint) { // 如果宽度小于断点
      return mobileWidget; // 返回移动端部件
    } else { // 如果宽度大于或等于断点
      return webWidget; // 返回Web端部件
    }
  }
}
