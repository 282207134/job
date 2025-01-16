import 'package:adaptive_theme/adaptive_theme.dart'; // 导入自适应主题包
import 'package:flutter/cupertino.dart'; // 导入 Cupertino 组件
import 'package:flutter/material.dart'; // 导入 Material 组件
import 'package:flutter/widgets.dart'; // 导入 Flutter 小部件
import 'cupertino_example.dart'; // 导入 Cupertino 示例
import 'material_example.dart'; // 导入 Material 示例

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 引擎已初始化
  final savedThemeMode = await AdaptiveTheme.getThemeMode(); // 获取保存的主题模式
  runApp(MyApp(savedThemeMode: savedThemeMode)); // 运行 MyApp，并传入保存的主题模式
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode; // 定义保存的主题模式

  const MyApp({super.key, this.savedThemeMode}); // 构造函数

  @override
  State<MyApp> createState() => _MyAppState(); // 创建状态管理
}

class _MyAppState extends State<MyApp> {
  bool isMaterial = true; // 用于标记当前是否为 Material 主题

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher( // 使用动画切换器
      duration: const Duration(seconds: 1), // 动画持续时间为1秒
      child: isMaterial // 根据 isMaterial 的值选择显示的组件
          ? MaterialExample( // 如果是 Material 主题，显示 Material 示例
        savedThemeMode: widget.savedThemeMode, // 传入保存的主题模式
        onChanged: () => setState(() => isMaterial = false), // 切换到 Cupertino 主题
      )
          : CupertinoExample( // 如果不是 Material 主题，显示 Cupertino 示例
        savedThemeMode: widget.savedThemeMode, // 传入保存的主题模式
        onChanged: () => setState(() => isMaterial = true), // 切换到 Material 主题
      ),
    );
  }
}
