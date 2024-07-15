import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../enumerations.dart'; // 导入 enumerations.dart 文件
import '../extension.dart'; // 导入 extension.dart 文件
import '../widgets/day_view_widget.dart'; // 导入 day_view_widget.dart 文件
import '../widgets/responsive_widget.dart'; // 导入 responsive_widget.dart 文件
import 'create_event_page.dart'; // 导入 create_event_page.dart 文件
import 'web/web_home_page.dart'; // 导入 web_home_page.dart 文件

class DayViewPageDemo extends StatefulWidget {
  const DayViewPageDemo({super.key}); // 构造函数

  @override
  _DayViewPageDemoState createState() => _DayViewPageDemoState(); // 创建状态
}

class _DayViewPageDemoState extends State<DayViewPageDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      centerTitle: true,
      title: Text("day View"), // 应用栏标题
      leading: IconButton(
        icon: Icon(Icons.arrow_back), // 设置返回图标
        onPressed: () {
          Navigator.pop(context); // 返回上一个页面
        },
      ),
    ),
      body: ResponsiveWidget(
        webWidget: WebHomePage(
          selectedView: CalendarView.day, // 设置选中的视图为日视图
        ),
        mobileWidget: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), // 添加图标
            elevation: 8, // 阴影高度
            onPressed: () => context.pushRoute(CreateEventPage()), // 按钮点击跳转到创建事件页面
          ),
          body: DayViewWidget(), // 日视图小部件
        ),
      ),
    );
  }
}
