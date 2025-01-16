import 'package:adaptive_theme/adaptive_theme.dart'; // 导入自适应主题包
import 'package:flutter/cupertino.dart'; // 导入 Cupertino 组件包

class CupertinoExample extends StatelessWidget { // Cupertino 示例类

  final AdaptiveThemeMode? savedThemeMode; // 保存的主题模式
  final VoidCallback onChanged; // 切换主题的回调

  const CupertinoExample({ // 构造函数
    super.key,
    this.savedThemeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) { // 构建方法
    return CupertinoAdaptiveTheme( // 自适应 Cupertino 主题
      light: const CupertinoThemeData(brightness: Brightness.light), // 亮色主题
      dark: const CupertinoThemeData(brightness: Brightness.dark), // 暗色主题
      initial: savedThemeMode ?? AdaptiveThemeMode.light, // 初始化主题模式
      debugShowFloatingThemeButton: true, // 调试时显示浮动主题按钮
      builder: (theme) => CupertinoApp( // 构建 Cupertino 应用
        title: 'Adaptive Theme Demo', // 应用标题
        theme: theme, // 主题
        home: MyHomePage(onChanged: onChanged), // 首页
      ),
    );
  }
}

class MyHomePage extends StatefulWidget { // 主页面类
  final VoidCallback onChanged; // 切换主题的回调

  const MyHomePage({super.key, required this.onChanged}); // 构造函数

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // 创建状态管理
}

class _MyHomePageState extends State<MyHomePage> { // 主页面状态管理
  @override
  Widget build(BuildContext context) { // 构建方法
    return CupertinoPageScaffold( // 使用 Cupertino 页面脚手架
      navigationBar: const CupertinoNavigationBar( // 导航栏
        middle: Text('Cupertino Example'), // 导航栏标题
      ),
      child: SafeArea( // 安全区域
        child: SizedBox.expand( // 填充整个可用空间
          child: Column( // 使用列布局
            crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
            mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
            children: [
              const Spacer(), // 占据可用空间的间隔
              const Text( // 显示当前主题模式文本
                'Current Theme Mode', // 当前主题模式
                style: TextStyle( // 文本样式
                  fontSize: 20,
                  letterSpacing: 0.8,
                ),
              ),
              Text( // 显示当前主题模式的名称
                CupertinoAdaptiveTheme.of(context).mode.modeName.toUpperCase(), // 主题模式名称
                style: const TextStyle( // 文本样式
                  fontSize: 24,
                  height: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(), // 占据可用空间的间隔
              CupertinoButton.filled( // 填充按钮，切换主题模式
                onPressed: () =>
                    CupertinoAdaptiveTheme.of(context).toggleThemeMode(),
                child: const Text('Toggle Theme Mode'), // 按钮文本
              ),
              const SizedBox(height: 16), // 空间间隔
              CupertinoButton.filled( // 填充按钮，设置为暗色主题
                onPressed: () => CupertinoAdaptiveTheme.of(context).setDark(),
                child: const Text('Set Dark'), // 按钮文本
              ),
              const SizedBox(height: 16), // 空间间隔
              CupertinoButton.filled( // 填充按钮，设置为亮色主题
                onPressed: () => CupertinoAdaptiveTheme.of(context).setLight(),
                child: const Text('Set Light'), // 按钮文本
              ),
              const SizedBox(height: 16), // 空间间隔
              CupertinoButton.filled( // 填充按钮，设置为系统默认主题
                onPressed: () => CupertinoAdaptiveTheme.of(context).setSystem(),
                child: const Text('Set System Default'), // 按钮文本
              ),
              const SizedBox(height: 16), // 空间间隔
              CupertinoButton.filled( // 填充按钮，设置自定义主题
                onPressed: () =>
                    CupertinoAdaptiveTheme.maybeOf(context)?.setTheme(
                      light: const CupertinoThemeData( // 亮色自定义主题
                          brightness: Brightness.light,
                          primaryColor: CupertinoColors.destructiveRed), // 主色为红色
                      dark: const CupertinoThemeData( // 暗色自定义主题
                          brightness: Brightness.dark,
                          primaryColor: CupertinoColors.systemYellow), // 主色为黄色
                    ),
                child: const Text('Set Custom Theme'), // 按钮文本
              ),
              const SizedBox(height: 16), // 空间间隔
              CupertinoButton.filled( // 填充按钮，重置到默认主题
                onPressed: () => CupertinoAdaptiveTheme.of(context).reset(),
                child: const Text('Reset to Default Themes'), // 按钮文本
              ),
              const Spacer(flex: 2), // 占据更多的可用空间
              CupertinoButton( // 文本按钮，切换到 Material 示例
                onPressed: widget.onChanged,
                child: const Text('Switch to Material Example'), // 按钮文本
              ),
            ],
          ),
        ),
      ),
    );
  }
}
