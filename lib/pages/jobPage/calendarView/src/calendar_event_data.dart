import 'package:flutter/material.dart';
import 'package:job/pages/jobPage/calendarView/calendar_view.dart';

@immutable
class CalendarEventData<T extends Object?> {
  final String? id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String? description;
  final Color color;
  final T? event;
  final DateTime? _endDate;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  CalendarEventData({
    this.id,
    required this.title,
    required DateTime date,
    this.description,
    this.event,
    this.color = Colors.blue,
    this.startTime,
    this.endTime,
    this.titleStyle,
    this.descriptionStyle,
    DateTime? endDate,
  })  : _endDate = endDate?.withoutTime,
        date = date.withoutTime;

  DateTime get endDate => _endDate ?? date;

  bool get isRangingEvent {
    final diff = endDate.withoutTime.difference(date.withoutTime).inDays;
    return diff > 0 && !isFullDayEvent;
  }

  bool get isFullDayEvent {
    return (startTime == null ||
        endTime == null ||
        (startTime!.isDayStart && endTime!.isDayStart));
  }

  bool occursOnDate(DateTime currentDate) {
    return currentDate == date ||
        currentDate == endDate ||
        (currentDate.isBefore(endDate.withoutTime) &&
            currentDate.isAfter(date.withoutTime));
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "date": date.toIso8601String(),
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "event": event,
    "title": title,
    "description": description,
    "color": color.value,
    "endDate": endDate.toIso8601String(),
  };

  factory CalendarEventData.fromMap(Map<String, dynamic> map) {
    return CalendarEventData(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      description: map['description'],
      color: Color(map['color']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      event: map['event']

    );
  }

  CalendarEventData<T> copyWith({
    String? id,
    String? title,
    String? description,
    T? event,
    Color? color,
    DateTime? startTime,
    DateTime? endTime,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    DateTime? endDate,
    DateTime? date,
  }) {
    return CalendarEventData(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      description: description ?? this.description,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      endDate: endDate ?? this.endDate,
      event: event ?? this.event,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }

  @override
  String toString() => '${toMap()}';

  @override
  bool operator ==(Object other) {
    return other is CalendarEventData<T> &&
        id == other.id &&
        date.compareWithoutTime(other.date) &&
        endDate.compareWithoutTime(other.endDate) &&
        ((event == null && other.event == null) ||
            (event != null && other.event != null && event == other.event)) &&
        ((startTime == null && other.startTime == null) ||
            (startTime != null &&
                other.startTime != null &&
                startTime!.hasSameTimeAs(other.startTime!))) &&
        ((endTime == null && other.endTime == null) ||
            (endTime != null &&
                other.endTime != null &&
                endTime!.hasSameTimeAs(other.endTime!))) &&
        title == other.title &&
        color == other.color &&
        titleStyle == other.titleStyle &&
        descriptionStyle == other.descriptionStyle &&
        description == other.description;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      description.hashCode ^
      descriptionStyle.hashCode ^
      titleStyle.hashCode ^
      color.hashCode ^
      title.hashCode ^
      date.hashCode;
}
