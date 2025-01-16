import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../extension.dart'; // 导入扩展

typedef Validator = String? Function(String? value); // 定义验证器类型

enum DateTimeSelectionType { date, time } // 定义日期时间选择类型枚举

class DateTimeSelectorFormField extends StatefulWidget {
  /// 选择日期时调用
  final Function(DateTime)? onSelect; // 定义一个回调函数，当选择日期或时间时调用

  /// 选择时间或日期
  final DateTimeSelectionType type; // 定义选择类型，默认为时间选择

  final FocusNode? focusNode; // 焦点节点，用于管理焦点

  /// 可以选择的最小日期
  final DateTime? minimumDateTime; // 最小可选择日期

  final Validator? validator; // 验证函数，用于验证输入值

  final TextStyle? textStyle; // 文本样式
  final void Function(DateTime? date)? onSave; // 保存回调函数
  final InputDecoration? decoration; // 输入框装饰
  final TextEditingController? controller; // 文本控制器
  final DateTime? initialDateTime; // 初始日期时间

  const DateTimeSelectorFormField({
    this.onSelect,
    this.type = DateTimeSelectionType.time,
    this.onSave,
    this.decoration,
    this.focusNode,
    this.minimumDateTime,
    this.validator,
    this.textStyle,
    this.controller,
    this.initialDateTime,
  });

  @override
  _DateTimeSelectorFormFieldState createState() => _DateTimeSelectorFormFieldState(); // 创建状态
}

class _DateTimeSelectorFormFieldState extends State<DateTimeSelectorFormField> {
  late var _minimumDate = CalendarConstants.minDate.withoutTime; // 初始化最小日期

  late var _textEditingController = widget.controller ?? TextEditingController(); // 初始化文本编辑控制器
  late var _focusNode = _getFocusNode(); // 初始化焦点节点

  late DateTime? _selectedDate; // 初始化选择的日期

  @override
  void initState() {
    super.initState();
    _setDates(); // 初始化设置日期
  }

  @override
  void didUpdateWidget(covariant DateTimeSelectorFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) { // 检查焦点节点是否变化
      _focusNode.dispose(); // 处理旧的焦点节点
      _focusNode = _getFocusNode(); // 获取新的焦点节点
    }

    if (widget.controller != oldWidget.controller) { // 检查控制器是否变化
      _textEditingController.dispose(); // 处理旧的控制器
      _textEditingController = widget.controller ?? TextEditingController(); // 获取新的控制器
    }

    if (_selectedDate != oldWidget.initialDateTime || widget.minimumDateTime != oldWidget.minimumDateTime) {
      _setDates(); // 更新日期设置
    }
  }

  FocusNode _getFocusNode() {
    final node = widget.focusNode ?? FocusNode(); // 获取焦点节点

    // 如果节点获得焦点，则显示选择器
    // node.addListener(() {
    //   if (node.hasFocus) {
    //     _showSelector();
    //   }
    // });

    return node; // 返回焦点节点
  }

  @override
  void dispose() {
    if (widget.controller == null) _textEditingController.dispose(); // 处理控制器
    if (widget.focusNode == null) _focusNode.dispose(); // 处理焦点节点

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // 返回一个手势检测器
      onTap: _showSelector, // 绑定点击事件，显示选择器
      child: TextFormField( // 文本表单字段
        focusNode: _focusNode, // 焦点节点
        style: widget.textStyle, // 文本样式
        controller: _textEditingController, // 控制器
        validator: widget.validator, // 验证器
        minLines: 1, // 最小行数
        onSaved: (value) => widget.onSave?.call(_selectedDate), // 保存回调
        enabled: false, // 禁用输入
        decoration: widget.decoration, // 输入装饰
      ),
    );
  }

  Future<void> _showSelector() async {
    DateTime? date;

    if (widget.type == DateTimeSelectionType.date) { // 选择日期
      date = await _showDateSelector(); // 显示日期选择器

      _textEditingController.text = (date ?? _selectedDate)
          ?.dateToStringWithFormat(format: "dd/MM/yyyy") ??
          ''; // 更新文本框内容
    } else { // 选择时间
      date = await _showTimeSelector(); // 显示时间选择器

      _textEditingController.text =
          (date ?? _selectedDate)?.getTimeInFormat(TimeStampFormat.parse_12) ??
              ''; // 更新文本框内容
    }

    _selectedDate = date ?? _selectedDate; // 更新选择的日期

    if (mounted) {
      setState(() {}); // 更新状态
    }

    if (date != null) {
      widget.onSelect?.call(date); // 调用选择回调
    }
  }

  Future<DateTime?> _showDateSelector() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // 初始日期
      firstDate: widget.minimumDateTime ?? CalendarConstants.minDate, // 最早可选日期
      lastDate: CalendarConstants.maxDate, // 最晚可选日期
    );

    return date; // 返回选择的日期
  }

  Future<DateTime?> _showTimeSelector() async {
    final now = _selectedDate ?? DateTime.now(); // 当前日期

    final time = await showTimePicker(
      context: context,
      builder: (context, widget) {
        return widget ?? SizedBox.shrink(); // 返回时间选择器或空部件
      },
      initialTime: TimeOfDay.fromDateTime(now), // 初始时间
    );

    if (time == null) return null; // 如果没有选择时间，返回null

    final date = now.copyWith(
      hour: time.hour, // 设置选择的小时
      minute: time.minute, // 设置选择的分钟
    );

    return date; // 返回选择的日期时间
  }

  void _setDates() {
    _minimumDate = widget.minimumDateTime ?? CalendarConstants.minDate; // 设置最小日期
    _selectedDate = widget.initialDateTime; // 设置初始日期

    switch (widget.type) {
      case DateTimeSelectionType.date: // 日期选择类型
        if (_selectedDate?.withoutTime.isBefore(_minimumDate.withoutTime) ?? false) {
          throw 'InitialDate is smaller than Minimum date'; // 如果初始日期小于最小日期，抛出异常
        }

        // 避免在重建部件时发生内部错误
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textEditingController.text =
              _selectedDate?.dateToStringWithFormat(format: "dd/MM/yyyy") ?? ''; // 更新文本框内容
        });

        break;

      case DateTimeSelectionType.time: // 时间选择类型
        if (_selectedDate != null &&
            _selectedDate!.getTotalMinutes < _minimumDate.getTotalMinutes) {
          throw 'InitialDate is smaller than Minimum date'; // 如果初始时间小于最小时间，抛出异常
        }

        // 避免在重建部件时发生内部错误
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textEditingController.text =
              _selectedDate?.getTimeInFormat(TimeStampFormat.parse_12) ?? ''; // 更新文本框内容
        });

        break;
    }
  }
}
