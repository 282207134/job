import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包

import 'app_colors.dart'; // 导入 app_colors.dart 文件

class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  static OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(7), // 圆角半径为 7
    borderSide: BorderSide(
      width: 2, // 边框宽度为 2
      color: AppColors.lightNavyBlue, // 边框颜色为浅海军蓝
    ),
  );

  static InputDecoration get inputDecoration => InputDecoration(
    border: inputBorder, // 默认边框
    disabledBorder: inputBorder, // 禁用时的边框
    errorBorder: inputBorder.copyWith(
      borderSide: BorderSide(
        width: 2, // 边框宽度为 2
        color: AppColors.red, // 错误状态下的边框颜色为红色
      ),
    ),
    enabledBorder: inputBorder, // 启用时的边框
    focusedBorder: inputBorder, // 聚焦时的边框
    focusedErrorBorder: inputBorder, // 聚焦且出错时的边框
    hintText: "Event Title", // 提示文本
    hintStyle: TextStyle(
      color: AppColors.black, // 提示文本颜色为黑色
      fontSize: 17, // 提示文本字体大小为 17
    ),
    labelStyle: TextStyle(
      color: AppColors.black, // 标签文本颜色为黑色
      fontSize: 17, // 标签文本字体大小为 17
    ),
    helperStyle: TextStyle(
      color: AppColors.black, // 帮助文本颜色为黑色
      fontSize: 17, // 帮助文本字体大小为 17
    ),
    errorStyle: TextStyle(
      color: AppColors.red, // 错误文本颜色为红色
      fontSize: 12, // 错误文本字体大小为 12
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 10, // 垂直内边距为 10
      horizontal: 20, // 水平内边距为 20
    ),
  );
}

class BreakPoints {
  static const double web = 800; // Web 断点宽度为 800
}
