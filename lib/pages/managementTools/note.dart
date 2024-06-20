import 'package:flutter/material.dart';

class note extends StatefulWidget {
  const note({Key? key}) : super(key: key); // 使用 key 参数的正确方式

  @override
  State<note> createState() => _noteState();
}

class _noteState extends State<note> {
  final TextEditingController _textController =
      TextEditingController(); // 文本控制器
  final List<String> _notes = []; // 笔记列表，确保这个列表是状态类的成员变量

  void _addNote() {
    if (_textController.text.trim().isNotEmpty) {
      // 判断输入内容非空
      setState(() {
        _notes.add(_textController.text.trim()); // 添加到笔记列表
        _textController.clear(); // 清空输入框
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 Scaffold 作为根 widget 更合适，便于后续添加导航栏等组件
      appBar: AppBar(
        title: Text('メモ'), // AppBar 标题
      ),
      body: Container(
        color: Colors.yellow.shade100, // 背景颜色
        padding: const EdgeInsets.all(8.0), // 添加一些内边距
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController, // 文本控制器
              decoration: InputDecoration(
                labelText: 'メモを入力してください', // 标签文本
                border: OutlineInputBorder(), // 边框样式
                suffixIcon: IconButton(
                  icon: Icon(Icons.add), // 图标
                  onPressed: _addNote, // 点击事件
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length, // 列表项数
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]), // 标题文本
                    trailing: IconButton(
                      icon: Icon(Icons.delete), // 删除按钮图标
                      onPressed: () {
                        setState(() {
                          _notes.removeAt(index); // 删除指定项
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
