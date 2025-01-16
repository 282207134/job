import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 包
import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 Flutter 的材料设计包

import '../app_colors.dart'; // 导入应用程序颜色
import '../enumerations.dart'; // 导入枚举
import '../extension.dart'; // 导入扩展
import 'add_event_form.dart'; // 导入添加事件表单

class CalendarConfig extends StatelessWidget { // 定义一个名为 CalendarConfig 的无状态小部件
  final void Function(CalendarView view) onViewChange; // 定义一个回调函数用于视图更改
  final CalendarView currentView; // 定义当前视图
  final CalendarEventData? event; // 新增一个可选的 event 参数

  const CalendarConfig({
    super.key, // 传递键值给父类
    required this.onViewChange, // 初始化视图更改回调
    this.currentView = CalendarView.month, // 设置默认视图为月视图
    this.event, // 新增 event 参数的初始化
  });

  @override
  Widget build(BuildContext context) { // 构建部件的 UI
    return Column( // 返回一个列部件
      mainAxisSize: MainAxisSize.min, // 设置主轴尺寸为最小
      crossAxisAlignment: CrossAxisAlignment.start, // 设置交叉轴对齐方式为左对齐
      children: [
        Padding( // 添加填充
          padding: EdgeInsets.only(left: 20, top: 20), // 设置填充值
          child: Text(
            "カレンダーページ", // 显示文本
            style: TextStyle(
              color: AppColors.black, // 设置文字颜色
              fontSize: 30, // 设置字体大小
            ),
          ),
        ),
        Divider(
          color: AppColors.lightNavyBlue, // 设置分割线颜色
        ),
        Expanded( // 扩展以填充剩余空间
          child: SingleChildScrollView( // 单子项滚动视图
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 设置填充值
            child: Column( // 嵌套列部件
              mainAxisSize: MainAxisSize.min, // 设置主轴尺寸为最小
              crossAxisAlignment: CrossAxisAlignment.start, // 设置交叉轴对齐方式为左对齐
              children: [
                Text(
                  "Active View:", // 显示文本
                  style: TextStyle(
                    fontSize: 20.0, // 设置字体大小
                    color: AppColors.black, // 设置文字颜色
                  ),
                ),
                Wrap( // 使用 Wrap 包裹视图选项
                  children: List.generate( // 生成视图选项列表
                    CalendarView.values.length, // 根据视图选项数量生成
                        (index) {
                      final view = CalendarView.values[index]; // 获取当前视图
                      return GestureDetector( // 手势检测器
                        onTap: () => onViewChange(view), // 绑定点击事件
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 40,
                          ), // 设置内边距
                          margin: EdgeInsets.only(
                            right: 20,
                            top: 20,
                          ), // 设置外边距
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7), // 设置圆角
                            color: view == currentView // 根据当前视图设置颜色
                                ? AppColors.navyBlue
                                : AppColors.bluishGrey,
                          ),
                          child: Text(
                            view.name.capitalized, // 显示视图名称
                            style: TextStyle(
                              color: view == currentView // 根据当前视图设置文字颜色
                                  ? AppColors.white
                                  : AppColors.black,
                              fontSize: 17, // 设置字体大小
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 40, // 设置高度
                ),
                Text(
                  "Add Event: ", // 显示文本
                  style: TextStyle(
                    fontSize: 20.0, // 设置字体大小
                    color: AppColors.black, // 设置文字颜色
                  ),
                ),
                SizedBox(
                  height: 20, // 设置高度
                ),
                AddOrEditEventForm( // 添加或编辑事件表单组件
                  onEventAdd: (newEvent) async { // 当添加事件时的回调函数
                    final controller = CalendarControllerProvider.of(context).controller; // 获取日历控制器

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

                    context.pop(true); // 返回上一个页面，并传递 true 作为参数
                  },
                  event: event, // 将事件参数传递给表单
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
