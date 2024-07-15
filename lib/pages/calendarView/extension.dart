import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:intl/intl.dart'; // 导入 intl 包

import 'app_colors.dart'; // 导入 app_colors.dart 文件
import 'enumerations.dart'; // 导入 enumerations.dart 文件

enum TimeStampFormat { parse_12, parse_24 } // 定义时间戳格式枚举

extension NavigationExtension on State {
  void pushRoute(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page)); // 定义页面导航扩展方法
}

extension NavigatorExtention on BuildContext {
  Future<T?> pushRoute<T>(Widget page) =>
      Navigator.of(this).push<T>(MaterialPageRoute(builder: (context) => page)); // 定义页面导航扩展方法

  void pop([dynamic value]) => Navigator.of(this).pop(value); // 定义返回上一级页面扩展方法

  void showSnackBarWithText(String text) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text))); // 定义显示 SnackBar 扩展方法
}

extension DateUtils on DateTime {
  String get weekdayToFullString {
    switch (weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "Error";
    }
  } // 获取星期的全称

  String get weekdayToAbbreviatedString {
    switch (weekday) {
      case DateTime.monday:
        return "M";
      case DateTime.tuesday:
        return "T";
      case DateTime.wednesday:
        return "W";
      case DateTime.thursday:
        return "T";
      case DateTime.friday:
        return "F";
      case DateTime.saturday:
        return "S";
      case DateTime.sunday:
        return "S";
      default:
        return "Err";
    }
  } // 获取星期的缩写

  int get totalMinutes => hour * 60 + minute; // 获取总分钟数

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute); // 获取 TimeOfDay 对象

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) =>
      DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      ); // 复制日期时间对象

  String dateToStringWithFormat({String format = 'y-M-d'}) {
    return DateFormat(format).format(this);
  } // 按照指定格式将日期时间转换为字符串

  DateTime stringToDateWithFormat({
    required String format,
    required String dateString,
  }) =>
      DateFormat(format).parse(dateString); // 按照指定格式将字符串转换为日期时间

  String getTimeInFormat(TimeStampFormat format) =>
      DateFormat('h:mm${format == TimeStampFormat.parse_12 ? " a" : ""}')
          .format(this)
          .toUpperCase(); // 按照指定格式获取时间字符串

  bool compareWithoutTime(DateTime date) =>
      day == date.day && month == date.month && year == date.year; // 比较日期，不比较时间

  bool compareTime(DateTime date) =>
      hour == date.hour && minute == date.minute && second == date.second; // 比较时间，不比较日期
}

extension ColorExtension on Color {
  Color get accentColor =>
      (blue / 2 >= 255 / 2 || red / 2 >= 255 / 2 || green / 2 >= 255 / 2)
          ? AppColors.black
          : AppColors.white; // 根据颜色的亮度返回强调色
}

extension StringExt on String {
  String get capitalized => toBeginningOfSentenceCase(this) ?? ""; // 将字符串首字母大写
}

extension ViewNameExt on CalendarView {
  String get name => toString().split(".").last; // 获取 CalendarView 枚举的名称
}
