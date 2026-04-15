import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库

class CommonMethods // 通用方法类
{
  Widget header(int headerFlexValue, String headerTitle) // 创建头部组件的方法
  {
    return Expanded( // 返回一个 Expanded 组件
      flex: headerFlexValue, // 设置弹性系数
      child: Container( // 容器组件
        decoration: BoxDecoration( // 装饰属性
          border: Border.all(color: Colors.black), // 黑色边框
          color: Colors.pink.shade500, // 粉色背景
        ),
        child: Padding( // 内边距组件
          padding: const EdgeInsets.all(10.0), // 四周 10 像素的内边距
          child: Text( // 文本组件
            headerTitle, // 显示的标题文本
            style: const TextStyle( // 文本样式
              color: Colors.white, // 白色文字
            ),
          ),
        ),
      ),
    );
  }

  Widget data(int dataFlexValue, Widget widget) // 创建数据组件的方法
  {
    return Expanded( // 返回一个 Expanded 组件
      flex: dataFlexValue, // 设置弹性系数
      child: Container( // 容器组件
        decoration: BoxDecoration( // 装饰属性
          border: Border.all(color: Colors.grey), // 灰色边框
        ),
        child: Padding( // 内边距组件
          padding: const EdgeInsets.all(10.0), // 四周 10 像素的内边距
          child: widget, // 传入的子组件
        ),
      ),
    );
  }
}