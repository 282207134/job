// Copyright (c) 2021 Simform Solutions. All rights reserved.
// 使用此源代码受 MIT 风格许可证的约束，许可证可以在 LICENSE 文件中找到

import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Firestore 包，用于与 Firebase Firestore 交互
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础功能包
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 设计包

import '../calendar_event_data.dart'; // 导入日历事件数据模型
import '../constants.dart'; // 导入常量库
import '../extensions.dart'; // 导入扩展方法库
import '../style/header_style.dart'; // 导入头部样式库
import '../typedefs.dart'; // 导入类型定义
import '../enumerations.dart'; // 导入枚举

import 'components.dart'; // 导入组件库

// 定义一个名为 CalendarPageHeader 的无状态小部件
class CalendarPageHeader extends StatelessWidget {
  /// 用户点击右箭头时的回调
  final VoidCallback? onNextDay;

  /// 用户点击左箭头时的回调
  final VoidCallback? onPreviousDay;

  /// 用户点击标题时的回调
  final AsyncCallback? onTitleTapped;

  /// 日期（月份/日期）
  final DateTime date;

  /// 辅助日期，用于定义日期范围
  /// [date]可以是开始日期， [secondaryDate]可以是结束日期
  final DateTime? secondaryDate;

  /// 提供用于显示的标题字符串
  final StringProvider dateStringBuilder;

  // TODO: 下一次发布后需要移除
  /// 头部背景颜色
  @Deprecated("Use Header Style to provide background")
  final Color backgroundColor;

  // TODO: 下一次发布后需要移除
  /// 头部两侧图标的颜色
  @Deprecated("Use Header Style to provide icon color")
  final Color iconColor;

  /// 日历头部的样式
  final HeaderStyle headerStyle;

  /// 月视图和日视图通用的头部，用户可以定义日期的显示格式
  /// 通过提供[dateStringBuilder]函数。
  const CalendarPageHeader({
    Key? key,
    required this.date, // 必填的日期参数
    required this.dateStringBuilder, // 必填的日期字符串构建器
    this.onNextDay, // 可选的下一个日期回调
    this.onTitleTapped, // 可选的标题点击回调
    this.onPreviousDay, // 可选的上一个日期回调
    this.secondaryDate, // 可选的辅助日期
    @Deprecated("Use Header Style to provide background") // 报废的背景颜色参数
    this.backgroundColor = Constants.headerBackground, // 默认的头部背景颜色
    @Deprecated("Use Header Style to provide icon color") // 报废的图标颜色参数
    this.iconColor = Constants.black, // 默认的图标颜色
    this.headerStyle = const HeaderStyle(), // 默认的头部样式
  }) : super(key: key); // 调用父类构造函数

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    return Container( // 使用容器作为根组件
      margin: headerStyle.headerMargin, // 设置标题的外边距
      padding: headerStyle.headerPadding, // 设置标题的内边距
      decoration: // 使用装饰来设置背景颜色
      // ignore_for_file: deprecated_member_use_from_same_package
      headerStyle.decoration ?? BoxDecoration(color: backgroundColor), // 设置背景
      clipBehavior: Clip.antiAlias, // 设置剪裁行为
      child: Row( // 使用行布局
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子组件均匀分布
        children: [
          if (headerStyle.leftIconVisible) // 如果左侧图标可见
            IconButton( // 图标按钮
              onPressed: onPreviousDay, // 点击时执行左箭头回调
              splashColor: Colors.transparent, // 设置水波纹颜色为透明
              focusColor: Colors.transparent, // 设置焦点颜色为透明
              hoverColor: Colors.transparent, // 设置悬停颜色为透明
              highlightColor: Colors.transparent, // 设置高亮颜色为透明
              padding: headerStyle.leftIconPadding, // 设置左图标的内边距
              icon: headerStyle.leftIcon ?? // 使用自定义的左图标
                  Icon(
                    Icons.chevron_left, // 默认左箭头图标
                    size: 30, // 图标大小
                    color: iconColor, // 图标颜色
                  ),
            ),
          Expanded( // 扩展组件以填充主轴
            child: InkWell( // 可点击的水波纹区域
              onTap: onTitleTapped, // 点击标题时的回调
              child: Text(
                dateStringBuilder(date, secondaryDate: secondaryDate), // 根据提供的函数显示日期
                textAlign: headerStyle.titleAlign, // 设置标题对齐方式
                style: headerStyle.headerTextStyle, // 设置标题文本样式
              ),
            ),
          ),
          if (headerStyle.rightIconVisible) // 如果右侧图标可见
            IconButton( // 图标按钮
              onPressed: onNextDay, // 点击时执行右箭头回调
              splashColor: Colors.transparent, // 设置水波纹颜色为透明
              focusColor: Colors.transparent, // 设置焦点颜色为透明
              hoverColor: Colors.transparent, // 设置悬停颜色为透明
              highlightColor: Colors.transparent, // 设置高亮颜色为透明
              padding: headerStyle.rightIconPadding, // 设置右图标的内边距
              icon: headerStyle.rightIcon ?? // 使用自定义的右图标
                  Icon(
                    Icons.chevron_right, // 默认右箭头图标
                    size: 30, // 图标大小
                    color: iconColor, // 图标颜色
                  ),
            ),
        ],
      ),
    );
  }
}

