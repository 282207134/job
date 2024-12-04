// Copyright (c) 2021 Simform Solutions. All rights reserved.
// 使用此源代码受 MIT 风格许可证的约束，许可证可以在 LICENSE 文件中找到。

import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包，用于与 Firebase Firestore 交互
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础功能包
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 设计包

import '../calendar_event_data.dart'; // 导入日历事件数据模型
import '../constants.dart'; // 导入常量库
import '../extensions.dart'; // 导入扩展方法库
import '../style/header_style.dart'; // 导入头部样式库
import '../typedefs.dart'; // 导入类型定义
import '../enumerations.dart'; // 导入枚举
import 'common_components.dart'; // 导入公共组件库

/// 此类定义了在日视图中显示的默认事件瓦片。
class RoundedEventTile extends StatelessWidget {
  /// 瓦片的标题。
  final String title;

  /// 瓦片的描述。
  final String? description;

  /// 瓦片的背景颜色。
  /// 默认颜色为 [Colors.blue]
  final Color backgroundColor;

  /// 如果同一瓦片可以有多个事件。
  /// 在大多数情况下，此值将比总事件数少 1。
  final int totalEvents;

  /// 瓦片的内边距。默认内边距为 [EdgeInsets.zero]
  final EdgeInsets padding;

  /// 瓦片的外边距。默认外边距为 [EdgeInsets.zero]
  final EdgeInsets margin;

  /// 瓦片的边框半径。
  final BorderRadius borderRadius;

  /// 事件标题的样式
  final TextStyle? titleStyle;

  /// 事件描述的样式
  final TextStyle? descriptionStyle;

  /// 默认瓦片，用于在日视图中显示。
  const RoundedEventTile({
    Key? key,
    required this.title, // 必填的标题参数
    this.padding = EdgeInsets.zero, // 默认内边距为零
    this.margin = EdgeInsets.zero, // 默认外边距为零
    this.description, // 可选的描述参数
    this.borderRadius = BorderRadius.zero, // 默认边框半径为零
    this.totalEvents = 1, // 默认事件总数为 1
    this.backgroundColor = Colors.blue, // 默认背景颜色
    this.titleStyle, // 自定义标题样式
    this.descriptionStyle, // 自定义描述样式
  }) : super(key: key); // 调用父类的构造函数

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    return Container( // 使用容器作为根组件
      padding: padding, // 设置内边距
      margin: margin, // 设置外边距
      decoration: BoxDecoration( // 设置容器的装饰样式
        color: backgroundColor, // 设置背景颜色
        borderRadius: borderRadius, // 设置边框半径
      ),
      child: Column( // 使用列组件
        crossAxisAlignment: CrossAxisAlignment.start, // 设置子组件左对齐
        mainAxisSize: MainAxisSize.min, // 设置主轴尺寸为最小
        children: [
          if (title.isNotEmpty) // 如果标题不为空
            Expanded( // 使用扩展组件
              child: Text(
                title, // 显示标题
                style: titleStyle ?? // 使用自定义标题样式，若未提供则使用默认样式
                    TextStyle(
                      fontSize: 20, // 设置字体大小
                      color: backgroundColor.accent, // 设置字体颜色
                    ),
                softWrap: true, // 允许软换行
                overflow: TextOverflow.fade, // 溢出时显示渐变效果`
              ),
            ),
          if (description?.isNotEmpty ?? false) // 如果描述不为空
            Expanded( // 使用扩展组件
              child: Padding( // 添加填充
                padding: const EdgeInsets.only(bottom: 12.0), // 设置底部填充
                child: Text(
                  description!, // 显示描述
                  style: descriptionStyle ?? // 使用自定义描述样式，若未提供则使用默认样式
                      TextStyle(
                        fontSize: 15, // 设置字体大小

                        color: backgroundColor.accent.withAlpha(200), // 设置字体颜色
                      ),
                ),
              ),
            ),
          if (totalEvents > 1) // 如果事件总数大于 1
            Expanded( // 使用扩展组件
              child: Text(
                "+${totalEvents - 1} more", // 显示剩余事件数量
                style: (descriptionStyle ?? // 使用描述样式，若未提供则使用默认样式
                    TextStyle(
                      color: backgroundColor.accent.withAlpha(200), // 设置字体颜色
                    ))
                    .copyWith(fontSize: 17), // 设置字体大小
              ),
            ),
        ],
      ),
    );
  }
}

/// 用于日视图的头部小部件。
class DayPageHeader extends CalendarPageHeader {
  /// 用于日视图的头部小部件。
  const DayPageHeader({
    Key? key,
    VoidCallback? onNextDay, // 可选的下一天回调
    AsyncCallback? onTitleTapped, // 可选的标题点击回调
    VoidCallback? onPreviousDay, // 可选的上一天回调
    Color iconColor = Constants.black, // 图标颜色，默认为黑色
    Color backgroundColor = Constants.headerBackground, // 背景颜色，默认为头部背景色
    StringProvider? dateStringBuilder, // 可选的日期字符串构建器
    required DateTime date, // 必填的日期参数
    HeaderStyle headerStyle = const HeaderStyle(), // 默认头部样式
  }) : super(
    key: key,
    date: date, // 传递日期
    // ignore_for_file: deprecated_member_use_from_same_package
    backgroundColor: backgroundColor, // 传递背景颜色
    iconColor: iconColor, // 传递图标颜色
    onNextDay: onNextDay, // 传递下一天回调
    onPreviousDay: onPreviousDay, // 传递上一天回调
    onTitleTapped: onTitleTapped, // 传递标题点击回调
    dateStringBuilder:
    dateStringBuilder ?? DayPageHeader._dayStringBuilder, // 传递日期字符串构建器
    headerStyle: headerStyle, // 传递头部样式
  );

