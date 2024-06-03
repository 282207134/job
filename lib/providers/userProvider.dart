import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:flutter/material.dart'; // 引入Flutter材料设计库

// 定义UserProvider类，继承自ChangeNotifier，用于跨组件状态管理
class UserProvider extends ChangeNotifier {
  String userName = "Dummy Name"; // 默认用户名
  String userEmail = "Dummy Email"; // 默认用户邮箱
  String userId = "Dummy UserID"; // 默认用户ID

  var db = FirebaseFirestore.instance; // 获取Firestore的实例

  // 获取用户详细信息的方法
  void getUserDetails() {
    var authUser = FirebaseAuth.instance.currentUser; // 获取当前通过Firebase认证的用户
    if (authUser != null) {
      // 如果用户已经登录
      db.collection("users").doc(authUser.uid).get().then((dataSnapshot) {
        userName = dataSnapshot.data()?["name"] ?? ""; // 从数据库获取用户名，如果不存在则返回空字符串
        userEmail =
            dataSnapshot.data()?["email"] ?? ""; // 从数据库获取用户邮箱，如果不存在则返回空字符串
        userId = dataSnapshot.data()?["id"] ?? ""; // 从数据库获取用户ID，如果不存在则返回空字符串
        notifyListeners(); // 通知听众更新，这会触发依赖此数据的界面部分重新构建
      }).catchError((error) {
        // 处理可能出现的错误
        print("Error getting user details: $error");
      });
    } else {
      // 如果没有用户登录，可能需要处理未登录的逻辑
      print("No user logged in");
    }
  }
}
