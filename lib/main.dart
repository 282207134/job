import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:introduction_screen/introduction_screen.dart'; // 导入引导屏幕包

void main() {
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

class OnBoardingPage extends StatefulWidget {
  // 引导页类
  const OnBoardingPage({Key? key}) : super(key: key); // 构造函数

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState(); // 创建状态
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  // 引导页状态类
  final introKey = GlobalKey<IntroductionScreenState>(); // 引导屏幕的全局键

  void _onIntroEnd(BuildContext context) {
    // 引导结束处理函数
    Navigator.of(context).pushReplacement(
      // 替换导航路由
      MaterialPageRoute(builder: (_) => LoginPage()), // 跳转到主页
    );
  }

  Widget _buildFullscreenImage(int index) {
    // 构建全屏图像
    return Image.asset(
      // 图像小部件
      'assets/$index.jpg', // 图像路径
      fit: BoxFit.cover, // 图像填充方式
      height: double.infinity, // 高度充满屏幕
      width: double.infinity, // 宽度充满屏幕
      alignment: Alignment.center, // 图像居中对齐
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    // 构建图像
    return Image.asset('assets/$assetName', width: width); // 图像小部件
  }

  @override
  Widget build(BuildContext context) {
    // 构建函数
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.white); // 正文样式

    var pageDecoration = PageDecoration(
      // 页面装饰
      titleTextStyle: TextStyle(
          // 标题文本样式
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: Colors.white),
      bodyTextStyle: bodyStyle, // 正文文本样式
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), // 正文内边距
      pageColor: null, // 页面颜色为null
      boxDecoration: BoxDecoration(
        // 盒子装饰
        color: Colors.black.withOpacity(0.5), // 背景颜色为半透明黑色
        borderRadius: BorderRadius.circular(10), // 圆角
      ),
      imagePadding: EdgeInsets.zero, // 图像内边距
    );

    return IntroductionScreen(
      // 引导屏幕小部件
      key: introKey, // 全局键
      globalBackgroundColor: Colors.white, // 全局背景颜色
      allowImplicitScrolling: true, // 允许隐式滚动
      autoScrollDuration: 5000, // 自动滚动持续时间
      infiniteAutoScroll: true, // 无限自动滚动
      pages: [
        // 页面列表
        PageViewModel(
          // 页面视图模型
          title: "便利性", // 标题
          body: "気軽いスタッフを管理できます.", // 正文
          image: _buildFullscreenImage(1), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
        PageViewModel(
          // 页面视图模型
          title: "安全性", // 标题
          body: "個人情報を漏洩を防ぐ.", // 正文
          image: _buildFullscreenImage(2), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
        PageViewModel(
          // 页面视图模型
          title: "可用性", // 标题
          body: "いつ、どこでも使います.", // 正文
          image: _buildFullscreenImage(3), // 图像
          decoration: pageDecoration.copyWith(
            // 页面装饰
            fullScreen: true, // 全屏
            bodyFlex: 2, // 正文弹性比例
            imageFlex: 3, // 图像弹性比例
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context), // 完成时的回调函数
      done: const Text('开始使用', // 完成按钮文本
          style:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.cyanAccent)),
      showNextButton: true, // 显示下一个按钮
      next: const Icon(
        // 下一个按钮
        Icons.arrow_forward,
        color: Colors.cyanAccent, // 图标颜色
      ),
      showSkipButton: true, // 显示跳过按钮
      skip: const Text(
        // 跳过按钮文本
        '跳过',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.cyanAccent),
      ),
      onSkip: () => _onIntroEnd(context), // 跳过时的回调函数
      curve: Curves.fastLinearToSlowEaseIn, // 动画曲线
      controlsMargin: const EdgeInsets.all(16), // 控制按钮外边距
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0), // 控制按钮内边距
      dotsDecorator: const DotsDecorator(
        // 点装饰
        size: Size(10.0, 10.0), // 大小
        color: Colors.white, // 颜色
        activeSize: Size(22.0, 10.0), // 激活大小
        activeShape: RoundedRectangleBorder(
          // 激活形状
          borderRadius: BorderRadius.all(Radius.circular(25.0)), // 圆角
        ),
      ),
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
        title: Center(child: Text("ログイン")),
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
                  decoration: InputDecoration(labelText: 'ユーザ'), // 用户名输入框
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ユーザを入力してください'; // 验证输入内容
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value!, // 保存输入内容
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.all(20),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'パスワード'), // 密码输入框
                  obscureText: true, // 隐藏输入内容
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください'; // 验证输入内容
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
                  child: Text('確認する'),
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
