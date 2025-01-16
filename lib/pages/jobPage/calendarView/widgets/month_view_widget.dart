import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../pages/event_details_page.dart'; // 导入事件详情页面

class MonthViewWidget extends StatelessWidget {
  final GlobalKey<MonthViewState>? state; // 定义全局键，用于操作MonthView的状态
  final double? width; // 定义宽度属性

  const MonthViewWidget({
    super.key,
    this.state,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return MonthView(
      key: state, // 设置MonthView的键
      width: width, // 设置MonthView的宽度
      hideDaysNotInMonth: false, // 显示不在本月的天数
      onEventTap: (event, date) {
        Navigator.of(context).push( // 事件点击时导航到详情页面
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              event: event, // 将事件传递给详情页面
            ),
          ),
        );
      },
      onEventLongTap: (event, date) {
        SnackBar snackBar = SnackBar(content: Text("on LongTap")); // 长按事件时显示提示
        ScaffoldMessenger.of(context).showSnackBar(snackBar); // 显示提示信息
      },
    );
  }
}
