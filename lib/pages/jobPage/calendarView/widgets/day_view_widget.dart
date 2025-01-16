import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 设计包

import '../pages/event_details_page.dart'; // 导入事件详情页面

// 创建 DayViewWidget 类，继承 StatelessWidget
class DayViewWidget extends StatelessWidget {
  final GlobalKey<DayViewState>? state; // 定义全局键，用于操作 DayView 的状态
  final double? width; // 定义宽度属性

  const DayViewWidget({ // 构造函数
    super.key, // 传递键值给父类
    this.state, // 初始化状态
    this.width, // 初始化宽度
  });

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    return DayView( // 返回 DayView 组件
      key: state, // 设置 DayView 的键
      width: width, // 设置 DayView 的宽度
      startDuration: Duration(hours: 8), // 设置 DayView 的开始时间为早上 8 点
      showHalfHours: true, // 显示半小时刻度
      heightPerMinute: 3, // 每分钟的高度为 3 像素
      timeLineBuilder: _timeLineBuilder, // 时间线构建器方法
      hourIndicatorSettings: HourIndicatorSettings( // 设置小时指示器的样式
        color: Theme.of(context).dividerColor, // 设置小时指示器的颜色
      ),
      onEventTap: (events, date) { // 事件点击时的回调
        Navigator.of(context).push( // 导航到事件详情页面
          MaterialPageRoute(
            builder: (_) => DetailsPage( // 创建事件详情页面
              event: events.first, // 将第一个事件传递给详情页面
            ),
          ),
        );
      },
      onEventLongTap: (events, date) { // 事件长按时的回调
        SnackBar snackBar = SnackBar(content: Text("on LongTap")); // 创建 Snackbar，显示长按提示
        ScaffoldMessenger.of(context).showSnackBar(snackBar); // 显示 Snackbar 提示
      },
      halfHourIndicatorSettings: HourIndicatorSettings( // 设置半小时指示器的样式
        color: Theme.of(context).dividerColor, // 设置半小时指示器的颜色
        lineStyle: LineStyle.dashed, // 将半小时指示器的样式设置为虚线
      ),
      verticalLineOffset: 0, // 设置垂直线的偏移量
      timeLineWidth: 65, // 设置时间线的宽度为 65 像素
      showLiveTimeLineInAllDays: true, // 显示实时时间线在所有天
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings( // 设置实时时间指示器的样式
        color: Colors.redAccent, // 设置实时时间指示器的颜色
        showBullet: false, // 不显示指示点
        showTime: true, // 显示时间
        showTimeBackgroundView: true, // 显示时间背景视图
      ),
    );
  }

  // 构建时间线的方法
  Widget _timeLineBuilder(DateTime date) {
    if (date.minute != 0) { // 如果分钟不为零，显示小时和分钟
      return Stack( // 使用 Stack 组件
        clipBehavior: Clip.none, // 不裁剪子组件
        children: [
          Positioned.fill( // 填充整个父容器
            top: -8, // 向上偏移 8 像素
            right: 8, // 向右偏移 8 像素
            child: Text(
              "${date.hour}:${date.minute}", // 显示小时和分钟
              textAlign: TextAlign.right, // 右对齐
              style: TextStyle(
                color: Colors.black.withAlpha(50), // 设置字体颜色和透明度
                fontStyle: FontStyle.italic, // 设置字体样式为斜体
                fontSize: 8, // 设置字体大小
              ),
            ),
          ),
        ],
      );
    }

    final hour = ((date.hour - 1) % 12) + 1; // 计算12小时制的小时
    return Stack( // 使用 Stack 组件
      clipBehavior: Clip.none, // 不裁剪子组件
      children: [
        Positioned.fill( // 填充整个父容器
          top: -8, // 向上偏移4 像素
          right:8, // 向右偏移 4 像素
          child: Text(
            "$hour ${date.hour ~/ 12 == 0 ? "am" : "pm"}", // 显示小时和 am/pm
            textAlign: TextAlign.right, // 右对齐
          ),
        ),
      ],
    );
  }
}
