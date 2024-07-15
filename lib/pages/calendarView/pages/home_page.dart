import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../widgets/responsive_widget.dart'; // 导入 responsive_widget.dart 文件
import 'mobile/mobile_home_page.dart'; // 导入 mobile_home_page.dart 文件
import 'web/web_home_page.dart'; // 导入 web_home_page.dart 文件

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // 构造函数

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobileWidget: MobileHomePage(), // 移动端小部件
      webWidget: WebHomePage(), // Web端小部件
    );
  }
}
