import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // 导入 flutter_colorpicker 包

import '../app_colors.dart'; // 导入 app_colors.dart 文件
import '../constants.dart'; // 导入 constants.dart 文件
import '../extension.dart'; // 导入 extension.dart 文件
import 'custom_button.dart'; // 导入 custom_button.dart 文件
import 'date_time_selector.dart'; // 导入 date_time_selector.dart 文件

class AddOrEditEventForm extends StatefulWidget {
  final void Function(CalendarEventData)? onEventAdd; // 事件添加回调函数
  final CalendarEventData? event; // 日历事件数据

  const AddOrEditEventForm({
    super.key,
    this.onEventAdd,
    this.event,
  }); // 构造函数

  @override
  _AddOrEditEventFormState createState() => _AddOrEditEventFormState(); // 创建状态
}

class _AddOrEditEventFormState extends State<AddOrEditEventForm> {
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
                  ),
                  initialDateTime: _startTime, // 初始开始时间
                  minimumDateTime: CalendarConstants.epochDate, // 最小日期时间
                  onSelect: (date) {
                    if (_endTime != null &&
                        date.totalMinutes > _endTime!.totalMinutes) {
                      _endTime = date.add(Duration(minutes: 1)); // 设置结束时间
                    }
                    _startTime = date; // 设置开始时间
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
                  ),
                  initialDateTime: _endTime, // 初始结束时间
                  onSelect: (date) {
                    if (_startTime != null &&
                        date.totalMinutes < _startTime!.totalMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('End time is less than start time.'), // 提示结束时间早于开始时间
                      ));
                    } else {
                      _endTime = date; // 设置结束时间
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
              GestureDetector(
                onTap: _displayColorPicker, // 显示颜色选择器
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: _color, // 显示当前选择的颜色
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          CustomButton(
            onTap: _createEvent, // 创建或更新事件
            title: widget.event == null ? "Add Event" : "Update Event", // 按钮文本
          ),
        ],
      ),
    );
  }

  void _createEvent() {
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

    widget.onEventAdd?.call(event); // 调用回调函数
    _resetForm(); // 重置表单
  }

  void _setDefaults() {
    if (widget.event == null) return; // 如果没有事件，则返回

    final event = widget.event!;
    _startDate = event.date; // 设置开始日期
    _endDate = event.endDate ?? _endDate; // 设置结束日期
    _startTime = event.startTime ?? _startTime; // 设置开始时间
    _endTime = event.endTime ?? _endTime; // 设置结束时间
    _titleController.text = event.title; // 设置标题
    _descriptionController.text = event.description ?? ''; // 设置描述
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

  void _displayColorPicker() {
    var color = _color; // 获取当前颜色
    showDialog(
      context: context,
      useSafeArea: true, // 使用安全区域
      barrierColor: Colors.black26, // 设置背景颜色
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge, // 裁剪行为
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // 设置圆角
        ),
        contentPadding: EdgeInsets.all(20.0), // 设置内容内边距
        children: [
          Text(
            "Select event color",
            style: TextStyle(
              color: AppColors.black, // 文字颜色
              fontSize: 25.0, // 字体大小
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
                title: "Select", // 按钮文本
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _color = color; // 更新颜色
                    });
                  }
                  context.pop(); // 关闭对话框
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
