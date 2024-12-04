import 'package:flutter/material.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      child:

          /// Home page
          Card(
        shadowColor: Colors.transparent, // 卡片阴影颜色。
        margin: const EdgeInsets.all(8.0), // 卡片外边距。
        child: SizedBox.expand(
          child: Center(
// 中心对齐的容器
              child: Column(
// 竖直排列的子组件
            children: [
              // Container(
              //   width: 200,
              //   height: 50,
              //   margin: EdgeInsets.only(top: 10),
              //   child: Card(
              //     child: Center(
              //       child: Text(
              //         '情報管理', // 文本内容
              //         style: TextStyle(fontSize: 20), // 文本样式
              //       ),
              //     ),
              //     color: Colors.yellow, // 卡片颜色
              //   ),
              // ),
              Container(
                padding: EdgeInsets.all(20),
                // 内边距
                margin: EdgeInsets.all(15),
                // 外边距
                height: 100,
                // 高度
                width: double.infinity,
                // 宽度
                color: Colors.cyan,
                // 背景颜色
                child: TextButton(
                  onPressed: () {
                    print('仕事管理'); // 控制台输出
                    Navigator.of(context).pushNamed('/job'); // 导航至工作页面
                  },
                  child: Text(
                    '仕事管理', // 按钮文本
                    style: TextStyle(color: Colors.red, fontSize: 30), // 文本样式
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(20),
                // 内边距
                margin: EdgeInsets.all(15),
                // 外边距
                height: 100,
                // 高度
                width: double.infinity,
                // 宽度
                color: Colors.cyan,
                // 背景颜色
                child: TextButton(
                  onPressed: () {
                    print('管理ツール'); // 控制台输出
                    Navigator.of(context)
                        .pushNamed('/management_tools'); // 导航至交易页面
                  },
                  child: Text(
                    '管理ツール', // 按钮文本
                    style: TextStyle(color: Colors.red, fontSize: 30), // 文本样式
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                // 内边距
                margin: EdgeInsets.all(15),
                // 外边距
                height: 100,
                // 高度
                width: double.infinity,
                // 宽度
                color: Colors.cyan,
                // 背景颜色
                child: TextButton(
                  onPressed: () {
                    print('そのほか'); // 控制台输出
                    Navigator.of(context).pushNamed('/othersApplication'); // 导航至员工页面
                  },
                  child: Text(
                    'そのほか', // 按钮文本
                    style: TextStyle(color: Colors.red, fontSize: 30), // 文本样式
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
