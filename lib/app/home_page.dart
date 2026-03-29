import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/othersApplication/others_application.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:kantankanri/screens/chatroom_screen.dart';
import 'package:kantankanri/screens/profile_screen.dart';
import 'package:kantankanri/screens/splash_screen.dart';
import 'package:provider/provider.dart';

/// ログイン後のメインシェル（下部ナビ：カレンダー / メッセージ / その他）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  static const int _navLength = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (currentPageIndex >= _navLength) {
        setState(() {
          currentPageIndex = currentPageIndex.clamp(0, _navLength - 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final navIndex = currentPageIndex.clamp(0, _navLength - 1);

    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: const Text('スケジュール管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        indicatorColor: Colors.amber,
        selectedIndex: navIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month),
            label: 'calendar',
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
        ChatroomScreen(
          chatroomName: '',
          chatroomId: '',
        ),
        othersApplication(),
      ][navIndex],
      drawer: Drawer(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        width: 200,
        child: Column(
          children: [
            const SizedBox(height: 50),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              leading: CircleAvatar(
                child: Text(
                  userProvider.userName.isNotEmpty
                      ? userProvider.userName[0]
                      : 'N',
                ),
              ),
            ),
            ListTile(
              title: Text(
                userProvider.userName.isNotEmpty
                    ? userProvider.userName
                    : 'No name available',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                userProvider.userEmail.isNotEmpty
                    ? userProvider.userEmail
                    : 'No email available',
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.people),
              title: const Text('個人情報'),
            ),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const SplashScreen(),
                  ),
                  (route) => false,
                );
              },
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
