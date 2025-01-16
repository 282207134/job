import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入 calendar_view 包
import 'package:kantankanri/pages/googleMap/MyGoogleMap.dart';
import 'package:kantankanri/pages/othersApplication/futureVision/quizzler.dart';
import 'package:kantankanri/pages/othersApplication/randomPerson.dart';
import 'package:kantankanri/pages/othersApplication/testPage.dart';
import 'package:kantankanri/pages/othersApplication/testPage2.dart';
import 'package:kantankanri/pages/othersApplication/Xylophone.dart';
import 'package:kantankanri/pages/managementTools/account.dart';
import 'package:kantankanri/pages/othersApplication/dicee.dart';
import 'package:kantankanri/pages/managementTools/management_tools.dart';
import 'package:kantankanri/pages/othersApplication/randomPerson.dart';
import 'package:kantankanri/pages/managementTools/schoolFestivalAccount.dart';
import 'package:kantankanri/pages/managementTools/timer.dart';
import 'package:kantankanri/pages/managementTools/note.dart';
import 'package:kantankanri/pages/notification/notification.dart';
import 'package:kantankanri/pages/othersApplication/others_application.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:kantankanri/screens/chatroom_screen.dart';
import 'package:kantankanri/screens/profile_screen.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'cupertino_example.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'splashScreen/OnBoardingPageState.dart';
import 'package:kantankanri/pages/jobPage/job_page.dart';
import 'package:kantankanri/pages/jobPage/staff_page.dart';
import 'package:kantankanri/pages/home/home.dart';

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
        '/account': (BuildContext context) => accounting(),
        '/schoolFestivalAccount': (BuildContext context) =>
            SchoolFestivalAccount(),
        '/calendar': (BuildContext context) => calendar(),
        '/othersApplication': (BuildContext context) => othersApplication(),
        '/testpage': (BuildContext context) => testPage(),
        '/testpage2': (BuildContext context) => testPage2(),
        '/draw': (BuildContext context) => RandomPersonPickerPage(),
        '/dicee': (BuildContext context) => DicePage(),
        '/piano': (BuildContext context) => XylophoneApp(),
        '/futureVision': (BuildContext context) => Quizzler(),
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
        floatingButtonPosition =
            Offset(screenSize.width - 80, screenSize.height - 150); // 设置为右下角
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context); // 获取用户提供者实例
    final ThemeData theme = Theme.of(context); // 获取当前主题

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.cyanAccent,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade200,
          title: Text('スケジュール管理'),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {


            }),
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
              selectedIcon: Icon(Icons.calendar_month),
              icon: Icon(Icons.calendar_month),
              label: 'calendar',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.note_alt),
              icon: Icon(Icons.note_alt_outlined),
              label: 'note',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.timer),
              icon: Badge(child: Icon(Icons.timer_outlined)),
              label: 'timer',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.message_sharp),
              icon: Badge(
                label: Text('2'),
                child: Icon(Icons.message_outlined),
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.business_center_rounded),
              icon: Badge(
                child: Icon(Icons.business_center_outlined),
              ),
              label: 'others',
            ),
          ],
        ),
        body: <Widget>[
          calendar(),
          note(),
          timer(),
          ChatroomScreen(
            chatroomName: '',
            chatroomId: '',
          ),
          othersApplication(),
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
            // Positioned(
            //   left: floatingButtonPosition.dx, // 设置浮动按钮的水平位置
            //   top: floatingButtonPosition.dy, // 设置浮动按钮的垂直位置
            //   child: Draggable(
            //     // 拖动时显示的浮动按钮
            //     feedback: FloatingActionButton.extended(
            //       icon: Icon(Icons.add),
            //       // 浮动按钮的图标
            //       label: Text(''),
            //       // 浮动按钮的文本标签
            //       onPressed: () {
            //         print('点击悬浮按钮'); // 点击浮动按钮时输出日志
            //         Navigator.of(context).pushNamed('/note'); // 导航到"/note"页面
            //       },
            //       backgroundColor: Colors.red.withOpacity(0.5),
            //       // 设置浮动按钮半透明的背景颜色
            //       foregroundColor: Colors.deepPurple, // 设置浮动按钮的前景颜色
            //     ),
            //     childWhenDragging: Container(), // 拖动时显示的空容器
            //     // 默认情况下显示的浮动按钮
            //     child: FloatingActionButton.extended(
            //       icon: Icon(Icons.note),
            //       // 浮动按钮的图标
            //       label: Text(''),
            //       // 浮动按钮的文本标签
            //       onPressed: () {
            //         Navigator.of(context).pushNamed('/note'); // 导航到"/note"页面
            //       },
            //       backgroundColor: Colors.red.withOpacity(0.2),
            //       // 设置浮动按钮半透明的背景颜色
            //       foregroundColor: Colors.deepPurple, // 设置浮动按钮的前景颜色
            //     ),
            //     onDragEnd: (details) {
            //       setState(() {
            //         // 更新浮动按钮的位置
            //         floatingButtonPosition = details.offset; // 确保位置不受其他因素影响
            //       });
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
