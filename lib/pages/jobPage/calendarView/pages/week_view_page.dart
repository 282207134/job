import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../enumerations.dart'; // 导入 enumerations.dart 文件
import '../extension.dart'; // 导入 extension.dart 文件
import '../widgets/responsive_widget.dart'; // 导入 responsive_widget.dart 文件
import '../widgets/week_view_widget.dart'; // 导入 week_view_widget.dart 文件
import 'create_event_page.dart'; // 导入 create_event_page.dart 文件
import 'web/web_home_page.dart'; // 导入 web_home_page.dart 文件

class WeekViewDemo extends StatefulWidget {
  const WeekViewDemo({super.key}); // 构造函数

  @override
  _WeekViewDemoState createState() => _WeekViewDemoState(); // 创建状态
}

class _WeekViewDemoState extends State<WeekViewDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWidget(
        webWidget: WebHomePage(
          selectedView: CalendarView.week, // 设置选中的视图为周视图
        ),
        mobileWidget: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), // 添加图标
            elevation: 8, // 阴影高度
            onPressed: () => context.pushRoute(CreateEventPage()), // 按钮点击跳转到创建事件页面
          ),
          body: WeekViewWidget(), // 周视图小部件
        ),
      ),
    );
  }
}
