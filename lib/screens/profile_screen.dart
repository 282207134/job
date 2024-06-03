//个人情报界面
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter框架基础库
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符库
import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库

import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import 'edit_profile_screen.dart'; // 引入状态管理库

// 定义ProfileScreen类，一个有状态的小部件
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // 构造函数

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // 创建状态
}

// 定义_ProfileScreenState类，是ProfileScreen的状态
class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData = {}; // 用于存储用户数据的Map

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); // 从Provider获取UserProvider实例

    return Scaffold(
      appBar: AppBar(
        title: Text(""), // 设置应用栏标题
      ),
      body: Container(
        width: double.infinity, // 容器宽度设置为无限
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Column(
            children: [
              CircleAvatar(
                radius: 120,
                //当前帐户图片:圈子头像
                backgroundImage: AssetImage('images/panda.png'),
              ),
            ],
          ), // 显示用户名称的首字母的圆形头像

          SizedBox(height: 20),
          Text(userProvider.userEmail,
              style: TextStyle(
                fontSize: 30.0,
              )), // 显示用户电子邮件
          SizedBox(height: 20),
          Text(userProvider.userName, // 显示用户全名
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 30)), // 字体加粗
          ElevatedButton(
              onPressed: () {
                // 点击按钮时导航到编辑个人资料页面
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditProfileScreen(); // 跳转到编辑个人资料的屏幕
                }));
              },
              child: Text("改名")) // 按钮文字
        ]),
      ),
    );
  }
}
