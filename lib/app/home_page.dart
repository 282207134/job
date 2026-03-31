import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/jobPage/calendarView/widgets/holiday_settings_sheet.dart';
import 'package:kantankanri/pages/othersApplication/todo_page.dart';
import 'package:kantankanri/providers/app_language_provider.dart';
import 'package:kantankanri/providers/userProvider.dart';
import 'package:kantankanri/screens/contacts_messages_screen.dart';
import 'package:kantankanri/screens/shared_calendar_sheet.dart';
import 'package:kantankanri/services/messaging_service.dart';
import 'package:kantankanri/services/shared_calendar_service.dart';
import 'package:kantankanri/screens/profile_screen.dart';
import 'package:kantankanri/screens/splash_screen.dart';
import 'package:provider/provider.dart';

/// ログイン後のメインシェル（下部ナビ：カレンダー / Todo / 連絡先）
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final navIndex = currentPageIndex.clamp(0, _navLength - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        title: navIndex == 0
            ? ValueListenableBuilder<CalendarRoom>(
                valueListenable: SharedCalendarService.selectedRoomNotifier,
                builder: (context, room, _) => Text(
                  room.isPersonal
                      ? langProvider.tr('my_calendar')
                      : '${langProvider.tr('shared_calendar')}: ${room.name}',
                ),
              )
            : Text(
                navIndex == 2
                    ? langProvider.tr('contacts')
                    : langProvider.tr('title_schedule'),
              ),
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
          NavigationDestination(
            selectedIcon: const Icon(Icons.calendar_month),
            icon: const Icon(Icons.calendar_month),
            label: langProvider.tr('calendar'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.task_alt),
            icon: const Icon(Icons.task_alt_outlined),
            label: langProvider.tr('todo'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.people_alt_rounded),
            icon: const _MessagesNavIcon(),
            label: langProvider.tr('contacts'),
          ),
        ],
      ),
      body: <Widget>[
        calendar(),
        const todo_page(embedded: true),
        const ContactsMessagesScreen(),
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
                    : langProvider.tr('no_name_available'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                userProvider.userEmail.isNotEmpty
                    ? userProvider.userEmail
                    : langProvider.tr('no_email_available'),
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
              title: Text(langProvider.tr('profile')),
            ),
            ListTile(
              onTap: () async {
                Navigator.of(context).pop();
                await HolidaySettingsSheet.show(context);
              },
              leading: const Icon(Icons.celebration_outlined),
              title: Text(langProvider.tr('holiday_settings')),
            ),
            ListTile(
              onTap: () async {
                Navigator.of(context).pop();
                await SharedCalendarSheet.show(context);
              },
              leading: const Icon(Icons.edit_calendar_outlined),
              title: Text(langProvider.tr('shared_calendar')),
            ),
            ListTile(
              onTap: () => _showLanguageSheet(context, langProvider),
              leading: const Icon(Icons.language),
              title: Text(langProvider.tr('language_settings')),
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
              title: Text(langProvider.tr('logout')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    AppLanguageProvider langProvider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppLanguage>(
              value: AppLanguage.zh,
              groupValue: langProvider.language,
              title: Text(langProvider.tr('language_zh')),
              onChanged: (v) async {
                if (v == null) return;
                await langProvider.setLanguage(v);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            RadioListTile<AppLanguage>(
              value: AppLanguage.ja,
              groupValue: langProvider.language,
              title: Text(langProvider.tr('language_ja')),
              onChanged: (v) async {
                if (v == null) return;
                await langProvider.setLanguage(v);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            RadioListTile<AppLanguage>(
              value: AppLanguage.en,
              groupValue: langProvider.language,
              title: Text(langProvider.tr('language_en')),
              onChanged: (v) async {
                if (v == null) return;
                await langProvider.setLanguage(v);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 8),
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
