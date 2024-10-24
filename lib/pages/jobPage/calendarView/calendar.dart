import 'dart:ui'; // 导入 Dart 的 UI 库

import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 组件库
import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 库，用于与 Firebase Firestore 进行数据交互
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入日历视图组件
import 'pages/CalendarPage.dart'; // 导入日历页面

// 获取当前时间
DateTime get _now => DateTime.now();

// 创建一个名为 calendar 的无状态组件
class calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // 返回一个脚手架组件，提供基本的视觉结构
      appBar: AppBar( // 应用栏组件
        centerTitle: true, // 标题居中
        title: Text("カレンダー"), // 设置应用栏标题
        leading: IconButton( // 返回按钮
          icon: Icon(Icons.arrow_back), // 返回图标
          onPressed: () { // 点击返回按钮时的回调
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>( // 使用 StreamBuilder 监听 Firestore 数据流
        stream: FirebaseFirestore.instance.collection('events').snapshots(), // 监听 'events' 集合的快照
        builder: (context, snapshot) { // 构建方法，根据快照状态更新 UI
          if (snapshot.connectionState == ConnectionState.waiting) { // 如果连接状态是等待中
            return Center(child: CircularProgressIndicator()); // 显示加载指示器
          }

          if (snapshot.hasError) { // 如果发生错误
            return Center(child: Text('Error: ${snapshot.error}')); // 显示错误信息
          }

          // 将快照中的文档数据转换为 CalendarEventData 列表
          List<CalendarEventData> events = snapshot.data!.docs.map((doc) {
            // 日期时间转换函数
            DateTime? getDateTime(dynamic value) {
              if (value is Timestamp) { // 如果值是 Timestamp 类型
                return value.toDate(); // 转换为 DateTime
              } else if (value is String) { // 如果值是字符串
                return DateTime.parse(value); // 解析为 DateTime
              }
              return null; // 否则返回 null
            }

            // 颜色转换函数
            Color getColor(dynamic value) {
              if (value is int) { // 如果值是整数
                return Color(value); // 根据整数值创建颜色
              } else if (value is String) { // 如果值是字符串
                return Color(int.parse(value)); // 解析字符串为整数后创建颜色
              }
              return Colors.black; // 默认返回黑色
            }

            // 解析文档数据并创建 CalendarEventData 对象
            return CalendarEventData(
              id: doc.id, // 文档 ID
              title: doc['title'], // 获取标题
              description: doc['description'], // 获取描述
              date: getDateTime(doc['date'])!, // 获取日期（确保不为 null）
              startTime: getDateTime(doc['startTime']), // 获取开始时间
              endTime: getDateTime(doc['endTime']), // 获取结束时间
              color: getColor(doc['color']), // 获取颜色
              endDate: getDateTime(doc['endDate']),  // 确保结束日期被解析
            );
          }).toList(); // 转换为列表

          // 传递事件数据给日历控制器
          return CalendarControllerProvider(
            controller: EventController()..addAll(events), // 创建事件控制器并添加所有事件
            child: MaterialApp( // 返回 Material 应用
              // title: 'Flutter Calendar Page Demo', // 应用标题
              debugShowCheckedModeBanner: false, // 不显示调试模式横幅
              theme: ThemeData.light(), // 应用主题
              scrollBehavior: ScrollBehavior().copyWith( // 自定义滚动行为
                dragDevices: { // 支持的拖动设备
                  PointerDeviceKind.trackpad, // 触控板
                  PointerDeviceKind.mouse, // 鼠标
                  PointerDeviceKind.touch, // 触摸屏
                },
              ),
              home: CalendarPage(), // 设置首页为日历页面
            ),
          );
        },
      ),
    );
  }
}
