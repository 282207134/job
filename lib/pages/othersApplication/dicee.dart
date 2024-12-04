import 'package:flutter/material.dart';
import 'dart:math';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  @override
  int leftDiceNumber = 1;
  int rightDiceNumber = 1;

  void leftChangeDiceFace() {
    setState(() {
      leftDiceNumber = Random().nextInt(6) + 1;
    });
  }

  void rightChangeDiceFace() {
    setState(() {
      rightDiceNumber = Random().nextInt(6) + 1;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.green,
      appBar: AppBar(
        centerTitle: true,
        title: Text("骰子"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 设置返回图标
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    leftChangeDiceFace();
                    print('左测的值为:$leftDiceNumber');
                  },
                  child: Image.asset('images/dice/dice$leftDiceNumber.png'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      rightChangeDiceFace();
                    });
                    print('右侧的值为:$rightDiceNumber');
                  },
                  child: Image.asset('images/dice/dice$rightDiceNumber.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
