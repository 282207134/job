import 'dart:ui'; // 导入 dart:ui 包
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'pages/CalendarPage.dart'; // 导入 pages/CalendarPage.dart 文件

DateTime get _now => DateTime.now(); // 获取当前日期时间的快捷方法

class calendar extends StatelessWidget {
  // 这是应用程序的根小部件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Calendar Page"), // 应用栏标题

        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 设置返回图标
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
      body: CalendarControllerProvider(
        controller: EventController()..addAll(_events), // 创建一个包含事件的控制器
        child: MaterialApp(
          title: 'Flutter Calendar Page Demo',
          // 设置应用程序标题

          debugShowCheckedModeBanner: false,
          // 隐藏调试模式横幅
          theme: ThemeData.light(),
          // 使用浅色主题
          scrollBehavior: ScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.trackpad,
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            }, // 允许不同类型的指针设备进行滚动
          ),
          home: CalendarPage(), // 设置主页为 CalendarPage 小部件
        ),
      ),
    );
  }
}

//示例日程
List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,
    // 当前日期
    title: "Project meeting",
    // 事件标题
    description: "Today is project meeting.",
    // 事件描述
    startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
    // 事件开始时间
    endTime: DateTime(_now.year, _now.month, _now.day, 22), // 事件结束时间
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 1)),
    // 当前日期加一天
    startTime: DateTime(_now.year, _now.month, _now.day, 18),
    // 事件开始时间
    endTime: DateTime(_now.year, _now.month, _now.day, 19),
    // 事件结束时间
    title: "Wedding anniversary",
    // 事件标题
    description: "Attend uncle's wedding anniversary.", // 事件描述
  ),
  CalendarEventData(
    date: _now,
    // 当前日期
    startTime: DateTime(_now.year, _now.month, _now.day, 14),
    // 事件开始时间
    endTime: DateTime(_now.year, _now.month, _now.day, 17),
    // 事件结束时间
    title: "Football Tournament",
    // 事件标题
    description: "Go to football tournament.", // 事件描述
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    // 当前日期加三天
    startTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    // 事件开始时间
    endTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    // 事件结束时间
    title: "Sprint Meeting.",
    // 事件标题
    description: "Last day of project submission for last year.", // 事件描述
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    // 当前日期减两天
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        14),
    // 事件开始时间
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        16),
    // 事件结束时间
    title: "Team Meeting",
    // 事件标题
    description: "Team Meeting", // 事件描述
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    // 当前日期减两天
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        10),
    // 事件开始时间
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        12),
    // 事件结束时间
    title: "Chemistry Viva",
    // 事件标题
    description: "Today is Joe's birthday.", // 事件描述
  ),
];
