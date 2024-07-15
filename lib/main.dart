import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:job/pages/jobPage/calendarView/calendar.dart';
import 'package:job/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:job/pages/googleMap/MyGoogleMap.dart';
import 'package:job/pages/managementTools/Xylophone.dart';
import 'package:job/pages/managementTools/account.dart';
import 'package:job/pages/managementTools/dicee.dart';
import 'package:job/pages/managementTools/management_tools.dart';
import 'package:job/pages/managementTools/randomPerson.dart';
import 'package:job/pages/managementTools/timer.dart';
import 'package:job/pages/managementTools/note.dart';
import 'package:job/pages/notification/notification.dart';
import 'package:job/providers/userProvider.dart';
import 'package:job/screens/chatroom_screen.dart';
import 'package:job/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'splashScreen/OnBoardingPageState.dart';
import 'package:job/pages/jobPage/job_page.dart';
import 'package:job/pages/staffPage/staff_page.dart';
import 'package:job/pages/home/home.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomePage();
          } else {
            return FlutterSplashScreen.fadeIn(
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
            );
          }
        },
      ),
      routes: {
        '/login': (BuildContext context) => LoginScreen(),
        '/home': (BuildContext context) => HomePage(),
        '/job': (BuildContext context) => JobPage(),
        '/staff': (BuildContext context) => StaffPage(),
        '/management_tools': (BuildContext context) => management_tools(),
        '/note': (BuildContext context) => note(),
        '/timer': (BuildContext context) => timer(),
        '/dicee':(BuildContext context)=>DicePage (),
        '/piano':(BuildContext context)=>XylophoneApp (),
        '/account':(BuildContext context)=>accounting (),
        '/draw':(BuildContext context)=>RandomPersonPickerPage (),
        '/calendar':(BuildContext context)=>calendar (),
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => UserProvider(),
    child: MyApp(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  Offset floatingButtonPosition = Offset(0, 0); // 初始位置

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final screenSize = MediaQuery.of(context).size;
        floatingButtonPosition = Offset(screenSize.width - 80, screenSize.height - 150); // 设置为右下角
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context); // 获取用户提供者实例
    final ThemeData theme = Theme.of(context); // 获取当前主题

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.cyanAccent,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('管理システム'),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.amber,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.map),
              icon: Icon(Icons.map_outlined),
              label: 'GoogleMap',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.notifications_sharp),
              icon: Badge(child: Icon(Icons.notifications_none)),
              label: 'Notifications',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.message_sharp),
              icon: Badge(
                label: Text('2'),
                child: Icon(Icons.message_outlined),
              ),
              label: 'Messages',
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
        ][currentPageIndex],
        drawer: Drawer(
          backgroundColor: Colors.white.withOpacity(0.7), // 设置抽屉背景颜色
          width: 200, // 设置抽屉宽度
          child: Container(
            child: Column(children: [
              SizedBox(height: 50),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfileScreen();
                  }));
                },
                leading: CircleAvatar(
                  child: Text(userProvider.userName.isNotEmpty
                      ? userProvider.userName[0]
                      : 'N'),
                ),
              ),
              ListTile(
                title: Text(
                    userProvider.userName.isNotEmpty
                        ? userProvider.userName
                        : 'No name available',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userProvider.userEmail.isNotEmpty
                    ? userProvider.userEmail
                    : 'No email available'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfileScreen();
                  }));
                },
                leading: Icon(Icons.people),
                title: Text("個人情報"),
              ),
              ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) {
                        return SplashScreen();
                      }), (route) => false);
                },
                leading: Icon(Icons.logout),
                title: Text("Logout"),
              )
            ]),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            // 使用Positioned小部件来定位浮动按钮的位置
            Positioned(
              left: floatingButtonPosition.dx, // 设置浮动按钮的水平位置
              top: floatingButtonPosition.dy, // 设置浮动按钮的垂直位置
              child: Draggable(
                // 拖动时显示的浮动按钮
                feedback: FloatingActionButton.extended(
                  icon: Icon(Icons.add), // 浮动按钮的图标
                  label: Text(''), // 浮动按钮的文本标签
                  onPressed: () {
                    print('点击悬浮按钮'); // 点击浮动按钮时输出日志
                    Navigator.of(context).pushNamed('/note'); // 导航到"/note"页面
                  },
                  backgroundColor:
                  Colors.red.withOpacity(0.5), // 设置浮动按钮半透明的背景颜色
                  foregroundColor: Colors.deepPurple, // 设置浮动按钮的前景颜色
                ),
                childWhenDragging: Container(), // 拖动时显示的空容器
                // 默认情况下显示的浮动按钮
                child: FloatingActionButton.extended(
                  icon: Icon(Icons.note), // 浮动按钮的图标
                  label: Text(''), // 浮动按钮的文本标签
                  onPressed: () {
                    Navigator.of(context).pushNamed('/note'); // 导航到"/note"页面
                  },
                  backgroundColor:
                  Colors.red.withOpacity(0.2), // 设置浮动按钮半透明的背景颜色
                  foregroundColor: Colors.deepPurple, // 设置浮动按钮的前景颜色
                ),
                onDragEnd: (details) {
                  setState(() {
                    // 更新浮动按钮的位置
                    floatingButtonPosition = details.offset; // 确保位置不受其他因素影响
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
