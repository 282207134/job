import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包

import '../extension.dart'; // 导入 extension.dart 文件
import 'create_event_page.dart'; // 导入 create_event_page.dart 文件

class DetailsPage extends StatelessWidget {
  final CalendarEventData event; // 事件数据

  const DetailsPage({super.key, required this.event}); // 构造函数，接收一个必需的事件参数

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: event.color, // 应用栏背景色为事件颜色
        elevation: 0, // 无阴影
        centerTitle: false, // 标题不居中
        title: Text(
          event.title, // 事件标题
          style: TextStyle(
            color: event.color.accentColor, // 文字颜色为事件颜色的强调色
            fontSize: 20.0, // 字体大小为 20.0
            fontWeight: FontWeight.bold, // 字体加粗
          ),
        ),
        leading: IconButton(
          onPressed: context.pop, // 返回上一级页面
          icon: Icon(
            Icons.arrow_back, // 返回箭头图标
            color: event.color.accentColor, // 图标颜色为事件颜色的强调色
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(5.0), // 内边距为 20.0
        children: [
          Text(
            "日付: ${event.date.dateToStringWithFormat(format: "dd/MM/yyyy")}", // 显示事件日期
          ),
          SizedBox(
            height: 10.0, // 间隔高度为 15.0
          ),
          if (event.startTime != null && event.endTime != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                    children: [
                      Text("開始時間"), // 开始时间标签
                      Text(
                        event.startTime
                            ?.getTimeInFormat(TimeStampFormat.parse_12) ??
                            "", // 显示开始时间
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                    children: [
                      Text("終了時間"), // 结束时间标签
                      Text(
                        event.endTime
                            ?.getTimeInFormat(TimeStampFormat.parse_12) ??
                            "", // 显示结束时间
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.0, // 间隔高度为 30.0
            ),
          ],
          if (event.description?.isNotEmpty ?? false) ...[
            Divider(), // 分隔线
            Text("内容"), // 描述标签
            SizedBox(
              height: 10.0, // 间隔高度为 10.0
            ),
            Text(event.description!), // 显示事件描述
          ],
          const SizedBox(height: 50), // 固定间隔高度为 50
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // 删除 Firestore 中的事件
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(event.id)
                        .delete();

                    // 删除本地控制器中的事件
                    CalendarControllerProvider.of(context)
                        .controller
                        .remove(event);

                    Navigator.of(context).pop(); // 返回上一级页面
                  },
                  child: Text('イベント削除'), // 删除事件按钮文字
                ),
              ),
              SizedBox(width: 30), // 按钮之间的间隔
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateEventPage(
                          event: event, // 编辑事件
                        ),
                      ),
                    );

                    if (result == true) {
                      Navigator.of(context).pop(); // 如果编辑成功，返回上一级页面
                    }
                  },
                  child: Text('イベント編集'), // 编辑事件按钮文字
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
