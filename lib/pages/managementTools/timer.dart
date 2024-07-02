import 'dart:async'; // 导入 dart:async 库以使用 Timer 类
import 'package:flutter/material.dart'; // 导入 Material 应用程序的 Flutter 组件库
import 'package:rflutter_alert/rflutter_alert.dart'; // 引入 rflutter_alert 包
import 'package:audioplayers/audioplayers.dart';

class timer extends StatefulWidget {
  // 创建 timer 类，它是一个有状态小部件
  @override
  _timerState createState() => _timerState(); // 创建状态对象
}

class _timerState extends State<timer> {
  Timer? _timer; // 定义一个 Timer 对象，用于控制倒计时
  int _start = 30; // 倒计时的起始时间
  final player = AudioPlayer();
  final TextEditingController _controller =
  TextEditingController(); // 创建文本编辑控制器

  void startTimer() {
    const oneSec = const Duration(seconds: 1); // 设置时间间隔为 1 秒
    _timer?.cancel(); // 如果已经有计时器在运行，先取消
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel(); // 到达零时取消计时器
            showAlert();
            try {
              player.play(AssetSource('1.wav'));
            } catch (e) {
              print('无法播放音频: $e');
            }
          });
        } else {
          setState(() {
            _start--; // 时间递减
          });
        }
      },
    );
  }

  void showAlert() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "終了",
      desc: "カウントダウン終了",
      buttons: [
        DialogButton(
          child: Text(
            "戻る",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            await player.stop(); // 停止音乐播放
            Navigator.pop(context); // 返回上一个页面
          },
          width: 120,
        )
      ],
    ).show();
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel(); // 取消计时器
      setState(() {
        _start = 0; // 重置倒计时
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 在小部件销毁时取消计时器
    _controller.dispose(); // 销毁控制器以释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カウントダウン'), // 页面顶部的标题
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 设置返回图标
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 120,
                child: TextField(
                  textAlign: TextAlign.center, // 文字居中对齐
                  controller: _controller, // 绑定控制器，用于管理输入框文本
                  keyboardType: TextInputType.number, // 设置键盘类型为数字，适用于输入时间
                  decoration: InputDecoration(
                    hintText: '時間(秒数)', // 当输入框未被选中且为空时显示的提示文本
                  ),
                )),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _start = int.tryParse(_controller.text) ?? 30; // 尝试解析输入值，如果失败则保持默认
                    _controller.clear(); // 清空输入框
                  });
                }
              },
              child: Text('カウントダウンを設定する'), // 按钮文本
            ),
            Text(
              '$_start', // 显示倒计时时间
              style: TextStyle(fontSize: 50), // 设置字体大小
            ),
            ElevatedButton(
              onPressed: startTimer, // 开始倒计时
              child: Text('カウントダウン開始'), // 按钮文本
            ),
            ElevatedButton(
              onPressed: stopTimer, // 停止倒计时
              child: Text('カウントダウン停止'), // 按钮文本
            ),
          ],
        ),
      ),
    );
  }
}
