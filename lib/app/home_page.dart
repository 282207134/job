import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 库
import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart'; // 导入日历页面
import 'package:kantankanri/pages/jobPage/calendarView/calendar_view.dart'; // 导入日历视图
import 'package:kantankanri/pages/jobPage/calendarView/pages/event_details_page.dart'; // 导入事件详情页面
import 'package:kantankanri/pages/jobPage/calendarView/widgets/holiday_settings_sheet.dart'; // 导入假期设置面板
import 'package:kantankanri/pages/othersApplication/todo_page.dart'; // 导入待办事项页面
import 'package:kantankanri/providers/app_language_provider.dart'; // 导入应用语言状态管理器
import 'package:kantankanri/providers/app_lock_provider.dart'; // 导入应用锁状态管理器
import 'package:kantankanri/providers/userProvider.dart'; // 导入用户状态管理器
import 'package:kantankanri/screens/contacts_messages_screen.dart'; // 导入联系人消息屏幕
import 'package:kantankanri/screens/shared_calendar_sheet.dart'; // 导入共享日历面板
import 'package:kantankanri/services/messaging_service.dart'; // 导入消息服务
import 'package:kantankanri/services/holiday_service.dart'; // 导入假期服务
import 'package:kantankanri/services/shared_calendar_service.dart'; // 导入共享日历服务
import 'package:kantankanri/screens/profile_screen.dart'; // 导入个人资料屏幕
import 'package:kantankanri/screens/splash_screen.dart'; // 导入启动屏幕
import 'package:provider/provider.dart'; // 导入状态管理 Provider 包

/// 登录后的主界面(底部导航:日历 / 待办 / 联系人)
class HomePage extends StatefulWidget { // 主页有状态组件类
  const HomePage({super.key}); // 构造函数

  @override // 重写父类方法
  State<HomePage> createState() => _HomePageState(); // 创建并返回状态对象
}

class _HomePageState extends State<HomePage> { // 主页的状态类
  int currentPageIndex = 0; // 当前页面索引

  static const int _navLength = 3; // 导航项数量

  @override // 重写 initState 生命周期方法
  void initState() { // 初始化状态时调用
    super.initState(); // 调用父类的 initState
    WidgetsBinding.instance.addPostFrameCallback((_) { // 在帧绘制完成后执行回调
      if (!mounted) return; // 如果组件未挂载,直接返回
      if (currentPageIndex >= _navLength) { // 如果当前索引超出范围
        setState(() { // 更新状态
          currentPageIndex = currentPageIndex.clamp(0, _navLength - 1); // 将索引限制在有效范围内
        });
      }
    });
  }

