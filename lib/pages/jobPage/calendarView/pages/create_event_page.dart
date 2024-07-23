import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包
import 'package:flutter/material.dart'; // 导入 Flutter Material 包
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包

import '../app_colors.dart'; // 导入自定义颜色配置文件
import '../extension.dart'; // 导入扩展方法文件
import '../widgets/add_event_form.dart'; // 导入添加事件表单文件

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.event});

  final CalendarEventData? event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
        title: Text(
          event == null ? "Create New Event" : "Update Event",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: AddOrEditEventForm(
            onEventAdd: (newEvent) async {
              final controller = CalendarControllerProvider.of(context).controller;

              if (event != null) {
                // 如果是编辑现有事件，更新 Firestore 和本地控制器中的事件
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(event!.id)
                    .update(newEvent.toMap());
                controller.update(event!, newEvent);
              } else {
                // 如果是添加新事件，创建新文档并更新本地控制器中的事件
                DocumentReference docRef = await FirebaseFirestore.instance
                    .collection('events')
                    .add(newEvent.toMap());
                newEvent = newEvent.copyWith(id: docRef.id);
                if (!controller.allEvents.any((e) => e.id == newEvent.id)) {
                  controller.add(newEvent);
                }
              }

              context.pop(true);
            },
            event: event,
          ),
        ),
      ),
    );
  }
}
