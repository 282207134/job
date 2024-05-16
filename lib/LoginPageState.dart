import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // 检查凭据是否正确
    if (username == 'liuyu' && password == '123456') {
      // 导航到HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正しい入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Center(child: Text("")),
        backgroundColor: Colors.blue,
      ), // 页面顶部的应用栏
      body: Padding(
        padding: EdgeInsets.all(20.0), // 内边距
        child: Column(
          children: [
            Container(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('images/panda.png'),
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.supervised_user_circle),
                    labelText: 'ユーザ',
                    hintText: 'ユーザを入力してください',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)))), // 用户名输入框
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.all(20),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'パスワード',
                    hintText: 'パスワードを入力ください',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)))), // 密码输入框
                obscureText: true, // 隐藏输入内容
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: _login, // 登录按钮
                child: Text('ログイン'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
