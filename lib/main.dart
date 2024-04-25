import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // 修改此处为正确的类名
      routes: {
        '/home': (BuildContext context) => HomePage(), // 修改此处为正确的类名
        '/job': (BuildContext context) => JobPage(), //
        '/staff': (BuildContext context) => StaffPage(), //
        '/transaction': (BuildContext context) => TransactionPage(), //
      },
    );
  }
}

class JobPage extends StatelessWidget {
  //工作管理界面
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("工作管理界面"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('关闭'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}

class StaffPage extends StatelessWidget {
  //人员管理界面

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("人员管理界面"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('关闭'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}

class TransactionPage extends StatelessWidget {
  //事务管理界面

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("事务管理界面"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('关闭'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}

// 类名应以大写字母开头
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _notes = [];
  @override
  Widget build(BuildContext context) {
    void _addNote() {
      if (_textController.text.trim().isNotEmpty) {
        setState(() {
          _notes.add(_textController.text.trim());
          _textController.clear();
        });
      }
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event_note_outlined)),
              Tab(icon: Icon(Icons.edit_note)),
              Tab(icon: Icon(Icons.directions_bike)),
              Tab(icon: Icon(Icons.directions_boat_rounded)),
            ],
          ),
          backgroundColor: Colors.blue,
          title: Text('学生兼职管理系统'),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ],
        ),
        body: TabBarView(
          children: [
            Center(
                child: Column(
              children: [
                Container(
                  width: 200,
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: Card(
                    child: Center(
                      child: Text(
                        '信息管理',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    color: Colors.yellow,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(15),
                  height: 100,
                  width: double.infinity,
                  color: Colors.cyan,
                  child: TextButton(
                    onPressed: () {
                      print('工作管理');
                      Navigator.of(context).pushNamed('/job');
                    },
                    child: Text(
                      '工作管理',
                      style: TextStyle(color: Colors.red, fontSize: 30),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(15),
                  height: 100,
                  width: double.infinity,
                  color: Colors.cyan,
                  child: TextButton(
                    onPressed: () {
                      print('人员管理');
                      Navigator.of(context).pushNamed('/staff');
                    },
                    child: Text(
                      '人员管理',
                      style: TextStyle(color: Colors.red, fontSize: 30),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(15),
                  height: 100,
                  width: double.infinity,
                  color: Colors.cyan,
                  child: TextButton(
                    onPressed: () {
                      print('事务管理');
                      Navigator.of(context).pushNamed('/transaction');
                    },
                    child: Text(
                      '事务管理',
                      style: TextStyle(color: Colors.red, fontSize: 30),
                    ),
                  ),
                )
              ],
            )),
            Container(
                color: Colors.yellow.shade100,
                child: Center(
                    child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 50,
                      margin: EdgeInsets.only(top: 10),
                      child: Card(
                        child: Center(
                          child: Text(
                            '日志',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        color: Colors.yellow,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '在这输入:',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _addNote,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_notes[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _notes.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ))),
            Center(child: Text("Bike")),
            Container(
                child: Center(
                    child: Column(
              children: [
                Container(
                  child: Text('Language'),
                )
              ],
            ))),
          ],
        ),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: const <Widget>[
          UserAccountsDrawerHeader(
            //用户账户抽屉头
            accountName: Text("Liu Yu"), //账户名称
            accountEmail: Text("xxxxxxyahoo.co.jp"), //账户邮箱
            currentAccountPicture: CircleAvatar(
              //当前帐户图片:圈子头像
              backgroundImage: AssetImage('images/panda.png'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
          ),
        ])),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "主页",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: "消息",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: "个人信息",
            ),
          ],
        ),
      ),
    );
  }
}

class MyVolumeButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyVolumeButtonState();
  }
}

class MyVolumeButtonState extends State<MyVolumeButton> {
  bool volumeOn = true;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: volumeOn ? Icon(Icons.volume_up) : Icon(Icons.volume_mute),
      onPressed: () {
        setState(() => volumeOn = !volumeOn);
      },
    );
  }
}
