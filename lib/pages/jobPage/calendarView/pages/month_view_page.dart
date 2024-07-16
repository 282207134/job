import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../enumerations.dart'; // 导入 enumerations.dart 文件
import '../extension.dart'; // 导入 extension.dart 文件
import '../widgets/month_view_widget.dart'; // 导入 month_view_widget.dart 文件
import '../widgets/responsive_widget.dart'; // 导入 responsive_widget.dart 文件
import 'create_event_page.dart'; // 导入 create_event_page.dart 文件
import 'web/web_home_page.dart'; // 导入 web_home_page.dart 文件

class MonthViewPageDemo extends StatefulWidget {
  const MonthViewPageDemo({
    super.key,
  }); // 构造函数

  @override
  _MonthViewPageDemoState createState() => _MonthViewPageDemoState(); // 创建状态
}

class _MonthViewPageDemoState extends State<MonthViewPageDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWidget(
        webWidget: WebHomePage(
          selectedView: CalendarView.month, // 设置选中的视图为月视图
        ),
        mobileWidget: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), // 添加图标
            elevation: 8, // 阴影高度
            onPressed: () => context.pushRoute(CreateEventPage()), // 按钮点击跳转到创建事件页面
          ),
          body: MonthViewWidget(), // 月视图小部件
        ),
      ),
    );
  }
}
