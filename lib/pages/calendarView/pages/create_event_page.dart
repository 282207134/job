import 'package:job/pages/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import '../app_colors.dart'; // 导入 app_colors.dart 文件
import '../extension.dart'; // 导入 extension.dart 文件
import '../widgets/add_event_form.dart'; // 导入 add_event_form.dart 文件
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.event}); // 构造函数，接收一个可选的事件参数

  final CalendarEventData? event; // 可选的日历事件数据

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 无阴影
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 背景颜色与 scaffold 相同
        centerTitle: false, // 标题不居中
        leading: IconButton(
          onPressed: context.pop, // 返回上一级页面
          icon: Icon(
            Icons.arrow_back, // 返回箭头图标
            color: AppColors.black, // 图标颜色为黑色
          ),
        ),
        title: Text(
          event == null ? "Create New Event" : "Update Event", // 根据是否有事件显示不同的标题
          style: TextStyle(
            color: AppColors.black, // 文字颜色为黑色
            fontSize: 20.0, // 字体大小为 20.0
            fontWeight: FontWeight.bold, // 字体加粗
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(), // 禁止滚动过度
        child: Padding(
          padding: EdgeInsets.all(20.0), // 内边距为 20.0
          child: AddOrEditEventForm(
            onEventAdd: (newEvent) {
              if (this.event != null) {
                CalendarControllerProvider.of(context)
                    .controller
                    .update(this.event!, newEvent); // 更新事件
              } else {
                CalendarControllerProvider.of(context).controller.add(newEvent); // 添加新事件
              }

              context.pop(true); // 返回并传递 true
            },
            event: event, // 传递事件参数
          ),
        ),
      ),
    );
  }
}
