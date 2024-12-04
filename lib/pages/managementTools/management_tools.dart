import 'package:flutter/material.dart';

class management_tools extends StatelessWidget {
  //管理ツール界面

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("管理ツール"),
        ),
        body: GridView.count(crossAxisCount: 2, children: [          Container(
          color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: IconButton(
                  onPressed: () {
                    print('学園祭用会計'); // 控制台输出
                    Navigator.of(context).pushNamed('/schoolFestivalAccount'); // 导航至工作页面
                  },
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.lightBlue,
                    size: 100.0,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "学園祭用会計",
                  style: TextStyle(color: Colors.lightBlue, fontSize: 20),
                ),
              )
            ],
          ),
        ),
          // Container(
          //   color: Colors.amber,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Center(
          //         child: IconButton(
          //           onPressed: () {
          //             print('会計'); // 控制台输出
          //             Navigator.of(context).pushNamed('/account'); // 导航至工作页面
          //           },
          //           icon: Icon(
          //             Icons.account_balance_wallet_outlined,
          //             color: Colors.lightBlue,
          //             size: 100.0,
          //           ),
          //         ),
          //       ),
          //       Center(
          //         child: Text(
          //           "会計",
          //           style: TextStyle(color: Colors.lightBlue, fontSize: 20),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          Container(
            color: Colors.greenAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "タイマー",
                    style: TextStyle(color: Colors.pink, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      size: 100.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "メモ",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                )
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
        ]));
  }
}
