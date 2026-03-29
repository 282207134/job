import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/othersApplication/others_application.dart';
import 'package:kantankanri/pages/othersApplication/todo_page.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:kantankanri/screens/contacts_messages_screen.dart';
import 'package:kantankanri/services/messaging_service.dart';
import 'package:kantankanri/screens/profile_screen.dart';
import 'package:kantankanri/screens/splash_screen.dart';
import 'package:provider/provider.dart';

/// ログイン後のメインシェル（下部ナビ：カレンダー / Todo / メッセージ / その他）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  static const int _navLength = 4;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        title: Text(navIndex == 2 ? '連絡先' : 'スケジュール管理'),
        actions: [
          if (navIndex == 2)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () =>
                  ContactsMessagesScreen.showAddFriendDialog(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        elevation: 1,
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        indicatorColor: Colors.grey.shade200,
        selectedIndex: navIndex,
        destinations: <Widget>[
          const NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month),
            label: 'calendar',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.task_alt),
            icon: Icon(Icons.task_alt_outlined),
            label: 'Todo',
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.people_alt_rounded),
            icon: const _MessagesNavIcon(),
            label: '連絡先',
          ),
          const NavigationDestination(
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
        const todo_page(embedded: true),
        const ContactsMessagesScreen(),
        othersApplication(),
      ][navIndex],
      drawer: Drawer(
        backgroundColor: Colors.white,
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

/// 受け取った友だち申請件数でバッジ表示
class _MessagesNavIcon extends StatelessWidget {
  const _MessagesNavIcon();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Icon(Icons.chat_bubble_outline_rounded);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: MessagingService.friendLinksForUser(uid),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final n = docs.where((d) {
          final m = d.data();
          return m['status'] == 'pending' && m['requested_by'] != uid;
        }).length;
        if (n <= 0) {
          return const Icon(Icons.chat_bubble_outline_rounded);
        }
        return Badge(
          label: Text('$n'),
          child: const Icon(Icons.chat_bubble_outline_rounded),
        );
      },
    );
  }
}