  @override // 重写 dispose 生命周期方法
  void dispose() { // 组件销毁时调用
    super.dispose(); // 调用父类的 dispose
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final navIndex = currentPageIndex.clamp(0, _navLength - 1);

    final appBarDivider = Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade300,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: appBarDivider,
        ),
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
          else if (navIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showEventSearch(context, langProvider),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          NavigationBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            elevation: 3,
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
              onTap: () => _showAppLockSheet(context, langProvider),
              leading: const Icon(Icons.lock_outline),
              title: Text(langProvider.tr('app_lock')),
              subtitle: Consumer<AppLockProvider>(
                builder: (_, lock, __) => Text(
                  lock.enabled
                      ? langProvider.tr('app_lock_status_enabled')
                      : langProvider.tr('app_lock_status_disabled'),
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Provider.of<AppLockProvider>(context, listen: false)
                    .lockSession();
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

  Future<void> _showEventSearch(
    BuildContext context,
    AppLanguageProvider langProvider,
  ) async {
    final selected = await showModalBottomSheet<CalendarEventData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final query = ValueNotifier<String>('');
        final controller = TextEditingController();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 12,
            ),
            child: SizedBox(
              height: 460,
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: langProvider.tr('search_event_hint'),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => query.value = v.trim().toLowerCase(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                                '${langProvider.tr('error')}: ${snap.error}'),
                          );
                        }
                        final docs = snap.data?.docs ?? const [];
                        final room =
                            SharedCalendarService.selectedRoomNotifier.value;
                        final myUid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final events = docs
                            .map(_eventFromDoc)
                            .where(
                              (e) =>
                                  !_isHolidayEvent(e) &&
                                  _inCurrentRoom(e, room, myUid),
                            )
                            .toList()
                          ..sort((a, b) => b.date.compareTo(a.date));

                        return ValueListenableBuilder<String>(
                          valueListenable: query,
                          builder: (context, q, _) {
                            if (q.isEmpty) {
                              return Center(
                                child: Text(
                                    langProvider.tr('search_start_typing')),
                              );
                            }
                            final matched = events.where((e) {
                              final title = e.title.toLowerCase();
                              final desc = (e.description ?? '').toLowerCase();
                              return title.contains(q) || desc.contains(q);
                            }).toList();
                            if (matched.isEmpty) {
                              return Center(
                                child:
                                    Text(langProvider.tr('search_no_results')),
                              );
                            }
                            return ListView.separated(
                              itemCount: matched.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final e = matched[i];
                                final dateText =
                                    '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
                                return ListTile(
                                  title: Text(e.title),
                                  subtitle: Text(
                                    e.description?.isNotEmpty == true
                                        ? '${e.description} · $dateText'
                                        : dateText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(sheetCtx).pop(e),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailsPage(event: selected),
      ),
    );
  }

  CalendarEventData _eventFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data() ?? const <String, dynamic>{};
    DateTime? getDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    Color getColor(dynamic value) {
      if (value is int) return Color(value);
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return Color(parsed);
      }
      return Colors.blue;
    }

    return CalendarEventData(
      id: doc.id,
      title: '${raw['title'] ?? ''}',
      description: raw['description'] as String?,
      date: getDateTime(raw['date']) ?? DateTime.now(),
      startTime: getDateTime(raw['startTime']),
      endTime: getDateTime(raw['endTime']),
      color: getColor(raw['color']),
      endDate: getDateTime(raw['endDate']) ??
          getDateTime(raw['date']) ??
          DateTime.now(),
      event: raw,
    );
  }

  bool _isHolidayEvent(CalendarEventData event) {
    return HolidayService.isHolidayEventData(event);
  }

  bool _inCurrentRoom(
      CalendarEventData event, CalendarRoom room, String myUid) {
    final map = event.event is Map<String, dynamic>
        ? event.event as Map<String, dynamic>
        : <String, dynamic>{};
    final calendarId = '${map['calendar_id'] ?? ''}';
    if (calendarId.isNotEmpty) {
      return calendarId == room.id;
    }
    if (!room.isPersonal) return false;
    final createdBy = '${map['created_by_uid'] ?? ''}';
    return createdBy.isEmpty || createdBy == myUid;
  }

  Future<void> _showAppLockSheet(
    BuildContext context,
    AppLanguageProvider langProvider,
  ) async {
    final lockActions = Provider.of<AppLockProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await lockActions.syncWithUser(uid);
    var sheetEnabled = lockActions.enabled;
    var sheetHasPassword = lockActions.hasPassword;
    var sheetIdleMinutes = lockActions.idleMinutes;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(langProvider.tr('app_lock_enabled')),
                  value: sheetEnabled,
                  onChanged: (v) async {
                    setSheetState(() => sheetEnabled = v);
                    if (!v) {
                      await lockActions.disable();
                      await lockActions.syncWithUser(uid);
                      setSheetState(() => sheetEnabled = lockActions.enabled);
                      if (mounted) setState(() {});
                      return;
                    }
                    if (sheetHasPassword) {
                      await lockActions.enable();
                      await lockActions.syncWithUser(uid);
                      setSheetState(() => sheetEnabled = lockActions.enabled);
                      if (mounted) setState(() {});
                      return;
                    }
                    final pass = await _showSetLockPasswordDialog(
                      context,
                      langProvider,
                    );
                    if (pass == null || pass.isEmpty) {
                      setSheetState(() => sheetEnabled = false);
                      return;
                    }
                    await lockActions.enableWithPassword(pass);
                    await lockActions.syncWithUser(uid);
                    setSheetState(() {
                      sheetHasPassword = lockActions.hasPassword;
                      sheetEnabled = lockActions.enabled;
                    });
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.password_outlined),
                  title: Text(
                    sheetHasPassword
                        ? langProvider.tr('change_lock_password')
                        : langProvider.tr('set_lock_password'),
                  ),
                  onTap: () async {
                    final pass = await _showSetLockPasswordDialog(
                      context,
                      langProvider,
                    );
                    if (pass == null || pass.isEmpty) return;
                    await lockActions.updatePassword(pass);
                    await lockActions.syncWithUser(uid);
                    setSheetState(
                        () => sheetHasPassword = lockActions.hasPassword);
                    if (mounted) setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(langProvider.tr('auto_lock_timeout')),
                  subtitle: Text(
                    sheetIdleMinutes <= 0
                        ? langProvider.tr('auto_lock_disabled')
                        : langProvider.tr('auto_lock_minutes').replaceFirst(
                              '{n}',
                              '$sheetIdleMinutes',
                            ),
                  ),
                  onTap: () async {
                    final selected = await _showAutoLockMinutesDialog(
                      context,
                      langProvider,
                      sheetIdleMinutes,
                    );
                    if (selected == null) return;
                    await lockActions.setIdleMinutes(selected);
                    await lockActions.syncWithUser(uid);
                    setSheetState(
                        () => sheetIdleMinutes = lockActions.idleMinutes);
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    await lockActions.syncWithUser(uid);
    if (mounted) setState(() {});
  }

  Future<String?> _showSetLockPasswordDialog(
    BuildContext context,
    AppLanguageProvider langProvider,
  ) async {
    String v1 = '';
    String v2 = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(langProvider.tr('set_lock_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: langProvider.tr('lock_password_hint'),
              ),
              onChanged: (value) => v1 = value.trim(),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: langProvider.tr('confirm_lock_password_hint'),
              ),
              onChanged: (value) => v2 = value.trim(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(langProvider.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (v1.length < 4) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content:
                          Text(langProvider.tr('lock_password_too_short'))),
                );
                return;
              }
              if (v1 != v2) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text(langProvider.tr('lock_password_mismatch'))),
                );
                return;
              }
              Navigator.of(ctx).pop(v1);
            },
            child: Text(langProvider.tr('save')),
          ),
        ],
      ),
    );
  }

  Future<int?> _showAutoLockMinutesDialog(
    BuildContext context,
    AppLanguageProvider langProvider,
    int current,
  ) async {
    var selected = current;
    const options = <int>[0, 1, 3, 5, 10, 15, 30];
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(langProvider.tr('auto_lock_timeout')),
        content: StatefulBuilder(
          builder: (ctx2, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (m) => RadioListTile<int>(
                    value: m,
                    groupValue: selected,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selected = v);
                    },
                    title: Text(
                      m == 0
                          ? langProvider.tr('auto_lock_disabled')
                          : langProvider.tr('auto_lock_minutes').replaceFirst(
                                '{n}',
                                '$m',
                              ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(langProvider.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(selected),
            child: Text(langProvider.tr('save')),
          ),
        ],
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
