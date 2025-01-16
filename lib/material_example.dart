import 'package:adaptive_theme/adaptive_theme.dart'; // 导入自适应主题包
import 'package:flutter/material.dart'; // 导入 Material 组件包

class MaterialExample extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode; // 保存主题模式
  final VoidCallback onChanged; // 切换主题的回调

  const MaterialExample({ // 构造函数
    super.key,
    this.savedThemeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) { // 构建方法
    return AdaptiveTheme( // 自适应主题
      light: ThemeData.light( // 亮色主题
        useMaterial3: true, // 使用 Material 3
      ),
      dark: ThemeData.dark( // 暗色主题
        useMaterial3: true, // 使用 Material 3
      ),
      debugShowFloatingThemeButton: true, // 显示浮动主题按钮（调试用）
      initial: savedThemeMode ?? AdaptiveThemeMode.light, // 初始化主题模式
      builder: (theme, darkTheme) => MaterialApp( // 构建 Material 应用
        title: 'Adaptive Theme Demo', // 应用标题
        theme: theme, // 主题
        darkTheme: darkTheme, // 暗色主题
        home: MyHomePage(onChanged: onChanged), // 首页
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback onChanged; // 切换主题的回调

  const MyHomePage({super.key, required this.onChanged}); // 构造函数

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // 创建状态管理
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) { // 构建方法
    return AnimatedTheme( // 使用动画主题
      duration: const Duration(milliseconds: 200), // 动画持续时间
      curve: Curves.easeOut, // 动画曲线
      data: Theme.of(context), // 当前主题数据
      child: Scaffold( // 使用 Scaffold 组件
        appBar: AppBar( // 应用栏
          title: const Text('Material Example'), // 应用栏标题
        ),
        body: SafeArea( // 安全区域
          child: SizedBox.expand( // 填充整个可用空间
            child: Column( // 使用列布局
              crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
              mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
              children: [
                const Spacer(), // 占据可用空间的间隔
                const Text( // 文本组件
                  'Current Theme Mode', // 当前主题模式文本
                  style: TextStyle( // 文本样式
                    fontSize: 20,
                    letterSpacing: 0.8,
                  ),
                ),
                Text( // 显示当前主题模式名称
                  AdaptiveTheme.of(context).mode.modeName.toUpperCase(), // 主题模式名称
                  style: const TextStyle( // 文本样式
                    fontSize: 24,
                    height: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(), // 占据可用空间的间隔
                FilledButton( // 填充按钮，切换主题模式
                  onPressed: () => AdaptiveTheme.of(context).toggleThemeMode(),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Toggle Theme Mode'), // 按钮文本
                ),
                const SizedBox(height: 8), // 空间间隔
                FilledButton( // 填充按钮，设置为暗色主题
                  onPressed: () => AdaptiveTheme.of(context).setDark(),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Set Dark'), // 按钮文本
                ),
                const SizedBox(height: 8), // 空间间隔
                FilledButton( // 填充按钮，设置为亮色主题
                  onPressed: () => AdaptiveTheme.of(context).setLight(),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Set Light'), // 按钮文本
                ),
                const SizedBox(height: 8), // 空间间隔
                FilledButton( // 填充按钮，设置为系统默认主题
                  onPressed: () => AdaptiveTheme.of(context).setSystem(),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Set System Default'), // 按钮文本
                ),
                const SizedBox(height: 8), // 空间间隔
                FilledButton( // 填充按钮，设置为自定义主题
                  onPressed: () => AdaptiveTheme.of(context).setTheme(
                    light: ThemeData( // 设置亮色主题
                      useMaterial3: true, // 使用 Material 3
                      colorSchemeSeed: Colors.pink, // 主题色
                      brightness: Brightness.light, // 亮度
                    ),
                    dark: ThemeData( // 设置暗色主题
                      useMaterial3: true, // 使用 Material 3
                      brightness: Brightness.dark, // 亮度
                      colorSchemeSeed: Colors.pink, // 主题色
                    ),
                  ),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Set Custom Theme'), // 按钮文本
                ),
                const SizedBox(height: 8), // 空间间隔
                FilledButton( // 填充按钮，重置主题到默认
                  onPressed: () => AdaptiveTheme.of(context).reset(),
                  style: ElevatedButton.styleFrom( // 按钮样式
                    visualDensity:
                    const VisualDensity(horizontal: 4, vertical: 2),
                  ),
                  child: const Text('Reset to Default Themes'), // 按钮文本
                ),
                const Spacer(flex: 2), // 占据更大的可用空间
                TextButton( // 文本按钮，切换到 Cupertino 示例
                  onPressed: widget.onChanged,
                  child: const Text('Switch to Cupertino Example'), // 按钮文本
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton( // 悬浮按钮
          onPressed: () {},
          child: const Icon(Icons.add), // 按钮图标
        ),
      ),
    );
  }
}
