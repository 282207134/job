import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'quiz_brain.dart';

QuizBrain quizBrain = QuizBrain(); // 实例化 QuizBrain 对象

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(        backgroundColor: Colors.grey.shade900, // 设置背景颜色
      appBar: AppBar(
        centerTitle: true,
        title: Text("進路選択"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 设置返回图标
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: QuizPage(), // 显示 QuizPage 组件
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState(); // 创建 QuizPage 的状态
}

class _QuizPageState extends State<QuizPage> {
  double _value = 0; // 定义进度条的值

  void updateProgress() { // 更新进度条的方法
    setState(() {
      _value = (quizBrain.getQuestionIndex() + 1) / quizBrain.getQuestionLength(); // 计算进度
    });
  }

  void checkAnswer(bool userPickedAnswer) { // 检查答案的方法
    setState(() {
      quizBrain.updateScore(userPickedAnswer, quizBrain.getQuestionIndex()); // 更新得分

      // 遇到问题完成的情况
      if (quizBrain.isFinished()) {
        List<int> top4Indexes = quizBrain.getTop4Careers(); // 获取得分最高的4个职业索引

        // 职业名称映射
        Map<int, String> careerNames = {
          0: "マークアップエンジニア",
          1: "フロントエンドエンジニア",
          2: "Webアプリケーションエンジニア",
          3: "モバイルアプリケーションエンジニア",
          4: "オープン系アプリケーションエンジニア",
          5: "汎用系アプリケーションエンジニア",
          6: "組み込み・制御系エンジニア",
          7: "AI・機械学習エンジニア",
          8: "サーバーエンジニア",
          9: "ネットワークエンジニア",
          10: "データベースエンジニア",
          11: "セキュリティエンジニア",
          12: "クラウドエンジニア",
          13: "セールスエンジニア",
          14: "社内SE",
          15: "プログラマ",
          16: "システムエンジニア",
          17: "プロジェクトマネージャー",
          18: "システムコンサルタント"
        };

        // 获取推荐职业的名称
        List<String> recommendedCareers = top4Indexes
            .map((index) => careerNames[index] ?? "未知の職業") // 映射索引到职业名称
            .toList();

        // 显示警报
        Alert(
          context: context, // 当前上下文
          type: AlertType.success, // 警报类型
          title: "おすすめの職種", // 标题
          desc: recommendedCareers.join("\n"), // 描述内容
          buttons: [
            DialogButton(
              child: Text(
                "もう一度", // 按钮文本
                style: TextStyle(color: Colors.white, fontSize: 10), // 文本样式
              ),
              onPressed: () {
                Navigator.pop(context); // 关闭弹窗
                setState(() {
                  quizBrain.reset(); // 重置 QuizBrain 状态
                  _value = 0; // 重置进度条值
                });
              },
              width: 140, // 按钮宽度
            )
          ],
        ).show(); // 显示警报
      } else {
        quizBrain.nextQuestion(); // 跳到下一个问题
        updateProgress(); // 更新进度条
      }
    });
  }

  @override
  Widget build(BuildContext context) { // 构建 QuizPage 的 UI
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 主轴对齐方式
      crossAxisAlignment: CrossAxisAlignment.stretch, // 交叉轴拉伸
      children: <Widget>[
        Expanded(
          flex: 5, // 占用 5 份空间
          child: Padding(
            padding: EdgeInsets.all(10.0), // 设置内边距
            child: Center(
              child: Text(
                quizBrain.getQuestionText(), // 获取问题文本
                textAlign: TextAlign.center, // 文本居中
                style: TextStyle(fontSize: 25.0, color: Colors.white), // 文本样式
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0), // 设置内边距
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green), // 按钮样式
              child: Text(
                'はい', // 按钮文本
                style: TextStyle(color: Colors.white, fontSize: 20.0), // 文本样式
              ),
              onPressed: () {
                checkAnswer(true); // 回答“是”
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0), // 设置内边距
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red), // 按钮样式
              child: Text(
                'いいえ', // 按钮文本
                style: TextStyle(color: Colors.white, fontSize: 20.0), // 文本样式
              ),
              onPressed: () {
                checkAnswer(false); // 回答“否”
              },
            ),
          ),
        ),
        // 添加进度条
        SizedBox(
          width: 250, // 设置宽度
          height: 20, // 设置高度
          child: LinearProgressIndicator(
            value: _value, // 设置进度条的值
            backgroundColor: Colors.cyan[100], // 设置背景颜色
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // 设置进度颜色
          ),
        ),
      ],
    );
  }
}
