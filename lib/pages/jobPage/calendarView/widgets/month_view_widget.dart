import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 Flutter 的材料设计包

import '../pages/event_details_page.dart'; // 导入事件详情页面
import '../pages/create_event_page.dart'; // 导入创建事件页面
import '../../../../services/holiday_service.dart';

class MonthViewWidget extends StatefulWidget {
  final GlobalKey<MonthViewState>? state; // 定义全局键，用于操作MonthView的状态
  final double? width; // 定义宽度属性

  const MonthViewWidget({
    super.key,
    this.state,
    this.width,
  });

  @override
  State<MonthViewWidget> createState() => _MonthViewWidgetState();
}

class _MonthViewWidgetState extends State<MonthViewWidget> {
  void _onSelectionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    HolidayService.selectionVersion.addListener(_onSelectionChanged);
    HolidayService.getSelectedCountries().then((_) {
      HolidayService.ensureMonthHolidays(DateTime.now());
    });
  }

  @override
  void dispose() {
    HolidayService.selectionVersion.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MonthView(
      key: widget.state, // 设置 MonthView 的键
      width: widget.width, // 设置 MonthView 的宽度
      hideDaysNotInMonth: false, // 显示不在本月的天数
      useAvailableVerticalSpace: true, // 自动计算格子比例，完整显示不需上下拖动
      cellAspectRatio: 1.0, // 设置格子宽高比为 1:1，根据画面比例自动调整
      cellBuilder: _cellBuilder,
      onPageChange: (date, page) {
        HolidayService.ensureMonthHolidays(date);
      },
      onEventTap: (event, date) {
        if (HolidayService.isHolidayEventData(event)) return;
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
      onCellTap: (events, date) {
        // 点击日期格子时跳转到创建事件页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateEventPage(
              selectedDate: date, // 传递选中的日期
            ),
          ),
        );
      },
    );
  }

  Widget _cellBuilder(
    DateTime date,
    List<CalendarEventData> events,
    bool isToday,
    bool isInMonth,
    bool hideDaysNotInMonth,
  ) {
    final isSaturday = date.weekday == DateTime.saturday;
    final isSunday = date.weekday == DateTime.sunday;
    final holidayEvents = events
        .where((e) =>
            HolidayService.isHolidayEventData(e) &&
            HolidayService.shouldShowHolidayEvent(e))
        .toList();
    final normalEvents = events.where((e) => !HolidayService.isHolidayEventData(e)).toList();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: !isInMonth
            ? Colors.grey.shade100
            : isSunday
                ? const Color(0xFFFFF2F2)
                : isSaturday
                    ? const Color(0xFFF2F6FF)
                    : Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: isToday
                  ? BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? Colors.red : Colors.black54,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          ...holidayEvents.take(2).map(
                (e) => SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      e.title,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ...normalEvents.take(2).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: e.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: e.color, fontSize: 10),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