  // 用于格式化日期的静态方法
  static String _dayStringBuilder(DateTime date, {DateTime? secondaryDate}) =>
      "${date.day} - ${date.month} - ${date.year}"; // 返回格式化后的日期字符串
}

/// 默认时间线标记，用于周视图和日视图
class DefaultTimeLineMark extends StatelessWidget {
  /// 定义要显示的时间
  final DateTime date;

  /// 用于时间字符串的字符串提供者
  final StringProvider? timeStringBuilder;

  /// 时间字符串的文本样式。
  final TextStyle? markingStyle;

  /// 时间线的时间标记
  const DefaultTimeLineMark({
    Key? key,
    required this.date, // 必填的日期
    this.markingStyle, // 可选的标记样式
    this.timeStringBuilder, // 可选的时间字符串构建器
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { // 构建时间标记的 UI
    final hour = ((date.hour - 1) % 12) + 1; // 计算 12 小时制的小时
    final timeString = (timeStringBuilder != null) // 如果存在时间字符串构建器
        ? timeStringBuilder!(date) // 调用构建器获取字符串
        : date.minute != 0 // 如果分钟不为零
        ? "$hour:${date.minute}" // 显示小时和分钟
        : "$hour ${date.hour ~/ 12 == 0 ? "am" : "pm"}"; // 显示小时和 am/pm

    return Transform.translate( // 进行平移变换
      offset: Offset(0, -7.5), // 设置偏移量
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0), // 设置右侧填充
        child: Text(
          timeString, // 显示时间字符串
          textAlign: TextAlign.right, // 右对齐
          style: markingStyle ?? // 使用自定义样式，若未提供则使用默认样式
              TextStyle(
                fontSize: 15.0, // 设置字体大小
              ),
        ),
      ),
    );
  }
}

/// 默认全日事件视图类
class FullDayEventView<T> extends StatelessWidget {
  const FullDayEventView({
    Key? key, // 可选的键值
    this.boxConstraints = const BoxConstraints(maxHeight: 100), // 确定视图的约束
    required this.events, // 必填的事件列表
    this.padding, // 可选的内边距
    this.itemView, // 可选的自定义事件视图组件
    this.titleStyle, // 可选的标题样式
    this.onEventTap, // 用户点击事件的回调
    required this.date, // 必填的日期
    this.onEventDoubleTap, // 用户双击事件的回调
    this.onEventLongPress, // 用户长按事件的回调
  }) : super(key: key);

  /// 视图的约束条件
  final BoxConstraints boxConstraints;

  /// 显示的事件列表
  final List<CalendarEventData<T>> events;

  /// 视图的内边距
  final EdgeInsets? padding;

  /// 自定义事件视图的组件
  final Widget Function(CalendarEventData<T>? event)? itemView;

  /// 标题的文本样式
  final TextStyle? titleStyle;

  /// 当用户点击事件瓦片时调用的回调
  final CellTapCallback<T>? onEventTap;

  /// 当用户长按事件瓦片时调用的回调
  final CellTapCallback<T>? onEventLongPress;

  /// 当用户双击任何事件瓦片时调用的回调
  final CellTapCallback<T>? onEventDoubleTap;

  /// 显示事件的日期。
  final DateTime date;

  @override
  Widget build(BuildContext context) { // 构建事件视图的 UI
    return ConstrainedBox( // 使用约束盒子
      constraints: boxConstraints, // 设置约束条件
      child: ListView.builder( // 使用列表视图构建事件列表
        itemCount: events.length, // 设置项目数量为事件长度
        padding: padding ?? EdgeInsets.zero, // 设置内边距
        shrinkWrap: true, // 允许根据内容收缩
        itemBuilder: (context, index) => InkWell( // 可点击的区域
          onLongPress: () => onEventLongPress?.call(events, date), // 长按事件的回调
          onTap: () => onEventTap?.call(events, date), // 点击事件的回调
          onDoubleTap: () => onEventDoubleTap?.call(events, date), // 双击事件的回调
          child: itemView?.call(events[index]) ?? // 使用自定义事件视图组件，如果未提供则使用默认组件
              Container( // 默认事件显示组件
                margin: const EdgeInsets.all(5.0), // 设置外边距
                padding: const EdgeInsets.all(1.0), // 设置内边距
                height: 24, // 设置高度
                child: Text(
                  events[index].title, // 显示事件标题
                  style: titleStyle ?? // 使用自定义标题样式，若未提供则使用默认样式
                      TextStyle(
                        fontSize: 16, // 设置字体大小
                        color: events[index].color.accent, // 设置字体颜色
                      ),
                  maxLines: 1, // 最大行数为 1
                ),
                decoration: BoxDecoration( // 设置容器的装饰
                  borderRadius: BorderRadius.circular(5), // 设置圆角
                  color: events[index].color, // 设置背景颜色
                ),
                alignment: Alignment.centerLeft, // 设置内容左对齐
              ),
        ),
      ),
    );
  }
}
