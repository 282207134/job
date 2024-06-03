import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  //事务管理界面

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("事務管理"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(),
          child: Text('閉じる'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}
