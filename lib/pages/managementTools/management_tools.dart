import 'package:flutter/material.dart';

class management_tools extends StatelessWidget {
  //管理ツール界面

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("管理ツール"),
        ),
        body: GridView.count(crossAxisCount: 2, children: [
          Container(
            color: Colors.greenAccent,
            child: Column(
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('タイマー'); // 控制台输出
                      Navigator.of(context).pushNamed('/timer'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.timer,
                      color: Colors.pink,
                      size: 160.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.blue,
            child: Column(
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('メモ'); // 控制台输出
                      Navigator.of(context).pushNamed('/note'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.edit_note,
                      color: Colors.amber,
                      size: 160.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.white,
          ),
          Container(
            color: Colors.amber,
          ),
          Container(
            color: Colors.deepPurple,
          ),
          Container(
            color: Colors.cyanAccent,
          ),
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.white,
          ),
          Container(
            color: Colors.amber,
          ),
          Container(
            color: Colors.deepPurple,
          ),
          Container(
            color: Colors.cyanAccent,
          ),
        ]));
  }
}
