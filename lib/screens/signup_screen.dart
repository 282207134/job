//注册界面
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter框架基础库
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符库
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/signup_controller.dart'; // 引入Firebase认证库

// 定义SignupScreen类，一个有状态的小部件
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key}); // 构造函数

  @override
  State<SignupScreen> createState() => _SignupScreenState(); // 创建状态
}

// 定义_SignupScreenState类，是SignupScreen的状态
class _SignupScreenState extends State<SignupScreen> {
  var userForm = GlobalKey<FormState>(); // 创建一个全局键用于表单状态

  bool isLoading = false; // 加载状态标识

  // 创建输入控制器
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController country = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 构建UI界面
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
          backgroundColor: Colors.blue.shade100,
        ),
        backgroundColor: Colors.blue.shade100,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: userForm, // 将全局键赋给Form小部件
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // SizedBox(
                        //     width: 100,
                        //     child: Image.asset("images/panda.png")), // Logo图片
                        TextFormField(
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                          controller: email, // 使用email控制器
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required"; // 验证邮箱输入
                            }
                          },
                          decoration:
                              InputDecoration(label: Text("Email")), // 邮箱输入框装饰
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
                              label: Text("Password")), // 密码输入框装饰
                        ),
                        SizedBox(height: 23),
                        TextFormField(
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                          controller: name, // 使用name控制器
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required"; // 验证名称输入
                            }
                          },
                          decoration:
                              InputDecoration(label: Text("Name")), // 名称输入框装饰
                        ),
                        SizedBox(height: 23),
                        TextFormField(
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                          controller: country, // 使用country控制器
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Country is required"; // 验证国家输入
                            }
                          },
                          decoration: InputDecoration(
                              label: Text("Country")), // 国家输入框装饰
                        ),
                        SizedBox(height: 53),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(0, 50),
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.deepPurpleAccent), // 按钮样式
                                  onPressed: () async {
                                    if (userForm.currentState!.validate()) {
                                      // 如果表单验证通过
                                      isLoading = true; // 开始加载
                                      setState(() {}); // 刷新UI

                                      // 创建账号
                                      await SignupController.createAccount(
                                          context: context,
                                          email: email.text,
                                          password: password.text,
                                          country: country.text,
                                          name: name.text);
                                    }

                                    isLoading = false; // 停止加载
                                    setState(() {}); // 刷新UI
                                  },
                                  child: isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ) // 显示加载中动画
                                      : Text("ユーザ登録")), // 显示创建账号文本
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
