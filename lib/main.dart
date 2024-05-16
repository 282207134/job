import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:introduction_screen/introduction_screen.dart'; // 导入引导屏幕包
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'LoginPageState.dart';
import 'OnBoardingPageState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlutterSplashScreen.fadeIn(
        backgroundColor: Colors.cyan,
        duration: Duration(seconds: 5),
        animationDuration: Duration(seconds: 10),
        onInit: () {
          debugPrint("On Init");
        },
        onEnd: () {
          debugPrint("On End");
        },
        childWidget: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset("assets/0.jpg"),
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"),
        nextScreen: OnBoardingPage(),
      ),
      routes: {
        '/login': (BuildContext context) => LoginPage(),
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
        title: Text("仕事管理"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('閉じる'),
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
        title: Text("スタッフ管理"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('閉じる'),
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
        title: Text("事務管理"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('閉じる'),
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
          title: Text('学生アルバイト管理システム'),
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
                        '情報管理',
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
                      print('仕事管理');
                      Navigator.of(context).pushNamed('/job');
                    },
                    child: Text(
                      '仕事管理',
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
                      print('スタッフ管理');
                      Navigator.of(context).pushNamed('/staff');
                    },
                    child: Text(
                      'スタッフ管理',
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
                      print('事務管理');
                      Navigator.of(context).pushNamed('/transaction');
                    },
                    child: Text(
                      '事務管理',
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
                            'ログ',
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
                          labelText: 'ここで入力:',
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
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("settings"),
          ),
        ])),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "ホーム",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: "メッセージ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: "個人情報",
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          onPressed: () {
            print('点击悬浮按钮');
          },
          backgroundColor: Colors.red,
          splashColor: Colors.yellow,
          foregroundColor: Colors.deepPurple,
          hoverColor: Colors.green,
          tooltip: "ここで新たなボタンを追加する",
          label: Text('添付'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
