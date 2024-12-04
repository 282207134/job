import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class XylophoneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("ピアノ"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // 设置返回图标
            onPressed: () {
              Navigator.pop(context); // 返回上一个页面
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (index) => buildKey(index + 1)),
          ),
        ),
      ),
    );
  }

  // 创建一个统一的函数来生成按钮
  Widget buildKey(int soundNumber) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.purple
    ];
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: colors[soundNumber - 1],
          padding: EdgeInsets.zero, // 移除内边距以填充整个空间
          // 设置固定的高度和宽度比例，使按钮看起来是长方形
          shape: RoundedRectangleBorder(), // 保持默认形状即可
        ),
        onPressed: () async {
          playSound(soundNumber);
        },
        child: Text(''),
      ),
    );
  }

  Future<void> playSound(int soundNumber) async {
    final player = AudioPlayer();
    await player.play(AssetSource('piano/note$soundNumber.wav'));
  }
}
