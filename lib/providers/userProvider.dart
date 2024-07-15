import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:flutter/material.dart'; // 引入Flutter材料设计库

class UserProvider extends ChangeNotifier {
  String userName = "Dummy Name"; // 默认用户名
  String userEmail = "Dummy Email"; // 默认用户邮箱
  String userId = "Dummy UserID"; // 默认用户ID

  final FirebaseFirestore db = FirebaseFirestore.instance; // 获取Firestore的实例

  UserProvider() {
    getUserDetails(); // 在实例化时获取用户详细信息
  }

  // 获取用户详细信息的方法
  Future<void> getUserDetails() async {
    User? authUser = FirebaseAuth.instance.currentUser; // 获取当前通过Firebase认证的用户

    if (authUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> dataSnapshot =
        await db.collection("users").doc(authUser.uid).get();

        if (dataSnapshot.exists) {
          userName = dataSnapshot.data()?["name"] ?? "No Name"; // 从数据库获取用户名
          userEmail = dataSnapshot.data()?["email"] ?? "No Email"; // 从数据库获取用户邮箱
          userId = dataSnapshot.data()?["id"] ?? "No ID"; // 从数据库获取用户ID
          notifyListeners(); // 通知听众更新，这会触发依赖此数据的界面部分重新构建
        } else {
          print("User document does not exist");
        }
      } catch (error) {
        // 处理可能出现的错误
        print("Error getting user details: $error");
      }
    } else {
      // 如果没有用户登录，可能需要处理未登录的逻辑
      print("No user logged in");
    }
  }

  // 更新用户名的方法
  Future<void> updateUserName(String newName) async {
    User? authUser = FirebaseAuth.instance.currentUser;

    if (authUser != null) {
      try {
        await db.collection("users").doc(authUser.uid).update({
          "name": newName,
        });
        userName = newName;
        notifyListeners();
      } catch (error) {
        print("Error updating user name: $error");
      }
    }
  }
}
