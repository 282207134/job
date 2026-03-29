import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb; // プラットフォーム判定
import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../constants.dart'; // 导入常量

/// 真機 iOS / Android では常に [mobileWidget] を使い、横屏・大屏でも Web 用レイアウトに切り替わらないようにする。
/// Web およびデスクトップ埋め込みでは従来どおり [breakPoint] で mobile / web を切り替える。
bool _useMobileLayoutForContext(
  BuildContext context,
  double breakPoint,
  double? overrideWidth,
) {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android)) {
    return true;
  }
  final width = overrideWidth ?? MediaQuery.sizeOf(context).width;
  return width < breakPoint;
}

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
    if (_useMobileLayoutForContext(context, breakPoint, width)) {
      return mobileWidget;
    }
    return webWidget;
  }
}
