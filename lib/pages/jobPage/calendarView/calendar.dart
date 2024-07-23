import 'dart:ui'; // 导入 dart:ui 包
import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'pages/CalendarPage.dart'; // 导入 pages/CalendarPage.dart 文件

DateTime get _now => DateTime.now(); // 获取当前日期时间的快捷方法

class calendar extends StatelessWidget {
  // Calendar 类是应用程序的根小部件

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
      body: StreamBuilder<QuerySnapshot>(
        // 使用 StreamBuilder 来监听 Firestore 数据库中 'events' 集合的变化
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果连接状态是等待，则显示加载指示器
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 如果有错误，则显示错误信息
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<CalendarEventData> events = snapshot.data!.docs.map((doc) {
            // 将 Firestore 文档映射到 CalendarEventData 对象列表

            // 帮助函数，用于处理 Timestamp 转换
            DateTime? getDateTime(dynamic value) {
              if (value is Timestamp) {
                return value.toDate(); // 如果值是 Timestamp，则转换为 DateTime
              } else if (value is String) {
                return DateTime.parse(value); // 如果值是 String，则解析为 DateTime
              }
              return null; // 否则返回 null
            }

            // 帮助函数，用于处理颜色转换
            Color getColor(dynamic value) {
              if (value is int) {
                return Color(value); // 如果值是 int，则转换为 Color
              } else if (value is String) {
                return Color(int.parse(value)); // 如果值是 String，则解析为 int 后转换为 Color
              }
              return Colors.black; // 如果解析失败，则返回默认颜色黑色
            }

            // 返回 CalendarEventData 对象
            return CalendarEventData(
              id: doc.id, // 事件 ID
              title: doc['title'], // 事件标题
              description: doc['description'], // 事件描述
              date: getDateTime(doc['date'])!, // 事件日期
              startTime: getDateTime(doc['startTime']), // 事件开始时间
              endTime: getDateTime(doc['endTime']), // 事件结束时间
              color: getColor(doc['color']), // 事件颜色
            );
          }).toList();

          return CalendarControllerProvider(
            controller: EventController()..addAll(events), // 创建一个包含事件的控制器并添加所有事件
            child: MaterialApp(
              title: 'Flutter Calendar Page Demo', // 设置应用程序标题
              debugShowCheckedModeBanner: false, // 隐藏调试模式横幅
              theme: ThemeData.light(), // 使用浅色主题
              scrollBehavior: ScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                }, // 允许不同类型的指针设备进行滚动
              ),
              home: CalendarPage(), // 设置主页为 CalendarPage 小部件
            ),
          );
        },
      ),
    );
  }
}
