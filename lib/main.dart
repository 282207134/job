import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:job/providers/userProvider.dart';
import 'package:job/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'splashScreen/OnBoardingPageState.dart';
import 'package:job/pages/job_page.dart';
import 'package:job/pages/message.dart';
import 'package:job/pages/staff_page.dart';
import 'package:job/pages/transaction_page.dart';
import 'package:job/screens/login_screen.dart';

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
        '/login': (BuildContext context) => SplashScreen(),
        '/home': (BuildContext context) => HomePage(), // 修改此处为正确的类名
        '/job': (BuildContext context) => JobPage(), //
        '/staff': (BuildContext context) => StaffPage(), //
        '/transaction': (BuildContext context) => TransactionPage(), //
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
      create: (context) => UserProvider(), child: MyApp()));
}

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

    var userProvider = Provider.of<UserProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.cyanAccent,
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
          title: Text('管理システム'),
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
                    : 'N')),
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
              title: Text("個人情報")),
          ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return SplashScreen();
                }), (route) => false);
              },
              leading: Icon(Icons.logout),
              title: Text("Logout"))
        ]))),
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
