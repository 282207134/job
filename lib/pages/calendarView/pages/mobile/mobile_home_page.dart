import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import '../../extension.dart'; // 导入 extension.dart 文件
import '../day_view_page.dart'; // 导入 day_view_page.dart 文件
import '../month_view_page.dart'; // 导入 month_view_page.dart 文件
import '../week_view_page.dart'; // 导入 week_view_page.dart 文件

class MobileHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Calendar Page"), // 应用栏标题
        centerTitle: true, // 标题居中
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 列的主轴大小为最小
          children: [
            ElevatedButton(
              onPressed: () => context.pushRoute(MonthViewPageDemo()), // 按钮点击跳转到月视图页面
              child: Text("Month View"), // 按钮文字
            ),
            SizedBox(
              height: 20, // 按钮与下一个按钮之间的间隔
            ),
            ElevatedButton(
              onPressed: () => context.pushRoute(DayViewPageDemo()), // 按钮点击跳转到日视图页面
              child: Text("Day View"), // 按钮文字
            ),
            SizedBox(
              height: 20, // 按钮与下一个按钮之间的间隔
            ),
            ElevatedButton(
              onPressed: () => context.pushRoute(WeekViewDemo()), // 按钮点击跳转到周视图页面
              child: Text("Week View"), // 按钮文字
            ),
          ],
        ),
      ),
    );
  }
}
