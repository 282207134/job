import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 数据库库
import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:flutter/material.dart'; // 导入 Flutter Material 组件库
import 'package:provider/provider.dart'; // 导入 Provider 状态管理库

import 'package:kantankanri/providers/app_language_provider.dart'; // 导入多语言提供者
import 'package:kantankanri/screens/contacts_messages_screen.dart'; // 导入联系人消息界面
import 'package:kantankanri/screens/direct_chat_screen.dart'; // 导入私聊界面
import 'package:kantankanri/screens/shared_calendar_sheet.dart'; // 导入共享日历弹窗

/// 从 Cloud Functions / OneSignal / FCM 的 data 载荷(`type`, `pair_id` 等)路由到对应界面。
class PushPayloadRouter { // 推送载荷路由器类
  PushPayloadRouter._(); // 私有构造函数,防止实例化

  static GlobalKey<NavigatorState>? _navigatorKey; // 导航器全局键
  static Map<String, String>? _queued; // 待处理的载荷队列
  static int _drainAttempt = 0; // 重试次数计数器
  static const int _maxDrainAttempts = 25; // 最大重试次数

  static void attachNavigator(GlobalKey<NavigatorState> key) { // 附加导航器
    _navigatorKey = key; // 保存导航器键
  }

  static Map<String, String> _normalize(Map<dynamic, dynamic>? raw) { // 标准化载荷数据
    final out = <String, String>{}; // 创建输出映射
    if (raw == null) return out; // 如果为空,返回空映射
    for (final e in raw.entries) { // 遍历所有条目
      final k = '${e.key}'.trim(); // 获取键并去除空格
      if (k.isEmpty) continue; // 如果键为空,跳过
      if (e.value == null) continue; // 如果值为空,跳过
      final v = '${e.value}'.trim(); // 获取值并去除空格
      if (v.isEmpty) continue; // 如果值为空,跳过
      out[k] = v; // 添加到输出映射
    }
    return out; // 返回标准化后的映射
  }

  /// 导航器和登录状态准备好之前重试数次(冷启动时)。
  static void scheduleHandle(Object? raw) { // 调度处理载荷
    if (raw is! Map) { // 如果不是 Map 类型
      debugPrint('PushPayloadRouter: skip (payload is not a Map)'); // 打印跳过日志
      return; // 直接返回
    }
    final norm = _normalize(Map<dynamic, dynamic>.from(raw)); // 标准化载荷
    if (norm['type'] == null && norm.isEmpty) { // 如果没有 type 且为空
      debugPrint('PushPayloadRouter: skip (empty payload)'); // 打印跳过日志
      return; // 直接返回
    }
    _queued = norm; // 保存到队列
    _drainAttempt = 0; // 重置重试次数
    _pumpDrain(); // 开始处理
  }

  static void _pumpDrain() { // 泵送处理(重试机制)
    WidgetsBinding.instance.addPostFrameCallback((_) async { // 添加帧后回调
      final nav = _navigatorKey; // 获取导航器键
      final ctx = nav?.currentContext; // 获取当前上下文
      final uid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
      if (ctx == null || uid == null || !ctx.mounted) { // 如果上下文为空或未登录或已卸载
        if (_drainAttempt++ < _maxDrainAttempts) { // 如果重试次数未超限
          await Future<void>.delayed(const Duration(milliseconds: 200)); // 延迟 200 毫秒
          _pumpDrain(); // 递归重试
        } else { // 如果超过最大重试次数
          debugPrint('PushPayloadRouter: gave up (no context or user)'); // 打印放弃日志
          _queued = null; // 清空队列
        }
        return; // 直接返回
      }
      final pending = _queued; // 获取待处理载荷
      _queued = null; // 清空队列
      if (pending != null) { // 如果有待处理载荷
        await _openForPayload(ctx, pending); // 打开对应界面
      }
    });
  }

  static Future<String> _peerDisplayName(String pairId) async { // 获取对方显示名称
    final myUid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (myUid == null) return 'Chat'; // 如果未登录,返回默认值
    final parts = pairId.split('__'); // 分割配对 ID
    if (parts.length != 2) return 'Chat'; // 如果格式不正确,返回默认值
    final other = parts[0] == myUid ? parts[1] : parts[0]; // 获取对方 UID
    try { // 尝试获取名称
      final link = await FirebaseFirestore.instance // Firestore 实例
          .collection('friend_links') // friend_links 集合
          .doc(pairId) // 配对 ID 文档
          .get(); // 获取文档
      final names = link.data()?['names']; // 获取名称映射
      if (names is Map) { // 如果是 Map 类型
        final n = names[other]; // 获取对方名称
        if (n is String && n.trim().isNotEmpty) return n.trim(); // 如果不为空,返回
      }
      final u = await FirebaseFirestore.instance // 如果好友关系中没有名称
          .collection('users') // users 集合
          .doc(other) // 对方用户文档
          .get(); // 获取文档
      final d = u.data(); // 获取数据
      if (d != null) { // 如果数据不为空
        for (final k in ['displayName', 'name', 'userName', 'email']) { // 遍历可能的名称字段
          final v = d[k]; // 获取字段值
          if (v is String && v.trim().isNotEmpty) return v.trim(); // 如果不为空,返回
        }
      }
    } catch (e) { // 捕获异常
      debugPrint('PushPayloadRouter: peer name: $e'); // 打印错误日志
    }
    return 'Chat'; // 返回默认值
  }

  static Future<void> _openForPayload( // 根据载荷打开对应界面
    BuildContext context, // 构建上下文
    Map<String, String> data, // 载荷数据
  ) async { // 异步方法
    final type = data['type']; // 获取类型
    if (type == null) return; // 如果类型为空,直接返回

    switch (type) { // 根据类型切换
      case 'chat_message': // 聊天消息
      case 'incoming_call': // 来电
        final pairId = data['pair_id']; // 获取配对 ID
        if (pairId == null) return; // 如果为空,直接返回
        final name = await _peerDisplayName(pairId); // 获取对方名称
        if (!context.mounted) return; // 如果上下文已卸载,直接返回
        await Navigator.of(context).push<void>( // push 导航
          MaterialPageRoute<void>( // Material 路由
            builder: (_) => DirectChatScreen( // 私聊界面
              pairId: pairId, // 配对 ID
              peerName: name, // 对方名称
            ),
          ),
        );
        break; // 跳出
      case 'friend_request': // 好友申请
        if (!context.mounted) return; // 如果上下文已卸载,直接返回
        final lang = Provider.of<AppLanguageProvider>(context, listen: false); // 获取多语言提供者
        await Navigator.of(context).push<void>( // push 导航
          MaterialPageRoute<void>( // Material 路由
            builder: (ctx2) => Scaffold( // Scaffold 脚手架
              appBar: AppBar( // 应用栏
                title: Text(lang.tr('contacts')), // 标题:联系人
              ),
              body: const ContactsMessagesScreen(), // 主体:联系人消息界面
            ),
          ),
        );
        break; // 跳出
      case 'calendar_invite': // 日历邀请
        if (!context.mounted) return; // 如果上下文已卸载,直接返回
        await SharedCalendarSheet.show(context); // 显示共享日历弹窗
        break; // 跳出
      default: // 其他情况
        debugPrint('PushPayloadRouter: unknown type=$type'); // 打印未知类型日志
    }
  }
}
