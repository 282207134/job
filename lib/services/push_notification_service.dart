import 'dart:convert'; // 导入 JSON 编解码库

import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 数据库库
import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:firebase_core/firebase_core.dart'; // 导入 Firebase 核心库
import 'package:firebase_messaging/firebase_messaging.dart'; // 导入 Firebase 消息推送库
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具库
import 'package:flutter/widgets.dart'; // 导入 Flutter Widgets 库
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 导入本地通知插件
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理库

import '../firebase_options.dart'; // 导入 Firebase 配置选项
import 'push_payload_router.dart'; // 导入推送载荷路由器

/// 消息类(私信、好友、日历等):`res/raw/message.wav`,系统通知只响一次。
const String androidMessageChannelId = 'kantankanri_msg_sfx'; // Android 消息通道 ID
const String androidMessageChannelName = '消息与提醒'; // Android 消息通道名称

/// 来电推送:`res/raw/notify.wav`;全屏接听界面另用 [AssetSource] 循环播放同一文件。
const String androidCallChannelId = 'kantankanri_call_sfx'; // Android 来电通道 ID
const String androidCallChannelName = '语音视频来电'; // Android 来电通道名称

bool _isIncomingCallPayload(Map<String, dynamic> data) { // 判断是否为来电推送载荷
  final t = data['type']; // 获取类型字段
  if (t == null) return false; // 如果类型为空,返回 false
  return '$t' == 'incoming_call'; // 判断是否为来电类型
}

Future<void> _ensureAndroidNotifyChannels( // 确保 Android 通知通道已创建
  AndroidFlutterLocalNotificationsPlugin? android, // Android 本地通知插件实例
) async { // 异步方法
  if (android == null) return; // 如果插件为空,直接返回
  await android.createNotificationChannel( // 创建消息通知通道
    AndroidNotificationChannel( // Android 通知通道配置
      androidMessageChannelId, // 通道 ID
      androidMessageChannelName, // 通道名称
      description: '私信、好友与日历等（自定义短提示音，每条一次）', // 通道描述
      importance: Importance.max, // 重要性:最高
      playSound: true, // 播放声音
      sound: RawResourceAndroidNotificationSound('message'), // 使用 message.wav 音效
      enableVibration: true, // 启用振动
      showBadge: true, // 显示角标
    ),
  );
  await android.createNotificationChannel( // 创建来电通知通道
    AndroidNotificationChannel( // Android 通知通道配置
      androidCallChannelId, // 通道 ID
      androidCallChannelName, // 通道名称
      description: '语音/视频来电推送', // 通道描述
      importance: Importance.max, // 重要性:最高
      playSound: true, // 播放声音
      sound: RawResourceAndroidNotificationSound('notify'), // 使用 notify.wav 音效
      enableVibration: true, // 启用振动
      showBadge: true, // 显示角标
    ),
  );
}

NotificationDetails _notificationDetailsForPayload( // 根据载荷生成通知详情
  Map<String, dynamic> data, { // 推送数据
  String? tag, // 通知标签
}) {
  final call = _isIncomingCallPayload(data); // 判断是否为来电
  return NotificationDetails( // 返回通知详情
    android: AndroidNotificationDetails( // Android 通知详情
      call ? androidCallChannelId : androidMessageChannelId, // 根据类型选择通道 ID
      call ? androidCallChannelName : androidMessageChannelName, // 根据类型选择通道名称
      channelDescription:
          call ? '语音或视频来电' : '消息、好友与日历等', // 通道描述
      importance: Importance.max, // 重要性:最高
      priority: Priority.max, // 优先级:最高
      category: call // 通知类别
          ? AndroidNotificationCategory.call // 来电类别
          : AndroidNotificationCategory.message, // 消息类别
      visibility: NotificationVisibility.public, // 可见性:公开
      playSound: true, // 播放声音
      enableVibration: true, // 启用振动
      sound: RawResourceAndroidNotificationSound(call ? 'notify' : 'message'), // 根据类型选择音效
      onlyAlertOnce: false, // 每次都要提醒
      tag: tag, // 通知标签
    ),
    iOS: DarwinNotificationDetails( // iOS 通知详情
      presentSound: true, // 播放声音
      sound: call ? 'notify.wav' : 'message.wav', // 根据类型选择音效文件
    ),
  );
}

