import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // 导入闪屏动画库
import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 身份验证包
import 'package:firebase_core/firebase_core.dart'; // 导入 Firebase 核心包
import 'package:firebase_messaging/firebase_messaging.dart'; // 导入 Firebase 消息推送包
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具库(包含 kIsWeb 等)
import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 导入环境变量加载库
import 'package:flutter_localizations/flutter_localizations.dart'; // 导入 Flutter 本地化支持
import 'package:kantankanri/app/app_routes.dart'; // 导入应用路由配置
import 'package:kantankanri/app/home_page.dart'; // 导入主页组件
import 'package:kantankanri/providers/app_language_provider.dart'; // 导入多语言状态管理器
import 'package:kantankanri/providers/app_lock_provider.dart'; // 导入应用锁状态管理器
import 'package:kantankanri/providers/userProvider.dart'; // 导入用户状态管理器
import 'package:kantankanri/screens/app_lock_gate_screen.dart'; // 导入应用锁门禁界面
import 'package:kantankanri/services/onesignal_push_service.dart'; // 导入 OneSignal 推送服务
import 'package:kantankanri/services/push_notification_service.dart'; // 导入推送通知服务
import 'package:kantankanri/services/push_payload_router.dart'; // 导入推送载荷路由器
import 'package:kantankanri/widgets/global_incoming_call_host.dart'; // 导入全局来电显示组件
import 'package:kantankanri/splashScreen/OnBoardingPageState.dart'; // 导入引导页组件
import 'package:provider/provider.dart'; // 导入 Provider 状态管理库

import 'firebase_options.dart'; // 导入 Firebase 多平台配置文件

class MyApp extends StatefulWidget { // 定义 MyApp 有状态组件类
  const MyApp({super.key}); // 构造函数,传递 key 参数

