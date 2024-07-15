import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../pages/event_details_page.dart'; // 导入事件详情页面

class DayViewWidget extends StatelessWidget {
  final GlobalKey<DayViewState>? state; // 定义全局键，用于操作DayView的状态
  final double? width; // 定义宽度属性

  const DayViewWidget({
    super.key,
    this.state,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return DayView(
      key: state, // 设置DayView的键
      width: width, // 设置DayView的宽度
      startDuration: Duration(hours: 8), // 设置DayView的开始时间
      showHalfHours: true, // 显示半小时刻度
      heightPerMinute: 3, // 每分钟的高度
      timeLineBuilder: _timeLineBuilder, // 时间线构建器
      hourIndicatorSettings: HourIndicatorSettings(
        color: Theme.of(context).dividerColor, // 设置小时指示器的颜色
      ),
      onEventTap: (events, date) {
        Navigator.of(context).push( // 事件点击时导航到详情页面
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              event: events.first, // 将事件传递给详情页面
            ),
          ),
        );
      },
      onEventLongTap: (events, date) {
        SnackBar snackBar = SnackBar(content: Text("on LongTap")); // 长按事件时显示提示
        ScaffoldMessenger.of(context).showSnackBar(snackBar); // 显示提示信息
      },
      halfHourIndicatorSettings: HourIndicatorSettings(
        color: Theme.of(context).dividerColor, // 设置半小时指示器的颜色
        lineStyle: LineStyle.dashed, // 设置半小时指示器的样式为虚线
      ),
      verticalLineOffset: 0, // 设置垂直线的偏移量
      timeLineWidth: 65, // 设置时间线的宽度
      showLiveTimeLineInAllDays: true, // 显示实时时间线在所有天
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Colors.redAccent, // 设置实时时间指示器的颜色
        showBullet: false, // 不显示指示点
        showTime: true, // 显示时间
        showTimeBackgroundView: true, // 显示时间背景视图
      ),
    );
  }

  Widget _timeLineBuilder(DateTime date) {
    if (date.minute != 0) { // 如果分钟不为零，显示小时和分钟
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: -8,
            right: 8,
            child: Text(
              "${date.hour}:${date.minute}", // 显示小时和分钟
              textAlign: TextAlign.right, // 右对齐
              style: TextStyle(
                color: Colors.black.withAlpha(50), // 设置字体颜色和透明度
                fontStyle: FontStyle.italic, // 设置字体样式为斜体
                fontSize: 12, // 设置字体大小
              ),
            ),
          ),
        ],
      );
    }

    final hour = ((date.hour - 1) % 12) + 1; // 计算12小时制的小时
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: -8,
          right: 8,
          child: Text(
            "$hour ${date.hour ~/ 12 == 0 ? "am" : "pm"}", // 显示小时和am/pm
            textAlign: TextAlign.right, // 右对齐
          ),
        ),
      ],
    );
  }
}
