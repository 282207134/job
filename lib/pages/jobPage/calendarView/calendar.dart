import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job/pages/jobPage/calendarView/calendar_view.dart';
import 'pages/CalendarPage.dart';

DateTime get _now => DateTime.now();

class calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Calendar Page"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<CalendarEventData> events = snapshot.data!.docs.map((doc) {
            // 日期时间转换函数
            DateTime? getDateTime(dynamic value) {
              if (value is Timestamp) {
                return value.toDate();
              } else if (value is String) {
                return DateTime.parse(value);
              }
              return null;
            }

            // 颜色转换函数
            Color getColor(dynamic value) {
              if (value is int) {
                return Color(value);
              } else if (value is String) {
                return Color(int.parse(value));
              }
              return Colors.black;
            }

            // 解析并创建 CalendarEventData 对象
            return CalendarEventData(
              id: doc.id,
              title: doc['title'],
              description: doc['description'],
              date: getDateTime(doc['date'])!,
              startTime: getDateTime(doc['startTime']),
              endTime: getDateTime(doc['endTime']),
              color: getColor(doc['color']),
              endDate: getDateTime(doc['endDate']),  // 确保结束日期被解析
            );
          }).toList();

          // 传递事件数据给日历控件
          return CalendarControllerProvider(
            controller: EventController()..addAll(events),
            child: MaterialApp(
              title: 'Flutter Calendar Page Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              scrollBehavior: ScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              home: CalendarPage(),
            ),
          );
        },
      ),
    );
  }
}