  @override // 重写父类方法
  State<MyApp> createState() => _MyAppState(); // 创建并返回状态对象
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver { // MyApp 的状态类,混入生命周期观察者
  /// [MaterialApp.builder] 内的组件不是 Navigator 的子组件,
  /// 要从来电 UI push 路由,需要使用这个全局键。
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(); // 根导航器全局键

  @override // 重写初始化方法
  void initState() { // 状态初始化
    super.initState(); // 调用父类初始化
    WidgetsBinding.instance.addObserver(this); // 添加生命周期观察者
    PushPayloadRouter.attachNavigator(_rootNavigatorKey); // 附加导航器到推送路由器
    // OneSignal 必须在界面/Activity 就绪后再请求通知权限,否则控制台长期显示 Permission Not Granted
    WidgetsBinding.instance.addPostFrameCallback((_) { // 添加帧后回调
      Future<void>.delayed(const Duration(milliseconds: 400), () { // 延迟 400 毫秒
        OneSignalPushService.promptForPushPermission(); // 请求推送权限
      });
    });
  }

  @override // 重写销毁方法
  void dispose() { // 资源释放
    WidgetsBinding.instance.removeObserver(this); // 移除生命周期观察者
    super.dispose(); // 调用父类销毁
  }

  @override // 重写生命周期变化回调
  void didChangeAppLifecycleState(AppLifecycleState state) { // 应用生命周期状态变化
    if (state == AppLifecycleState.resumed) { // 如果应用恢复前台
      PushNotificationService.onAppResumed(); // 同步 FCM Token
    }
  }

  @override // 重写构建方法
  Widget build(BuildContext context) { // 构建 UI
    return Consumer2<AppLanguageProvider, AppLockProvider>( // 消费两个 Provider
      builder: (context, lang, lock, _) => Listener( // 监听器包装
        behavior: HitTestBehavior.translucent, // 点击行为:透明穿透
        onPointerDown: (_) => lock.recordActivity(), // 记录用户活动(用于自动锁定)
        child: MaterialApp( // Material 应用
          navigatorKey: _rootNavigatorKey, // 设置导航器全局键
          debugShowCheckedModeBanner: false, // 隐藏调试横幅
          theme: ThemeData( // 应用主题配置
            useMaterial3: true, // 启用 Material 3 设计
            colorScheme: ColorScheme.fromSeed( // 从种子颜色生成配色方案
              seedColor: const Color(0xFF3949AB), // 种子颜色:靛蓝色
              brightness: Brightness.light, // 亮度:浅色模式
            ),
            scaffoldBackgroundColor: const Color(0xFFF2F4F7), // Scaffold 背景色:浅灰色
            dividerTheme: DividerThemeData( // 分割线主题
              color: Colors.grey.shade300, // 颜色:浅灰色
              thickness: 1, // 厚度:1像素
              space: 1, // 间距:1像素
            ),
            cardTheme: CardThemeData( // 卡片主题
              color: Colors.white, // 卡片颜色:白色
              elevation: 0, // 阴影高度:0
              shape: RoundedRectangleBorder( // 形状:圆角矩形
                borderRadius: BorderRadius.circular(12), // 圆角半径:12
                side: BorderSide(color: Colors.grey.shade200), // 边框:极浅灰色
              ),
            ),
          ),
          locale: lang.locale, // 当前语言环境
          supportedLocales: const [ // 支持的语言列表
            Locale('zh'), // 中文
            Locale('ja'), // 日文
            Locale('en'), // 英文
          ],
          localizationsDelegates: const [ // 本地化代理
            GlobalMaterialLocalizations.delegate, // Material 组件本地化
            GlobalWidgetsLocalizations.delegate, // Widgets 本地化
            GlobalCupertinoLocalizations.delegate, // Cupertino(iOS风格)本地化
          ],
          builder: (context, child) { // 自定义构建器
            final hasUser = FirebaseAuth.instance.currentUser != null; // 判断是否有登录用户
            final showLockGate =
                hasUser && lock.ready && lock.shouldRequireUnlock; // 是否显示应用锁门禁
            return Stack( // 堆叠布局
              children: [
                if (child != null) child, // 如果子组件存在则显示
                if (showLockGate) // 如果需要显示应用锁
                  const Positioned.fill(child: AppLockGateScreen()), // 全屏显示门禁界面
                GlobalIncomingCallHost(navigatorKey: _rootNavigatorKey), // 全局来电显示
              ],
            );
          },
          home: StreamBuilder<User?>( // 首页:监听认证状态流
            stream: FirebaseAuth.instance.authStateChanges(), // Firebase 认证状态变化流
            builder: (context, snapshot) { // 构建器
              if (snapshot.connectionState == ConnectionState.waiting) { // 如果正在等待
                return const Center(child: CircularProgressIndicator()); // 显示加载指示器
              }
              if (snapshot.hasData) { // 如果有用户数据(已登录)
                return FutureBuilder<void>( // 等待应用锁同步
                  future: lock.ensureSynced(snapshot.data!.uid), // 确保锁状态同步
                  builder: (context, lockSnap) { // 构建器
                    if (lockSnap.connectionState != ConnectionState.done ||
                        !lock.ready) { // 如果未完成或未就绪
                      return const Center(child: CircularProgressIndicator()); // 显示加载指示器
                    }
                    return const HomePage(); // 返回主页
                  },
                );
              }
              return FutureBuilder<void>( // 未登录情况:等待锁同步
                future: lock.ensureSynced(null), // 同步锁状态(无用户)
                builder: (context, lockSnap) { // 构建器
                  if (lockSnap.connectionState != ConnectionState.done ||
                      !lock.ready) { // 如果未完成或未就绪
                    return const Center(child: CircularProgressIndicator()); // 显示加载指示器
                  }
                  return FlutterSplashScreen.fadeIn( // 淡入式闪屏
                    backgroundColor: Colors.cyan, // 背景颜色:青色
                    duration: const Duration(seconds: 5), // 显示时间:5秒
                    animationDuration: const Duration(seconds: 10), // 动画时长:10秒
                    onInit: () => debugPrint('On Init'), // 初始化回调
                    onEnd: () => debugPrint('On End'), // 结束回调
                    childWidget: SizedBox( // 子组件:固定尺寸容器
                      height: double.infinity, // 高度:无限
                      width: double.infinity, // 宽度:无限
                      child: Image.asset('assets/0.jpg'), // 图片资源
                    ),
                    onAnimationEnd: () => debugPrint('On Fade In End'), // 动画结束回调
                    nextScreen: const OnBoardingPage(), // 下一个屏幕:引导页
                  );
                },
              );
            },
          ),
          routes: buildAppRoutes(), // 应用路由表
        ),
      ),
    );
  }
}

Future<void> main() async { // 应用入口主函数
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定已初始化(在异步操作前必须调用)
  try { // 尝试加载环境变量
    await dotenv.load(fileName: '.env', isOptional: true); // 加载 .env 文件,可选(不存在也不报错)
  } catch (e, st) { // 捕获异常
    debugPrint('dotenv: $e\n$st'); // 打印错误信息和堆栈跟踪
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // 初始化 Firebase(根据当前平台自动选择配置)
  if (!kIsWeb) { // 如果不是 Web 平台
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler); // 注册后台消息处理器
    await PushNotificationService.initialize(); // 初始化推送通知服务(FCM + 本地通知)
    await OneSignalPushService.initialize(); // 初始化 OneSignal 推送服务
  }
  runApp( // 运行应用
    MultiProvider( // 多 Provider 包装器
      providers: [ // Provider 列表
        ChangeNotifierProvider(create: (context) => UserProvider()), // 用户状态管理器
        ChangeNotifierProvider(create: (context) => AppLanguageProvider()), // 多语言管理器
        ChangeNotifierProvider(create: (context) => AppLockProvider()), // 应用锁管理器
      ],
      child: const MyApp(), // 子组件:MyApp
    ),
  );
}