@pragma('vm:entry-point') // 标记为 VM 入口点(后台消息处理器需要)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async { // Firebase 消息后台处理器
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定已初始化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // 初始化 Firebase
  debugPrint( // 打印日志
    'FCM background: id=${message.messageId} ' // 消息 ID
    'hasNotification=${message.notification != null} data=${message.data}', // 是否有通知和数据
  );

  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return; // 如果是 Web 或非 Android,直接返回

  final plugin = FlutterLocalNotificationsPlugin(); // 创建本地通知插件实例
  await plugin.initialize( // 初始化插件
    settings: const InitializationSettings( // 初始化设置
      android: AndroidInitializationSettings('@mipmap/ic_launcher'), // Android 图标
    ),
  );
  final androidImpl = plugin.resolvePlatformSpecificImplementation< // 获取 Android 实现
      AndroidFlutterLocalNotificationsPlugin>();
  await _ensureAndroidNotifyChannels(androidImpl); // 确保通知通道已创建

  final title = _fcmTitle(message); // 获取标题
  final body = _fcmBody(message); // 获取内容
  if (title.isEmpty && body.isEmpty) { // 如果标题和内容都为空
    debugPrint('FCM background: skip show (no title/body in data or notification)'); // 打印跳过日志
    return; // 直接返回
  }

  final dataMap = Map<String, dynamic>.from(message.data); // 转换数据为映射
  final nid = (message.messageId ?? '${message.hashCode}').hashCode & 0x7fffffff; // 生成通知 ID
  await plugin.show( // 显示通知
    id: nid, // 通知 ID
    title: title.isEmpty ? '通知' : title, // 标题,如果为空则使用默认值
    body: body, // 内容
    notificationDetails: _notificationDetailsForPayload( // 通知详情
      dataMap, // 数据映射
      tag: message.messageId ?? 'kantankanri', // 标签
    ),
    payload: jsonEncode(message.data), // 载荷:JSON 编码的数据
  );
}

String _fcmTitle(RemoteMessage m) { // 获取 FCM 消息标题
  final d = m.data['title']; // 从数据中获取标题
  if (d is String && d.isNotEmpty) return d; // 如果数据中有标题且不为空,返回
  return m.notification?.title ?? ''; // 否则从通知对象获取,如果为空则返回空字符串
}

String _fcmBody(RemoteMessage m) { // 获取 FCM 消息内容
  final d = m.data['body']; // 从数据中获取内容
  if (d is String && d.isNotEmpty) return d; // 如果数据中有内容且不为空,返回
  return m.notification?.body ?? ''; // 否则从通知对象获取,如果为空则返回空字符串
}

/// 将 FCM token 写入 `users/{uid}.fcm_token`,供 Cloud Functions 发推送。
class PushNotificationService { // 推送通知服务类
  PushNotificationService._(); // 私有构造函数,防止实例化

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance; // Firebase 消息实例
  static final FlutterLocalNotificationsPlugin _local = // 本地通知插件实例
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false; // 是否已初始化

  static Future<void> syncTokenNow() async { // 立即同步 Token
    if (kIsWeb) return; // 如果是 Web,直接返回
    await _syncTokenToFirestore(); // 同步 Token 到 Firestore
  }

  static Future<void> onAppResumed() async { // 应用恢复时调用
    if (kIsWeb) return; // 如果是 Web,直接返回
    await _syncTokenToFirestore(); // 同步 Token 到 Firestore
  }

