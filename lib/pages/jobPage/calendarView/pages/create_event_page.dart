import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包，用于与 Firebase Firestore 实现数据交互
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 包，提供 Material Design 组件
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包，包含日历视图相关内容
import '../app_colors.dart';
import '../widgets/add_event_form.dart'; // 导入自定义颜色配置文件

// 创建事件页面类，继承 StatelessWidget
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.event}); // 构造函数，接受一个可选的事件参数

  final CalendarEventData? event; // 可选的事件数据

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    return Scaffold( // 返回一个脚手架组件，提供基本的视觉结构
      appBar: AppBar( // 应用栏组件
        elevation: 0, // 设置应用栏的阴影值为 0
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 设置应用栏的背景颜色
        centerTitle: false, // 标题不居中
        leading: IconButton( // 应用栏的返回按钮
          onPressed: () {
            Navigator.of(context).pop(); // 使用 Navigator.pop 返回上一个页面
          },
          icon: Icon(
            Icons.arrow_back, // 返回图标
            color: AppColors.black, // 图标颜色
          ),
        ),
        title: Text( // 设置应用栏的标题
          event == null ? "新規イベント作成" : "イベント更新", // 根据是否有事件来决定标题
          style: TextStyle(
            color: AppColors.black, // 设置标题文本的颜色
            fontSize: 20.0, // 设置字体大小
            fontWeight: FontWeight.bold, // 设置字体为加粗
          ),
        ),
      ),
      body: SingleChildScrollView( // 包裹在可滚动视图中，允许内容滚动
        physics: ClampingScrollPhysics(), // 设置滚动物理特性，防止滞后
        child: Padding( // 填充组件，设置内边距
          padding: EdgeInsets.all(20.0), // 设置所有方向的内边距为 20
          child: AddOrEditEventForm( // 添加或编辑事件表单组件
            onEventAdd: (newEvent) async { // 当添加事件时的回调函数
              final controller = CalendarControllerProvider.of(context).controller; // 获取日历控制器

              try {
                if (event != null) { // 如果存在事件
                  // 如果是编辑现有事件，更新 Firestore 和本地控制器中的事件
                  await FirebaseFirestore.instance
                      .collection('events') // 指定 Firestore 集合
                      .doc(event!.id) // 选择要更新的文档
                      .update(newEvent.toMap()); // 更新文档数据
                  controller.update(event!, newEvent); // 更新本地控制器中的事件
                } else {
                  // 如果是添加新事件，创建新文档并更新本地控制器中的事件
                  DocumentReference docRef = await FirebaseFirestore.instance
                      .collection('events') // 指定 Firestore 集合
                      .add(newEvent.toMap()); // 添加新文档
                  newEvent = newEvent.copyWith(id: docRef.id); // 将新文档的 ID 赋给新事件
                  if (!controller.allEvents.any((e) => e.id == newEvent.id)) { // 检查本地控制器中是否已存在该事件
                    controller.add(newEvent); // 添加新事件到本地控制器
                  }
                }

                // 成功添加事件后显示成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Event added successfully")),
                );

                // 刷新日历视图以显示新添加的事件
                controller.notifyListeners();

              } catch (e) {
                // 处理任何错误并展示错误信息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add event: $e")),
                );
              }
            },
            event: event, // 将事件参数传递给表单
          ),
        ),
      ),
    );
  }
}
