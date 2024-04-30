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
      home: LoginPage(), // 修改此处为正确的类名
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // 表单的全局键
  String _username = ''; // 用户名字符串
  String _password = ''; // 密码字符串

  void _login() {
    if (_formKey.currentState!.validate()) {
      // 如果表单验证通过
      _formKey.currentState!.save(); // 保存表单状态

      // 检查凭据是否正确
      if (_username == 'liuyu' && _password == '123456') {
        // 导航到MyHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("登録")),
      ), // 页面顶部的应用栏
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0), // 内边距
          child: Column(
            children: [
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Username'), // 用户名输入框
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username'; // 验证输入内容
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value!, // 保存输入内容
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.all(20),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Password'), // 密码输入框
                  obscureText: true, // 隐藏输入内容
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'; // 验证输入内容
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!, // 保存输入内容
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _login, // 登录按钮
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
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
