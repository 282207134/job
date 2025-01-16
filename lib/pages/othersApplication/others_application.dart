import 'package:flutter/material.dart';


class othersApplication extends StatelessWidget {
  //工作管理界面
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("そのほかのアプリ"),
        ),
        body: GridView.count(crossAxisCount: 2, mainAxisSpacing: 0, children: [
          Container(
            color: Colors.yellow,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('進路選択'); // 控制台输出
                      Navigator.of(context).pushNamed('/futureVision'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.straight,
                      color: Colors.red,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "進路選択",
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('骰子'); // 控制台输出
                      Navigator.of(context).pushNamed('/dicee'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.casino_outlined,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "骰子",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('ピアノ'); // 控制台输出
                      Navigator.of(context).pushNamed('/piano'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.piano,
                      color: Colors.black,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "ピアノ",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.deepPurple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('抽選'); // 控制台输出
                      Navigator.of(context).pushNamed('/draw'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.question_mark,
                      color: Colors.green,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "抽選",
                    style: TextStyle(color: Colors.green, fontSize: 20),
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
            color: Colors.lightBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      print('TestPage2'); // 控制台输出
                      Navigator.of(context).pushNamed('/testpage2'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.add_to_drive,
                      color: Colors.red,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "testpage2",
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
                  child: Text(
                    "testpage2",
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
                      print('TestPage'); // 控制台输出
                      Navigator.of(context).pushNamed('/testpage'); // 导航至工作页面
                    },
                    icon: Icon(
                      Icons.add_to_drive,
                      color: Colors.red,
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "testpage",
                    style: TextStyle(color: Colors.pink, fontSize: 20),
                  ),
                )
              ],
            ),
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
