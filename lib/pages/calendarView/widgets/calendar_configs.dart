import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包
import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../app_colors.dart'; // 导入应用程序颜色
import '../enumerations.dart'; // 导入枚举
import '../extension.dart'; // 导入扩展
import '../src/calendar_controller_provider.dart';
import 'add_event_form.dart'; // 导入添加事件表单

class CalendarConfig extends StatelessWidget { // 定义一个名为CalendarConfig的无状态小部件
  final void Function(CalendarView view) onViewChange; // 定义一个回调函数用于视图更改
  final CalendarView currentView; // 定义当前视图

  const CalendarConfig({
    super.key, // 传递键值给父类
    required this.onViewChange, // 初始化视图更改回调
    this.currentView = CalendarView.month, // 设置默认视图为月视图
  });

  @override
  Widget build(BuildContext context) { // 构建部件的UI
    return Column( // 返回一个列部件
      mainAxisSize: MainAxisSize.min, // 设置主轴尺寸为最小
      crossAxisAlignment: CrossAxisAlignment.start, // 设置交叉轴对齐方式为左对齐
      children: [
        Padding( // 添加填充
          padding: EdgeInsets.only(left: 20, top: 20), // 设置填充值
          child: Text(
            "Flutter Calendar Page", // 显示文本
            style: TextStyle(
              color: AppColors.black, // 设置文字颜色
              fontSize: 30, // 设置字体大小
            ),
          ),
        ),
        Divider(
          color: AppColors.lightNavyBlue, // 设置分割线颜色
        ),
        Expanded( // 扩展以填充剩余空间
          child: SingleChildScrollView( // 单子项滚动视图
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 设置填充值
            child: Column( // 嵌套列部件
              mainAxisSize: MainAxisSize.min, // 设置主轴尺寸为最小
              crossAxisAlignment: CrossAxisAlignment.start, // 设置交叉轴对齐方式为左对齐
              children: [
                Text(
                  "Active View:", // 显示文本
                  style: TextStyle(
                    fontSize: 20.0, // 设置字体大小
                    color: AppColors.black, // 设置文字颜色
                  ),
                ),
                Wrap( // 使用Wrap包裹视图选项
                  children: List.generate( // 生成视图选项列表
                    CalendarView.values.length, // 根据视图选项数量生成
                        (index) {
                      final view = CalendarView.values[index]; // 获取当前视图
                      return GestureDetector( // 手势检测器
                        onTap: () => onViewChange(view), // 绑定点击事件
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 40,
                          ),
                          margin: EdgeInsets.only(
                            right: 20,
                            top: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7), // 设置圆角
                            color: view == currentView // 根据当前视图设置颜色
                                ? AppColors.navyBlue
                                : AppColors.bluishGrey,
                          ),
                          child: Text(
                            view.name.capitalized, // 显示视图名称
                            style: TextStyle(
                              color: view == currentView // 根据当前视图设置文字颜色
                                  ? AppColors.white
                                  : AppColors.black,
                              fontSize: 17, // 设置字体大小
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 40, // 设置高度
                ),
                Text(
                  "Add Event: ", // 显示文本
                  style: TextStyle(
                    fontSize: 20.0, // 设置字体大小
                    color: AppColors.black, // 设置文字颜色
                  ),
                ),
                SizedBox(
                  height: 20, // 设置高度
                ),
                AddOrEditEventForm( // 添加或编辑事件表单
                  onEventAdd: (event) { // 事件添加回调
                    CalendarControllerProvider.of(context)
                        .controller
                        .add(event); // 向日历控制器添加事件
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