// 此类将在日视图和周视图中使用
class DefaultPressDetector extends StatelessWidget {
  /// 默认按压检测器，用于周视图和日视图
  const DefaultPressDetector({
    required this.date, // 必填的日期
    required this.height, // 必填的高度
    required this.width, // 必填的宽度
    required this.heightPerMinute, // 每分钟的高度
    required this.minuteSlotSize, // 分钟槽大小
    this.onDateTap, // 可选的日期点击回调
    this.onDateLongPress, // 可选的日期长按回调
    this.startHour = 0, // 默认开始小时
  });

  final DateTime date; // 日期
  final double height; // 高度
  final double width; // 宽度
  final double heightPerMinute; // 每分钟的高度
  final MinuteSlotSize minuteSlotSize; // 分钟槽大小
  final DateTapCallback? onDateTap; // 日期点击回调
  final DatePressCallback? onDateLongPress; // 日期长按回调
  final int startHour; // 开始小时

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute; // 每个时间槽的高度
    final slots = (Constants.hoursADay * 60) ~/ minuteSlotSize.minutes; // 一天有多少个时间槽

    return SizedBox( // 设置大小
      height: height, // 高度
      width: width, // 宽度
      child: Stack( // 使用栈布局
        children: [
          for (int i = 0; i < slots; i++) // 遍历所有时间槽
            Positioned( // 设置位置
              top: heightPerSlot * i, // 计算顶部位置
              left: 0, // 左边距
              right: 0, // 右边距
              bottom: height - (heightPerSlot * (i + 1)), // 计算底部位置
              child: GestureDetector( // 手势检测器
                behavior: HitTestBehavior.translucent, // 透明点击检测
                onLongPress: () => onDateLongPress?.call( // 长按时的回调
                  getSlotDateTime(i), // 获取对应时间槽的日期
                ),
                onTap: () => onDateTap?.call( // 点击时的回调
                  getSlotDateTime(i), // 获取对应时间槽的日期
                ),
                child: SizedBox( // 设置子组件大小
                  width: width, // 宽度
                  height: heightPerSlot, // 高度
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 获取时间槽对应的日期时间
  DateTime getSlotDateTime(int slot) => DateTime(
    date.year, // 年
    date.month, // 月
    date.day, // 日
    0, // 时
    (minuteSlotSize.minutes * slot) + (startHour * 60), // 计算分钟
  );
}

// 此类将在日视图和周视图中使用
class DefaultEventTile<T> extends StatelessWidget {
  const DefaultEventTile({
    required this.date, // 必填的日期
    required this.events, // 必填的事件列表
    required this.boundary, // 必填的边界矩形
    required this.startDuration, // 必填的开始时间
    required this.endDuration, // 必填的结束时间
  });

  final DateTime date; // 日期
  final List<CalendarEventData<T>> events; // 事件列表
  final Rect boundary; // 边界矩形
  final DateTime startDuration; // 开始时间
  final DateTime endDuration; // 结束时间

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    if (events.isNotEmpty) { // 如果事件列表不为空
      final event = events[0]; // 获取第一个事件
      return RoundedEventTile( // 返回圆角事件组件
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
        title: event.title, // 事件标题
        totalEvents: events.length - 1, // 事件总数减去一个
        description: event.description, // 事件描述
        padding: EdgeInsets.all(3.0), // 内边距
        backgroundColor: event.color, // 背景颜色
        margin: EdgeInsets.all(2.0), // 外边距
        titleStyle: event.titleStyle, // 标题样式
        descriptionStyle: event.descriptionStyle, // 描述样式
      );
    } else {
      return SizedBox.shrink(); // 如果事件列表为空，返回一个透明的子组件
    }
  }
}
