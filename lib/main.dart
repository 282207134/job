import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // 导入自定义的启动屏库
import 'package:firebase_auth/firebase_auth.dart'; // 导入Firebase认证库
import 'package:flutter/material.dart'; // 导入Flutter材质设计组件库
import 'package:flutter/src/widgets/framework.dart'; // 导入Flutter的基础widget框架
import 'package:flutter/src/widgets/placeholder.dart'; // 导入Flutter的占位符组件库
import 'package:firebase_core/firebase_core.dart'; // 导入Firebase核心库
import 'package:job/pages/googleMap/MyGoogleMap.dart';
// import 'package:job/pages/GoogleMap/MyGoogleMap.dart';
import 'package:job/pages/managementTools/management_tools.dart';
import 'package:job/pages/managementTools/timer.dart';
import 'package:job/pages/managementTools/note.dart';
import 'package:job/pages/notification/notification.dart';
import 'package:job/providers/userProvider.dart'; // 导入自定义的用户状态管理库
import 'package:job/screens/chatroom_screen.dart';
import 'package:job/screens/profile_screen.dart'; // 导入用户资料页面
import 'package:provider/provider.dart'; // 导入状态管理库
// import 'button/note_button.dart';
import 'firebase_options.dart'; // 导入Firebase配置选项
import 'screens/splash_screen.dart'; // 导入应用的启动屏页面
import 'screens/login_screen.dart'; // 导入登录页面
import 'splashScreen/OnBoardingPageState.dart'; // 导入引导页面状态
import 'package:job/pages/jobPage/job_page.dart'; // 导入工作页面
import 'package:job/pages/staffPage/staff_page.dart'; // 导入员工页面
// import 'package:job/pages/transaction_page.dart'; // 导入交易页面
import 'package:job/pages/home/home.dart';
// import 'package:job/pages/messages.dart';
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
        '/management_tools': (BuildContext context) => management_tools(), // 交易页面路由
        '/note': (BuildContext context) => note(),
        '/timer': (BuildContext context) => timer(),
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

  int currentPageIndex = 0; // 当前选中的页面索引。

  @override
  Widget build(BuildContext context) {
    // 构建方法

    var userProvider = Provider.of<UserProvider>(context); // 获取用户状态
    final ThemeData theme = Theme.of(context); // 获取当前主题数据。
    // 初始悬浮按钮位置
    // Offset position = Offset(100, 100);

    return DefaultTabController(
      // 创建带有标签控制的Scaffold
      length: 4, // 标签数量
      child: Scaffold(
        backgroundColor: Colors.cyanAccent, // 背景颜色
        appBar: AppBar(
          backgroundColor: Colors.blue, // 应用栏背景颜色
          title: Text('管理システム'), // 应用栏标题
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}), // 应用栏按钮
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index; // 更新当前页面索引。
            });
          },
          indicatorColor: Colors.amber, // 设置指示器颜色为琥珀色。
          selectedIndex: currentPageIndex, // 设置选中的索引。
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home), // 选中时的图标。
              icon: Icon(Icons.home_outlined), // 未选中时的图标。
              label: 'Home', // 标签。
            ),
            NavigationDestination(
              icon:
              Badge(child: Icon(Icons.map_outlined)), // 使用徽章包裹的通知图标。
              label: 'GoogleMap', // 标签。
            ),
            NavigationDestination(
              icon:
              Badge(child: Icon(Icons.notifications_sharp)), // 使用徽章包裹的通知图标。
              label: 'Notifications', // 标签。
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('2'), // 徽章标签。
                child: Icon(Icons.messenger_sharp), // 信息图标。
              ),
              label: 'Messages', // 标签。
            ),
          ],
        ),

        body: <Widget>[
          home(),
          MyGoogleMap(),

          notification(),
          ChatroomScreen(
            chatroomName: '',
            chatroomId: '',
          ),
        ][currentPageIndex], // 根据当前页面索引显示相应页面。

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

        // floatingActionButton: Draggable(
        //   feedback: FloatingActionButton.extended(
        //     icon: Icon(Icons.add),
        //     label: Text('ノート'),
        //     onPressed: () {
        //       print('点击悬浮按钮');
        //       NoteButton();
        //       Navigator.of(context).pushNamed('/note');
        //     },
        //     backgroundColor: Colors.red
        //         .withOpacity(0.5), // Set opacity to 0.5 for semi-transparency
        //     foregroundColor: Colors.deepPurple,
        //   ),
        //   child: FloatingActionButton.extended(
        //     icon: Icon(Icons.note),
        //     label: Text('ノート'),
        //     onPressed: () {
        //       Navigator.of(context).pushNamed('/note');
        //     },
        //     backgroundColor: Colors.red
        //         .withOpacity(0.5), // Set opacity to 0.5 for semi-transparency
        //     foregroundColor: Colors.deepPurple,
        //   ),
        //   childWhenDragging:
        //       Container(), // Display an empty container when the button is being dragged.
        // ),
      ),
    );
  }
}
