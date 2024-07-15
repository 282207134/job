import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 包

import '../../enumerations.dart'; // 导入 enumerations.dart 文件
import '../../widgets/calendar_configs.dart'; // 导入 calendar_configs.dart 文件
import '../../widgets/calendar_views.dart'; // 导入 calendar_views.dart 文件

class WebHomePage extends StatefulWidget {
  WebHomePage({
    this.selectedView = CalendarView.month, // 默认选中月视图
  });

  final CalendarView selectedView; // 选中的日历视图

  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  late var _selectedView = widget.selectedView; // 初始化选中的视图为传入的值

  void _setView(CalendarView view) {
    if (view != _selectedView && mounted) {
      setState(() {
        _selectedView = view; // 更新选中的视图
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: CalendarConfig(
              onViewChange: _setView, // 当视图改变时调用 _setView 方法
              currentView: _selectedView, // 当前选中的视图
            ),
          ),
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height), // 设置媒体查询的数据
              ),
              child: CalendarViews(
                key: ValueKey(MediaQuery.of(context).size.width), // 使用屏幕宽度作为键
                view: _selectedView, // 当前选中的视图
              ),
            ),
          ),
        ],
      ),
    );
  }
}
