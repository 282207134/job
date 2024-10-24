import 'package:flutter/material.dart'; // 导入Flutter的材料设计包

import '../app_colors.dart'; // 导入应用程序颜色

class CustomButton extends StatelessWidget { // 定义一个名为CustomButton的无状态小部件
  final String title; // 定义按钮标题
  final VoidCallback? onTap; // 定义点击回调函数

  const CustomButton({super.key, required this.title, this.onTap}); // 构造函数，初始化标题和点击回调

  @override
  Widget build(BuildContext context) { // 构建部件的UI
    return GestureDetector( // 返回一个手势检测器
      onTap: onTap, // 绑定点击事件
      child: Container( // 容器部件
        padding: EdgeInsets.symmetric( // 设置填充值
          vertical: 10,
          horizontal: 40,
        ),
        decoration: BoxDecoration( // 设置装饰
          color: AppColors.navyBlue, // 背景颜色
          borderRadius: BorderRadius.circular(7.0), // 圆角半径
          boxShadow: [ // 阴影效果
            BoxShadow(
              color: AppColors.black, // 阴影颜色
              offset: Offset(0, 4), // 偏移量
              blurRadius: 10, // 模糊半径
              spreadRadius: -3, // 扩散半径
            )
          ],
        ),
        child: Text( // 文本部件
          title, // 显示标题
          style: TextStyle(
            color: AppColors.white, // 文字颜色
            fontSize: 10, // 字体大小
          ),
        ),
      ),
    );
  }
}
