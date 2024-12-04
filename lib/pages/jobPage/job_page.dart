import 'package:flutter/material.dart';


class JobPage extends StatelessWidget {
  //工作管理界面
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("仕事管理"),
        ),
        body: GridView.count(crossAxisCount: 2, mainAxisSpacing: 0, children: [
          Container(
            color: Colors.greenAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('カレンダー'); // 控制台输出
                      Navigator.of(context).pushNamed('/calendar'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      color: Colors.pink,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "シフト管理",
                    style: TextStyle(color: Colors.pink, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.lightBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('スタッフ管理'); // 控制台输出
                      Navigator.of(context).pushNamed('/futureVision'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.perm_contact_cal,
                      color: Colors.amberAccent,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "スタッフ管理",
                    style: TextStyle(color: Colors.amberAccent, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.green,
          ),
          Container(
            color: Colors.amber,
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
