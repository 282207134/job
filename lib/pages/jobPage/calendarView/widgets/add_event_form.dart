import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // 导入 flutter_colorpicker 包

import '../app_colors.dart'; // 导入 app_colors.dart 文件
import '../constants.dart'; // 导入 constants.dart 文件
import 'custom_button.dart'; // 导入 custom_button.dart 文件
import 'date_time_selector.dart'; // 导入 date_time_selector.dart 文件

class AddOrEditEventForm extends StatefulWidget {
  final Future<void> Function(CalendarEventData)? onEventAdd; // 事件添加回调函数
  final CalendarEventData? event; // 日历事件数据
  final DateTime? selectedDate; // 选中的日期

  const AddOrEditEventForm({
    super.key,
    this.onEventAdd,
    this.event,
    this.selectedDate,
  }); // 构造函数

  @override
  _AddOrEditEventFormState createState() => _AddOrEditEventFormState(); // 创建状态
}

class _AddOrEditEventFormState extends State<AddOrEditEventForm> {
  static const List<Color> _presetColors = <Color>[
    Color(0xFF1E88E5), // blue
    Color(0xFFE53935), // red
    Color(0xFF43A047), // green
    Color(0xFFFFB300), // amber
    Color(0xFF8E24AA), // purple
    Color(0xFF6D4C41), // brown
  ];

  late DateTime _startDate = DateTime.now().withoutTime; // 开始日期
  late DateTime _endDate = DateTime.now().withoutTime; // 结束日期

  DateTime? _startTime; // 开始时间
  DateTime? _endTime; // 结束时间

  Color _color = Colors.blue; // 事件颜色

  final _form = GlobalKey<FormState>(); // 表单全局键

  late final _descriptionController = TextEditingController(); // 描述控制器
  late final _titleController = TextEditingController(); // 标题控制器
  late final _titleNode = FocusNode(); // 标题焦点节点
  late final _descriptionNode = FocusNode(); // 描述焦点节点

  @override
  void initState() {
    super.initState();
    // 如果有选中的日期，使用选中的日期作为开始和结束日期
    if (widget.selectedDate != null) {
      _startDate = widget.selectedDate!.withoutTime;
      _endDate = widget.selectedDate!.withoutTime;
    }
    _setDefaults(); // 初始化默认值
  }

