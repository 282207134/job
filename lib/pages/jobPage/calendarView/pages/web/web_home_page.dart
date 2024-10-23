import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 包，提供 Material Design 组件

import '../../enumerations.dart'; // 导入 enumerations.dart 文件，用于列举类型
import '../../widgets/calendar_configs.dart'; // 导入 calendar_configs.dart 文件，提供日历配置组件
import '../../widgets/calendar_views.dart'; // 导入 calendar_views.dart 文件，提供不同的日历视图组件

// 创建 WebHomePage 类，继承 StatefulWidget
class WebHomePage extends StatefulWidget {
  WebHomePage({
    this.selectedView = CalendarView.month, // 默认选中月视图
  });

  final CalendarView selectedView; // 选中的日历视图

  @override
  _WebHomePageState createState() => _WebHomePageState(); // 创建状态
}

// 创建 WebHomePage 的状态类
class _WebHomePageState extends State<WebHomePage> {
  late var _selectedView = widget.selectedView; // 初始化选中的视图为传入的值

  // 设置视图的方法
  void _setView(CalendarView view) {
    if (view != _selectedView && mounted) { // 如果新视图与当前视图不同且组件仍在树中
      setState(() {
        _selectedView = view; // 更新选中的视图
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 返回一个脚手架组件
      body: Row( // 使用 Row 组件布局
        children: [
          Expanded( // 扩展组件，使其占用可用空间
            child: CalendarConfig(
              onViewChange: _setView, // 当视图改变时调用 _setView 方法
              currentView: _selectedView, // 当前选中的视图
            ),
          ),
          Expanded( // 再次使用扩展组件
            child: MediaQuery( // 使用 MediaQuery 组件来响应式设计
              data: MediaQuery.of(context).copyWith( // 复制当前媒体查询的数据并进行修改
                size: Size(MediaQuery.of(context).size.width / 2, // 设置新宽度为一半
                    MediaQuery.of(context).size.height), // 保持高度不变
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
