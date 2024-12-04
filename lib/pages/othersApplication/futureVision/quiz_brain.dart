import 'package:job/pages/othersApplication/futureVision/quizzler.dart';

import 'question.dart';

class QuizBrain {
  int _questionNumber = 0;
  late List<Question> _questionBank;

  // 初始化19个职业的得分数组
  List<int> scores = List.filled(19, 0);

  QuizBrain() {
    _questionBank = _initQuestionBank();
  }

  List<Question> _initQuestionBank() {
    return [
      Question('自分で問題を解決することが得意ですか？', true),
      // 问题解决能力
      Question('独立して仕事をするよりも、チームで協力する方が得意ですか？', true),
      // 团队合作
      Question('小規模なチームよりも、大規模なチームで働く方が得意ですか？', true),
      // 团队规模
      Question('小さなプロジェクトよりも、大きなプロジェクトに挑戦したいですか？', true),
      // 项目规模
      Question('最新技術の研究に興味がありますか？', true),
      // 对新技术的兴趣
      Question('アプリケーションの開発よりも、基盤技術に興味がありますか？', true),
      // 基础技术
      Question('ハードウェアやデバイスを扱う仕事に興味がありますか？', true),
      // 硬件技术
      Question('創造的なアイデアを生み出すのが得意ですか？', true),
      // 创造力
      Question('新しいツールや技術をすぐに習得できる自信がありますか？', true),
      // 学习能力
      Question('リーダーとしての役割に挑戦するのが好きですか？', true),
      // 领导力
      Question('顧客やクライアントと直接関わる仕事が好きですか？', true),
      // 客户关系
      Question('安定した仕事環境より、変化の多い仕事環境に魅力を感じますか？', true),
      // 工作环境
      Question('他の人をサポートする仕事に関心がありますか？', true),
      // 支持性角色
      Question('自分のアイデアを実現することに喜びを感じますか？', true),
      // 实现创意
      Question('論理的思考を得意としますか？', true),
      // 逻辑思维
      Question('データ分析や統計に興味がありますか？', true),
      // 数据分析
    ];

  }

  int getQuestionLength() {
    return _questionBank.length;
  }
  void updateScore(bool userPickedAnswer, int questionIndex) {
    Map<int, List<int>> questionToCareerMap = {
      0: userPickedAnswer
          ? [0, 2, 4, 5, 7, 10, 12, 16] // 问题解决能力：是时加分
          : [1, 3, 6, 9, 11, 13], // 问题解决能力：否时加分

      1: userPickedAnswer
          ? [2, 4, 7, 8, 11, 12] // 更喜欢独立工作的职业：是时加分
          : [0, 3, 5, 6, 9, 13], // 更喜欢独立工作的职业：否时加分

      2: userPickedAnswer
          ? [1, 3, 4, 6, 8, 9, 14, 16] // 更喜欢小规模团队的职业：是时加分
          : [0, 2, 5, 7, 10, 12, 13], // 更喜欢大规模团队的职业：否时加分

      3: userPickedAnswer
          ? [2, 5, 6, 7, 11, 15] // 喜欢大型项目的职业：是时加分
          : [1, 3, 4, 9, 14, 16], // 喜欢小型项目的职业：否时加分

      4: userPickedAnswer
          ? [4, 6, 7, 8, 9, 10, 11] // 喜欢新技术的职业：是时加分
          : [0, 1, 5, 12, 14], // 不喜欢新技术的职业：否时加分

      5: userPickedAnswer
          ? [5, 7, 8, 11, 17] // 对基础技术感兴趣的职业：是时加分
          : [0, 1, 2, 3, 4, 10], // 不喜欢基础技术的职业：否时加分

      6: userPickedAnswer
          ? [7, 8, 10, 17] // 对硬件技术感兴趣的职业：是时加分
          : [0, 1, 2, 4, 5, 9], // 不喜欢硬件技术的职业：否时加分

      7: userPickedAnswer
          ? [0, 3, 6, 9, 15, 16] // 喜欢创造性工作的职业：是时加分
          : [2, 4, 5, 8, 12], // 不喜欢创造性工作的职业：否时加分

      8: userPickedAnswer
          ? [2, 5, 6, 11, 13] // 快速学习新技术的职业：是时加分
          : [0, 3, 7, 10], // 不擅长学习新技术的职业：否时加分

      9: userPickedAnswer
          ? [0, 4, 5, 10, 12] // 有领导力的职业：是时加分
          : [1, 2, 7, 13], // 没有领导力的职业：否时加分

      10: userPickedAnswer
          ? [0, 1, 5, 9, 13] // 客户导向的职业：是时加分
          : [2, 3, 6, 8, 11], // 不喜欢客户导向的职业：否时加分

      11: userPickedAnswer
          ? [0, 2, 5, 7, 13] // 喜欢变动环境的职业：是时加分
          : [1, 3, 6, 9], // 喜欢稳定环境的职业：否时加分

      12: userPickedAnswer
          ? [1, 4, 10, 14] // 喜欢支持其他人的职业：是时加分
          : [0, 2, 5, 7, 9], // 不喜欢支持他人的职业：否时加分

      13: userPickedAnswer
          ? [0, 4, 6, 7, 15] // 实现创意的职业：是时加分
          : [2, 3, 5, 9], // 不喜欢实现创意的职业：否时加分

      14: userPickedAnswer
          ? [1, 4, 10, 14] // 善于逻辑思维的职业：是时加分
          : [0, 2, 6, 10, 13], // 不善于逻辑思维的职业：否时加分

      15: userPickedAnswer
          ? [2, 4, 5, 7, 17] // 对数据分析有兴趣的职业：是时加分
          : [1, 3, 6, 10], // 不喜欢数据分析的职业：否时加分
    };

    // 根据用户的选择更新职业得分
    for (int careerIndex in questionToCareerMap[questionIndex] ?? []) {
      quizBrain.scores[careerIndex] += 1; // 如果选中该选项，为相关职业加分
    }
  }

  List<int> getTop4Careers() {
    List<MapEntry<int, int>> scoreWithIndex = scores.asMap().entries.toList();
    scoreWithIndex.sort((a, b) => b.value.compareTo(a.value));
    return scoreWithIndex.take(4).map((entry) => entry.key + 1).toList();
  }

  void nextQuestion() {
    if (_questionNumber < _questionBank.length - 1) {
      _questionNumber++;
    }
  }

  String getQuestionText() {
    return _questionBank[_questionNumber].questionText;
  }

  int getQuestionIndex() {
    return _questionNumber;
  }

  bool isFinished() {
    return _questionNumber >= _questionBank.length - 1;
  }

  void reset() {
    _questionNumber = 0;
    scores = List.filled(19, 0);
  }
}
