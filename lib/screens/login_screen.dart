import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter框架基础库
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符库
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job/screens/signup_screen.dart';

import '../controllers/login_controller.dart'; // 引入Firebase认证库

// 定义LoginScreen类，一个有状态的小部件
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // 构造函数

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // 创建状态
}

// 定义_LoginScreenState类，是LoginScreen的状态
class _LoginScreenState extends State<LoginScreen> {
  var userForm = GlobalKey<FormState>(); // 创建一个全局键用于表单状态

  bool isLoading = false; // 加载状态标识

  // 创建输入控制器
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade300,
        // appBar: AppBar(title: Text("Login")), // 可以选择添加一个标题栏
        body: Form(
          key: userForm, // 将全局键赋给Form小部件
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height:180,
                    width:180,
                    child: Image.asset("images/logo.png")), // Logo图片
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode:
                      AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                  controller: email, // 使用email控制器
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required"; // 验证邮箱输入
                    }
                  },
                  decoration: InputDecoration(
                      label: Text("Email"),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.mail),
                      hintStyle:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)))), // 邮箱输入框装饰
                ),
                SizedBox(height: 23),
                TextFormField(
                  autovalidateMode:
                      AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                  controller: password, // 使用password控制器
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required"; // 验证密码输入
                    }
                  },
                  obscureText: true, // 隐藏输入内容
                  enableSuggestions: false, // 禁止建议
                  autocorrect: false, // 禁止自动更正
                  decoration: InputDecoration(
                      label: Text("Password"),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock),
                      hintStyle:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)))), // 密码输入框装饰
                ),
                SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(0, 50),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepPurpleAccent), // 按钮样式
                          onPressed: () async {
                            if (userForm.currentState!.validate()) {
                              // 如果表单验证通过
                              isLoading = true; // 开始加载
                              setState(() {}); // 刷新UI

                              // 登录账号
                              await LoginController.login(
                                  context: context,
                                  email: email.text,
                                  password: password.text);

                              isLoading = false; // 停止加载
                              setState(() {}); // 刷新UI
                            }
                          },
                          child: isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ) // 显示加载中动画
                              : Text("Login")), // 显示登录文本
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ユーザを持っていない'), // 提示没有账户
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SignupScreen(); // 跳转到注册界面
                        }));
                      },
                      child: Text("ここから登録する", // 提供注册链接
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)), // 链接样式
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
