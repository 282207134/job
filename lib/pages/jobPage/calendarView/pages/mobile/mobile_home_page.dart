import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../../extension.dart'; // 导入 extension.dart 文件
import '../../widgets/day_view_widget.dart';
import '../../widgets/month_view_widget.dart';
import '../../widgets/week_view_widget.dart';
import '../create_event_page.dart';
import '../day_view_page.dart'; // 导入 day_view_page.dart 文件
import '../month_view_page.dart'; // 导入 month_view_page.dart 文件
import '../week_view_page.dart'; // 导入 week_view_page.dart 文件

class MobileHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), // 添加图标
          elevation: 8, // 阴影高度
          onPressed: () => context.pushRoute(CreateEventPage()), // 按钮点击跳转到创建事件页面
        ),
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0), // 设置TabBar高度
            child: TabBar(
              indicatorSize:TabBarIndicatorSize.tab,
              labelColor: Colors.red, //选择图标颜色
              unselectedLabelColor: Colors.green, //默认图标颜色
              tabs: [
                Tab(text: "月"),
                Tab(text: "週"),
                Tab(text: "日"),
              ],
            ),
          ),
          centerTitle: true, // 标题居中
        ),
        body: TabBarView(
          children: [
            MonthViewWidget(),
            WeekViewWidget(),
            DayViewWidget()
          ],
        ),
      ),
    );
  }
}