  static Future<void> initialize() async { // 初始化推送服务
    if (kIsWeb) return; // 如果是 Web,直接返回
    if (_initialized) return; // 如果已初始化,直接返回
    _initialized = true; // 标记为已初始化

    await _ensureLocalNotifications(); // 确保本地通知已初始化

    await _messaging.setForegroundNotificationPresentationOptions( // 设置前台通知展示选项
      alert: true, // 显示警报
      badge: true, // 显示角标
      sound: true, // 播放声音
    );

    final settings = await _messaging.requestPermission( // 请求通知权限
      alert: true, // 警报权限
      announcement: false, // 公告权限
      badge: true, // 角标权限
      carPlay: false, // CarPlay 权限
      criticalAlert: false, // 紧急警报权限
      provisional: false, // 临时权限
      sound: true, // 声音权限
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}'); // 打印权限状态

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) { // 如果是 Android
      var n = await Permission.notification.status; // 获取通知权限状态
      if (!n.isGranted) { // 如果未授予
        n = await Permission.notification.request(); // 请求通知权限
      }
      debugPrint( // 打印权限状态
        'Android notification: status=$n granted=${n.isGranted} ' // 是否授予
        'provisional=${n.isProvisional} limited=${n.isLimited}', // 是否临时或受限
      );
      final bat = await Permission.ignoreBatteryOptimizations.status; // 获取忽略电池优化权限状态
      if (!bat.isGranted) { // 如果未授予
        final r = await Permission.ignoreBatteryOptimizations.request(); // 请求忽略电池优化权限
        debugPrint('Android ignore battery optimizations: $r'); // 打印结果
      }
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) { // 监听认证状态变化
      if (user != null) { // 如果用户已登录
        _syncTokenToFirestore(); // 同步 Token 到 Firestore
      }
    });

    await Future<void>.delayed(Duration.zero); // 等待一帧
    await _syncTokenToFirestore(); // 同步 Token 到 Firestore

    FirebaseMessaging.instance.onTokenRefresh.listen(_persistToken); // 监听 Token 刷新事件

    FirebaseMessaging.onMessage.listen(_showForegroundNotification); // 监听前台消息

    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened); // 监听消息打开事件

    final initial = await _messaging.getInitialMessage(); // 获取初始消息(从通知启动)
    if (initial != null) { // 如果有初始消息
      _onOpened(initial); // 处理打开事件
    }
  }

  static Future<void> _ensureLocalNotifications() async { // 确保本地通知已初始化
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher'); // Android 初始化设置
    const iosInit = DarwinInitializationSettings( // iOS 初始化设置
      requestAlertPermission: true, // 请求警报权限
      requestBadgePermission: true, // 请求角标权限
      requestSoundPermission: true, // 请求声音权限
    );
    await _local.initialize( // 初始化本地通知插件
      settings: const InitializationSettings( // 初始化设置
        android: androidInit, // Android 设置
        iOS: iosInit, // iOS 设置
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap, // 通知点击回调
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation< // 获取 Android 实现
        AndroidFlutterLocalNotificationsPlugin>();
    await _ensureAndroidNotifyChannels(androidPlugin); // 确保通知通道已创建
  }

  static void _onLocalNotificationTap(NotificationResponse response) { // 本地通知点击处理
    final p = response.payload; // 获取载荷
    if (p == null || p.isEmpty) return; // 如果载荷为空,直接返回
    try { // 尝试解析载荷
      final map = jsonDecode(p) as Map<String, dynamic>; // JSON 解码
      debugPrint('Local notification tap: $map'); // 打印日志
      PushPayloadRouter.scheduleHandle(map); // 路由处理载荷
    } catch (_) {} // 捕获异常
  }

  static Future<void> _syncTokenToFirestore() async { // 同步 Token 到 Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (uid == null) { // 如果未登录
      debugPrint('FCM sync skipped: no signed-in user'); // 打印跳过日志
      return; // 直接返回
    }
    try { // 尝试同步
      final token = await _messaging.getToken(); // 获取 FCM Token
      if (token != null) { // 如果 Token 不为空
        await _persistToken(token); // 保存 Token
        debugPrint('FCM token saved for uid=$uid (len=${token.length})'); // 打印成功日志
      } else { // 如果 Token 为空
        debugPrint('FCM getToken returned null'); // 打印错误日志
      }
    } catch (e) { // 捕获异常
      debugPrint('FCM getToken failed: $e'); // 打印失败日志
    }
  }

  static Future<void> _persistToken(String token) async { // 保存 Token 到 Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (uid == null) return; // 如果未登录,直接返回
    try { // 尝试保存
      await FirebaseFirestore.instance.collection('users').doc(uid).set( // 更新用户文档
        {
          'fcm_token': token, // FCM Token
          'fcm_token_updated_at': FieldValue.serverTimestamp(), // 更新时间戳
        },
        SetOptions(merge: true), // 合并选项
      );
    } catch (e) { // 捕获异常
      debugPrint('FCM save token to Firestore failed: $e'); // 打印失败日志
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async { // 显示前台通知
    final t = _fcmTitle(message); // 获取标题
    final title = t.isEmpty ? '通知' : t; // 如果标题为空,使用默认值
    final body = _fcmBody(message); // 获取内容
    final dataMap = Map<String, dynamic>.from(message.data); // 转换数据为映射

    await _local.show( // 显示本地通知
      id: message.hashCode, // 通知 ID
      title: title, // 标题
      body: body, // 内容
      notificationDetails: _notificationDetailsForPayload(dataMap), // 通知详情
      payload: jsonEncode(message.data), // 载荷:JSON 编码的数据
    );
  }

  static void _onOpened(RemoteMessage message) { // 消息打开处理
    debugPrint('FCM notification opened: ${message.data}'); // 打印日志
    PushPayloadRouter.scheduleHandle(message.data); // 路由处理载荷
  }
}
