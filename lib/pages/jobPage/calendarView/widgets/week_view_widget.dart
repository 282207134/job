import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart';

import '../pages/event_details_page.dart';

class WeekViewWidget extends StatelessWidget {
  final GlobalKey<WeekViewState>? state;
  final double? width;

  // 构造函数，接受state和width参数
  const WeekViewWidget({super.key, this.state, this.width});

  @override
  Widget build(BuildContext context) {
    return WeekView(
      key: state,
      width: width,
      showLiveTimeLineInAllDays: true, // 在所有天数中显示实时时间线
      timeLineWidth: 65, // 时间线的宽度
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Colors.redAccent, // 实时指示器的颜色
        showTime: true, // 是否显示时间
      ),
      onEventTap: (events, date) {
        // 点击事件时的处理
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              event: events.first, // 传递第一个事件到详情页面
            ),
          ),
        );
      },
      onEventLongTap: (events, date) {
        // 长按事件时的处理
        SnackBar snackBar = SnackBar(content: Text("on LongTap"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}
