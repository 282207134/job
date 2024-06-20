import 'package:flutter/material.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:

          /// Notifications page
          const Padding(
        padding: EdgeInsets.all(8.0), // 内边距。
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications_sharp), // 列表项图标。
                title: Text('Notification 1'), // 标题文本。
                subtitle: Text('This is a notification'), // 子标题文本。
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications_sharp), // 列表项图标。
                title: Text('Notification 2'), // 标题文本。
                subtitle: Text('This is a notification'), // 子标题文本。
              ),
            ),
          ],
        ),
      ),
    );
  }
}
