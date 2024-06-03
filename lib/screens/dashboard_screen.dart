//示例文件的侧面栏和主界面
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter框架基础库
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符库
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库

import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:job/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../splashScreen/splash_screen.dart';
import 'chatroom_screen.dart'; // 引入状态管理库

// 定义DashboardScreen类，一个有状态的小部件
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key}); // 构造函数

  @override
  State<DashboardScreen> createState() => _DashboardScreenState(); // 创建状态
}

// 定义_DashboardScreenState类，是DashboardScreen的状态
class _DashboardScreenState extends State<DashboardScreen> {
  var user = FirebaseAuth.instance.currentUser; // 获取当前用户
  var db = FirebaseFirestore.instance; // 获取Firestore实例

  var scaffoldKey = GlobalKey<ScaffoldState>(); // 创建一个全局键用于脚手架状态

  List<Map<String, dynamic>> chatroomsList = []; // 聊天室列表数据
  List<String> chatroomsIds = []; // 聊天室ID列表

  void getChatrooms() {
    db.collection("chatrooms").get().then((dataSnapshot) {
      for (var singleChatroomData in dataSnapshot.docs) {
        chatroomsList.add(singleChatroomData.data()); // 添加聊天室数据
        chatroomsIds.add(singleChatroomData.id.toString()); // 添加聊天室ID
      }

      setState(() {}); // 更新状态以重新构建UI
    });
  }

  @override
  void initState() {
    getChatrooms(); // 获取聊天室数据
    super.initState(); // 调用父类的initState
  }

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); // 从Provider获取UserProvider实例

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Global Chat"), // 应用栏标题
          leading: InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer(); // 打开侧边抽屉
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: CircleAvatar(
                  radius: 20,
                  child: Text(userProvider.userName[0])), // 显示用户名称首字母的圆形头像
            ),
          ),
        ),
        drawer: Drawer(
            child: Container(
                child: Column(children: [
          SizedBox(height: 50),
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfileScreen(); // 导航到个人资料屏幕
              }));
            },
            leading:
                CircleAvatar(child: Text(userProvider.userName[0])), // 用户头像
            title: Text(userProvider.userName,
                style: TextStyle(fontWeight: FontWeight.bold)), // 用户名
            subtitle: Text(userProvider.userEmail), // 用户电邮
          ),
          ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProfileScreen(); // 导航到个人资料屏幕
                }));
              },
              leading: Icon(Icons.people),
              title: Text("Profile")), // 个人资料列表项
          ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // 登出操作
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return SplashScreen(); // 返回启动屏幕
                }), (route) {
                  return false;
                });
              },
              leading: Icon(Icons.logout),
              title: Text("Logout")) // 登出列表项
        ]))),
        body: ListView.builder(
            itemCount: chatroomsList.length, // 聊天室列表的数量
            itemBuilder: (BuildContext context, int index) {
              String chatroomName =
                  chatroomsList[index]["chatroom_name"] ?? ""; // 获取聊天室名称

              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ChatroomScreen(
                      chatroomName: chatroomName, // 聊天室名称
                      chatroomId: chatroomsIds[index], // 聊天室ID
                    );
                  }));
                },
                leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey[900],
                    child: Text(
                      chatroomName[0], // 显示聊天室名称的首字母
                      style: TextStyle(color: Colors.white),
                    )),
                title: Text(chatroomName), // 聊天室完整名称
                subtitle: Text(chatroomsList[index]["desc"] ?? ""),
              );
            }));
  }
}
