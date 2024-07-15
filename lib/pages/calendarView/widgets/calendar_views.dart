import 'dart:math'; // 导入数学库

import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../app_colors.dart'; // 导入应用程序颜色
import '../enumerations.dart'; // 导入枚举
import 'day_view_widget.dart'; // 导入日视图部件
import 'month_view_widget.dart'; // 导入月视图部件
import 'week_view_widget.dart'; // 导入周视图部件

class CalendarViews extends StatelessWidget { // 定义一个名为CalendarViews的无状态小部件
  final CalendarView view; // 定义当前视图

  const CalendarViews({super.key, this.view = CalendarView.month}); // 构造函数，初始化当前视图为月视图

  final _breakPoint = 490.0; // 定义断点宽度

  @override
  Widget build(BuildContext context) { // 构建部件的UI
    final availableWidth = MediaQuery.of(context).size.width; // 获取可用宽度
    final width = min(_breakPoint, availableWidth); // 计算实际宽度

    return Container( // 返回一个容器部件
      height: double.infinity, // 设置高度为无限大
      width: double.infinity, // 设置宽度为无限大
      color: AppColors.grey, // 设置背景颜色为灰色
      child: Center( // 居中子部件
        child: view == CalendarView.month // 判断当前视图
            ? MonthViewWidget( // 月视图
          width: width,
        )
            : view == CalendarView.day // 日视图
            ? DayViewWidget(
          width: width,
        )
            : WeekViewWidget( // 周视图
          width: width,
        ),
      ),
    );
  }
}
