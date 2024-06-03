import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // 导入自定义的启动屏库
import 'package:firebase_auth/firebase_auth.dart'; // 导入Firebase认证库
import 'package:flutter/material.dart'; // 导入Flutter材质设计组件库
import 'package:flutter/src/widgets/framework.dart'; // 导入Flutter的基础widget框架
import 'package:flutter/src/widgets/placeholder.dart'; // 导入Flutter的占位符组件库
import 'package:firebase_core/firebase_core.dart'; // 导入Firebase核心库
import 'package:job/providers/userProvider.dart'; // 导入自定义的用户状态管理库
import 'package:job/screens/profile_screen.dart'; // 导入用户资料页面
import 'package:provider/provider.dart'; // 导入状态管理库
import 'firebase_options.dart'; // 导入Firebase配置选项
import 'screens/splash_screen.dart'; // 导入应用的启动屏页面
import 'screens/login_screen.dart'; // 导入登录页面
import 'splashScreen/OnBoardingPageState.dart'; // 导入引导页面状态
import 'package:job/pages/job_page.dart'; // 导入工作页面
import 'package:job/pages/message.dart'; // 导入消息页面
import 'package:job/pages/staff_page.dart'; // 导入员工页面
import 'package:job/pages/transaction_page.dart'; // 导入交易页面
import 'package:job/screens/login_screen.dart'; // 重复导入登录页面（注意可能的重复导入）

class MyApp extends StatefulWidget {
  // 定义有状态的应用主类
  const MyApp({super.key}); // 构造函数，接受一个可选的key参数

  @override
  State<MyApp> createState() => _MyAppState(); // 创建状态
}

class _MyAppState extends State<MyApp> {
  // 定义应用的状态类
  @override
  Widget build(BuildContext context) {
    // 构建方法
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 不显示debug标签
      home: FlutterSplashScreen.fadeIn(
        // 使用自定义的SplashScreen
        backgroundColor: Colors.cyan, // 背景颜色
        duration: Duration(seconds: 5), // 显示时长
        animationDuration: Duration(seconds: 10), // 动画时长
        onInit: () {
          debugPrint("On Init"); // 初始化时的回调
        },
        onEnd: () {
          debugPrint("On End"); // 结束时的回调
        },
        childWidget: SizedBox(
          // 显示的widget
          height: double.infinity,
          width: double.infinity,
          child: Image.asset("assets/0.jpg"), // 显示的图片
        ),
        onAnimationEnd: () => debugPrint("On Fade In End"), // 动画结束时的回调
        nextScreen: OnBoardingPage(), // 动画结束后跳转的页面
      ),
      routes: {
        // 定义路由
        '/login': (BuildContext context) => SplashScreen(), // 登录路由
        '/home': (BuildContext context) => HomePage(), // 首页路由
        '/job': (BuildContext context) => JobPage(), // 工作页面路由
        '/staff': (BuildContext context) => StaffPage(), // 员工页面路由
        '/transaction': (BuildContext context) => TransactionPage(), // 交易页面路由
      },
    );
  }
}

Future<void> main() async {
  // 主函数，异步执行
  WidgetsFlutterBinding.ensureInitialized(); // 初始化Flutter绑定
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // 初始化Firebase
  runApp(ChangeNotifierProvider(
      // 运行应用
      create: (context) => UserProvider(), // 创建用户状态管理
      child: MyApp())); // 应用的主Widget
}

class HomePage extends StatefulWidget {
  // 定义有状态的首页类
  const HomePage({Key? key}) : super(key: key); // 构造函数，接受一个可选的key参数

  @override
  State<HomePage> createState() => _HomePageState(); // 创建状态
}

class _HomePageState extends State<HomePage> {
  // 定义首页的状态类
  final TextEditingController _textController =
      TextEditingController(); // 文本控制器
  final List<String> _notes = []; // 笔记列表