  @override
  void dispose() {
    _titleNode.dispose(); // 释放标题焦点节点
    _descriptionNode.dispose(); // 释放描述焦点节点
    _descriptionController.dispose(); // 释放描述控制器
    _titleController.dispose(); // 释放标题控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form, // 绑定表单键
      child: Column(
        mainAxisSize: MainAxisSize.min, // 设置列的主轴尺寸最小
        children: [
          TextFormField(
            controller: _titleController, // 绑定标题控制器
            decoration: AppConstants.inputDecoration.copyWith(
              labelText: "Event Title", // 标签文本
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            style: TextStyle(
              color: AppColors.black, // 文字颜色
              fontSize: 17.0, // 字体大小
            ),
            validator: (value) {
              final title = value?.trim(); // 去除标题的空格
              if (title == null || title == "") {
                return "Please enter event title."; // 验证标题
              }
              return null;
            },
            keyboardType: TextInputType.text, // 键盘类型
            textInputAction: TextInputAction.next, // 输入操作类型
          ),
          SizedBox(
            height: 15, // 间隔高度
          ),
          Row(
            children: [
              Expanded(
                child: DateTimeSelectorFormField(
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "Start Date", // 开始日期标签文本
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  initialDateTime: _startDate, // 初始日期时间
                  onSelect: (date) {
                    if (date.withoutTime.isAfter(_endDate.withoutTime)) {
                      _endDate = date.withoutTime; // 设置结束日期
                    }
                    _startDate = date.withoutTime; // 设置开始日期
                    if (mounted) {
                      setState(() {}); // 更新状态
                    }
                  },
                  validator: (value) {
                    if (value == null || value == "") {
                      return "Please select start date."; // 验证开始日期
                    }
                    return null;
                  },
                  textStyle: TextStyle(
                    color: AppColors.black, // 文字颜色
                    fontSize: 17.0, // 字体大小
                  ),
                  onSave: (date) => _startDate = date ?? _startDate, // 保存日期
                  type: DateTimeSelectionType.date, // 日期选择类型
                ),
              ),
              SizedBox(width: 20.0), // 间隔宽度
              Expanded(
                child: DateTimeSelectorFormField(
                  initialDateTime: _endDate, // 初始结束日期
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "End Date", // 结束日期标签文本
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  onSelect: (date) {
                    if (date.withoutTime.isBefore(_startDate.withoutTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('End date occurs before start date.'), // 提示结束日期早于开始日期
                      ));
                    } else {
                      _endDate = date.withoutTime; // 设置结束日期
                    }
                    if (mounted) {
                      setState(() {}); // 更新状态
                    }
                  },
                  validator: (value) {
                    if (value == null || value == "") {
                      return "Please select end date."; // 验证结束日期
                    }
                    return null;
                  },
                  textStyle: TextStyle(
                    color: AppColors.black, // 文字颜色
                    fontSize: 17.0, // 字体大小
                  ),
                  onSave: (date) => _endDate = date ?? _endDate, // 保存日期
                  type: DateTimeSelectionType.date, // 日期选择类型
                ),
              ),
            ],
          ),
          SizedBox(height: 15), // 间隔高度
          Row(
            children: [
              Expanded(
                child: DateTimeSelectorFormField(
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "Start Time", // 开始时间标签文本
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(
                      Icons.schedule_rounded,
                      size: 22,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  initialDateTime: _startTime, // 初始开始时间
                  minimumDateTime: CalendarConstants.epochDate, // 最小日期时间
                  onSelect: (date) {
                    _startTime = date; // 设置开始时间
                    if (_endTime != null && _startTime != null) {
                      // 处理跨午夜的情况
                      if (_endTime!.isBefore(_startTime!)) {
                        _endDate = _startDate.add(Duration(days: 1)); // 结束日期加1天
                      }
                    }
                    if (mounted) {
                      setState(() {}); // 更新状态
                    }
                  },
                  onSave: (date) => _startTime = date, // 保存时间
                  textStyle: TextStyle(
                    color: AppColors.black, // 文字颜色
                    fontSize: 17.0, // 字体大小
                  ),
                  type: DateTimeSelectionType.time, // 时间选择类型
                ),
              ),
              SizedBox(width: 20.0), // 间隔宽度
              Expanded(
                child: DateTimeSelectorFormField(
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "End Time", // 结束时间标签文本
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(
                      Icons.schedule_rounded,
                      size: 22,
                      color: AppColors.lightNavyBlue,
                    ),
                  ),
                  initialDateTime: _endTime, // 初始结束时间
                  onSelect: (date) {
                    _endTime = date; // 设置结束时间
                    if (_startTime != null && _endTime != null) {
                      // 处理跨午夜的情况
                      if (_endTime!.isBefore(_startTime!)) {
                        _endDate = _startDate.add(Duration(days: 1)); // 结束日期加1天
                      }
                    }
                    if (mounted) {
                      setState(() {}); // 更新状态
                    }
                  },
                  onSave: (date) => _endTime = date, // 保存时间
                  textStyle: TextStyle(
                    color: AppColors.black, // 文字颜色
                    fontSize: 17.0, // 字体大小
                  ),
                  type: DateTimeSelectionType.time, // 时间选择类型
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: _descriptionController, // 绑定描述控制器
            focusNode: _descriptionNode, // 绑定描述焦点节点
            style: TextStyle(
              color: AppColors.black, // 文字颜色
              fontSize: 17.0, // 字体大小
            ),
            keyboardType: TextInputType.multiline, // 键盘类型
            textInputAction: TextInputAction.newline, // 输入操作类型
            selectionControls: MaterialTextSelectionControls(), // 选择控制
            minLines: 1, // 最小行数
            maxLines: 10, // 最大行数
            maxLength: 1000, // 最大长度
            validator: (value) {
              if (value == null || value.trim() == "") {
                return "Please enter event description."; // 验证事件描述
              }
              return null;
            },
            decoration: AppConstants.inputDecoration.copyWith(
              hintText: "Event Description", // 提示文本
              hintStyle: TextStyle(
                color: AppColors.black,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Row(
            children: [
              Text(
                "Event Color: ",
                style: TextStyle(
                  color: AppColors.black, // 文字颜色
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._presetColors.map((c) => _buildColorDot(
                          color: c,
                          selected: _sameColor(_color, c),
                          onTap: () {
                            setState(() {
                              _color = c;
                            });
                          },
                        )),
                    _buildPaletteDot(
                      selected: !_presetColors.any((c) => _sameColor(c, _color)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              width: double.infinity,
              height: 52,
              fontSize: 17,
              onTap: _createEvent, // 创建或更新事件
              title: widget.event == null ? "Add Event" : "Update Event", // 按钮文本
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createEvent() async {
    if (!(_form.currentState?.validate() ?? true)) return; // 验证表单

    _form.currentState?.save(); // 保存表单

    final event = CalendarEventData(
      date: _startDate, // 设置事件日期
      endTime: _endTime, // 设置事件结束时间
      startTime: _startTime, // 设置事件开始时间
      endDate: _endDate, // 设置事件结束日期
      color: _color, // 设置事件颜色
      title: _titleController.text.trim(), // 设置事件标题
      description: _descriptionController.text.trim(), // 设置事件描述
    );

    await widget.onEventAdd?.call(event); // 调用回调函数
  }

  void _setDefaults() {
    if (widget.event == null) return; // 如果没有事件，则返回

    final event = widget.event!;
    _startDate = event.date; // 设置开始日期
    _endDate = event.endDate; // 设置结束日期
    _startTime = event.startTime ?? _startTime; // 设置开始时间
    _endTime = event.endTime ?? _endTime; // 设置结束时间
    _titleController.text = event.title; // 设置标题
    _descriptionController.text = event.description ?? ''; // 设置描述
    _color = event.color; // 设置颜色
  }

  void _resetForm() {
    _form.currentState?.reset(); // 重置表单
    _startDate = DateTime.now().withoutTime; // 重置开始日期
    _endDate = DateTime.now().withoutTime; // 重置结束日期
    _startTime = null; // 重置开始时间
    _endTime = null; // 重置结束时间
    _color = Colors.blue; // 重置颜色

    if (mounted) {
      setState(() {}); // 更新状态
    }
  }

  Widget _displayColorPicker(BuildContext dialogContext) {
    var color = _color; // 获取当前颜色
    return SimpleDialog(
      clipBehavior: Clip.hardEdge, // 裁剪行为
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // 设置圆角
      ),
      contentPadding: EdgeInsets.all(5.0), // 设置内容内边距
      children: [
        Text(
          "Select event color",
          style: TextStyle(
            color: AppColors.black, // 文字颜色
            fontSize: 15.0, // 字体大小
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0), // 设置外边距
          height: 1.0, // 设置高度
          color: AppColors.bluishGrey, // 设置颜色
        ),
        ColorPicker(
          displayThumbColor: true, // 显示拇指颜色
          enableAlpha: false, // 禁用 Alpha 通道
          pickerColor: _color, // 初始颜色
          onColorChanged: (c) {
            color = c; // 颜色变化时设置颜色
          },
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 50.0, bottom: 30.0), // 设置内边距
            child: CustomButton(
              width: 120,
              height: 42,
              fontSize: 14,
              title: "Select", // 按钮文本
              onTap: () {
                setState(() {
                  _color = color; // 更新颜色
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showColorPickerDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _displayColorPicker(dialogContext),
    );
  }

  Widget _buildColorDot({
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Colors.black87 : Colors.white,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteDot({required bool selected}) {
    return GestureDetector(
      onTap: _showColorPickerDialog,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF3B30),
              Color(0xFFFF9500),
              Color(0xFFFFCC00),
              Color(0xFF34C759),
              Color(0xFF0A84FF),
              Color(0xFF5856D6),
              Color(0xFFFF2D55),
              Color(0xFFFF3B30),
            ],
          ),
          border: Border.all(
            color: selected ? Colors.black87 : Colors.white,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.palette_outlined,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
}