  @override
  Widget build(BuildContext context) {
    // 构建方法
    void _addNote() {
      if (_textController.text.trim().isNotEmpty) {
        // 判断输入内容非空
        setState(() {
          _notes.add(_textController.text.trim()); // 添加到笔记列表
          _textController.clear(); // 清空输入框
        });
      }
    }

    var userProvider = Provider.of<UserProvider>(context); // 获取用户状态

    return DefaultTabController(
      // 创建带有标签控制的Scaffold
      length: 4, // 标签数量
      child: Scaffold(
        backgroundColor: Colors.cyanAccent, // 背景颜色
        appBar: AppBar(
          // 顶部应用栏
          bottom: TabBar(
            // 标签栏
            tabs: [
              Tab(icon: Icon(Icons.event_note_outlined)), // 标签项
              Tab(icon: Icon(Icons.edit_note)), // 标签项
              Tab(icon: Icon(Icons.directions_bike)), // 标签项
              Tab(icon: Icon(Icons.directions_boat_rounded)), // 标签项
            ],
          ),
          backgroundColor: Colors.blue, // 应用栏背景颜色
          title: Text('管理システム'), // 应用栏标题
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}), // 应用栏按钮
          ],
        ),
        body: TabBarView(
          // 标签视图内容
          children: [
            Center(
                // 中心对齐的容器
                child: Column(
              // 竖直排列的子组件
              children: [
                Container(
                  width: 200,
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: Card(
                    child: Center(
                      child: Text(
                        '情報管理', // 文本内容
                        style: TextStyle(fontSize: 20), // 文本样式
                      ),
                    ),
                    color: Colors.yellow, // 卡片颜色
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20), // 内边距
                  margin: EdgeInsets.all(15), // 外边距
                  height: 100, // 高度
                  width: double.infinity, // 宽度
                  color: Colors.cyan, // 背景颜色
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
                  padding: EdgeInsets.all(20), // 内边距
                  margin: EdgeInsets.all(15), // 外边距
                  height: 100, // 高度
                  width: double.infinity, // 宽度
                  color: Colors.cyan, // 背景颜色
                  child: TextButton(
                    onPressed: () {
                      print('スタッフ管理'); // 控制台输出
                      Navigator.of(context).pushNamed('/staff'); // 导航至员工页面
                    },
                    child: Text(
                      'スタッフ管理', // 按钮文本
                      style: TextStyle(color: Colors.red, fontSize: 30), // 文本样式
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20), // 内边距
                  margin: EdgeInsets.all(15), // 外边距
                  height: 100, // 高度
                  width: double.infinity, // 宽度
                  color: Colors.cyan, // 背景颜色
                  child: TextButton(
                    onPressed: () {
                      print('事務管理'); // 控制台输出
                      Navigator.of(context)
                          .pushNamed('/transaction'); // 导航至交易页面
                    },
                    child: Text(
                      '事務管理', // 按钮文本
                      style: TextStyle(color: Colors.red, fontSize: 30), // 文本样式
                    ),
                  ),
                )
              ],
            )),
            Container(
                color: Colors.yellow.shade100, // 背景颜色
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
                            'ログ', // 文本内容
                            style: TextStyle(fontSize: 20), // 文本样式
                          ),
                        ),
                        color: Colors.yellow, // 卡片颜色
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textController, // 文本控制器
                        decoration: InputDecoration(
                          border: OutlineInputBorder(), // 边框样式
                          labelText: 'ここで入力:', // 标签文本
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add), // 图标
                            onPressed: _addNote, // 点击事件
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notes.length, // 列表项数
                        itemBuilder: (context, index) {
                          // 构建列表项
                          return ListTile(
                            title: Text(_notes[index]), // 标题文本
                            trailing: IconButton(
                              icon: Icon(Icons.delete), // 图标
                              onPressed: () {
                                setState(() {
                                  _notes.removeAt(index); // 删除指定项
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ))),
            Center(child: Text("Bike")), // 中心文本
            Container(
                child: Center(
                    child: Column(
              children: [
                Container(
                  child: Text('Language'), // 文本内容
                )
              ],
            ))),
          ],
        ),
        drawer: Drawer(
            child: Container(
                child: Column(children: [
          SizedBox(height: 50), // 大小盒子
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfileScreen(); // 导航至个人资料页面
              }));
            },
            leading: CircleAvatar(
                child: Text(userProvider.userName.isNotEmpty
                    ? userProvider.userName[0]
                    : 'N')), // 圆形头像
            title: Text(
                userProvider.userName.isNotEmpty
                    ? userProvider.userName
                    : 'No name available', // 名称文本
                style: TextStyle(fontWeight: FontWeight.bold)), // 文本样式
            subtitle: Text(userProvider.userEmail.isNotEmpty
                ? userProvider.userEmail
                : 'No email available'), // 邮件文本
          ),
          ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProfileScreen(); // 导航至个人资料页面
                }));
              },
              leading: Icon(Icons.people), // 图标
              title: Text("個人情報")), // 标题文本
          ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // Firebase登出
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return SplashScreen(); // 导航至启动屏
                }), (route) => false);
              },
              leading: Icon(Icons.logout), // 图标
              title: Text("Logout")) // 标题文本
        ]))),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // 图标
              label: "ホーム", // 标签
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail), // 图标
              label: "メッセージ", // 标签
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle), // 图标
              label: "個人情報", // 标签
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   icon: Icon(Icons.add),
        //   onPressed: () {
        //     print('点击悬浮按钮');
        //   },
        //   backgroundColor: Colors.red,
        //   splashColor: Colors.yellow,
        //   foregroundColor: Colors.deepPurple,
        //   hoverColor: Colors.green,
        //   tooltip: "ここで新たなボタンを追加する",
        //   label: Text('添付'),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(5),
        //   ),
        // ),
      ),
    );
  }
}
