import 'dart:async'; // 导入异步编程库

import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库
import 'package:shared_preferences/shared_preferences.dart'; // 导入本地存储包

class AppLockProvider extends ChangeNotifier { // 应用锁状态管理器类
  AppLockProvider() { // 构造函数
    _load(); // 加载保存的状态
  }

  static const _enabledKey = 'app_lock_enabled'; // 启用状态的键名
  static const _passwordKey = 'app_lock_password'; // 密码的键名
  static const _idleMinutesKey = 'app_lock_idle_minutes'; // 空闲时间的键名

  bool _ready = false; // 是否已就绪
  bool _enabled = false; // 是否启用应用锁
  bool _unlocked = false; // 是否已解锁
  String _password = ''; // 锁密码
  String? _activeUid; // 当前活跃用户 ID
  int _idleMinutes = 0; // 自动锁定空闲分钟数
  Timer? _idleTimer; // 空闲计时器

  bool get ready => _ready; // 获取是否已就绪
  bool get enabled => _enabled; // 获取是否启用
  bool get unlocked => _unlocked; // 获取是否已解锁
  bool get hasPassword => _password.isNotEmpty; // 获取是否设置了密码
  int get idleMinutes => _idleMinutes; // 获取空闲分钟数
  bool get shouldRequireUnlock => _enabled && _password.isNotEmpty && !_unlocked; // 获取是否需要解锁

  Future<void> _load() async { // 私有方法:加载保存的状态
    await syncWithUser(null); // 同步用户状态(初始为空)
  }

  String _k(String base) { // 私有方法:生成带用户 ID 的键名
    final uid = _activeUid; // 获取当前活跃用户 ID
    if (uid == null || uid.isEmpty) return base; // 如果用户 ID 为空,返回基础键名
    return '${base}_$uid'; // 否则返回带用户 ID 后缀的键名
  }

  Future<void> syncWithUser(String? uid) async { // 同步用户状态(会通知监听器)
    if (_activeUid == uid && _ready) return; // 如果用户 ID 相同且已就绪,直接返回
    _idleTimer?.cancel(); // 取消空闲计时器
    _ready = false; // 设置为未就绪
    _activeUid = uid; // 更新活跃用户 ID
    if (uid == null || uid.isEmpty) { // 如果用户 ID 为空
      _enabled = false; // 禁用应用锁
      _password = ''; // 清空密码
      _idleMinutes = 0; // 重置空闲时间
      _unlocked = false; // 设置为未解锁
      _ready = true; // 设置为已就绪
      notifyListeners(); // 通知监听器
      return; // 返回
    }

    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    final userEnabledKey = _k(_enabledKey); // 生成用户特定的启用状态键名
    final userPasswordKey = _k(_passwordKey); // 生成用户特定的密码键名
    final userIdleKey = _k(_idleMinutesKey); // 生成用户特定的空闲时间键名
    final hasUserScoped = prefs.containsKey(userEnabledKey) || // 检查是否有用户特定的配置
        prefs.containsKey(userPasswordKey) ||
        prefs.containsKey(userIdleKey);

    if (hasUserScoped) { // 如果有用户特定的配置
      _enabled = prefs.getBool(userEnabledKey) ?? false; // 获取启用状态
      _password = prefs.getString(userPasswordKey) ?? ''; // 获取密码
      _idleMinutes = prefs.getInt(userIdleKey) ?? 0; // 获取空闲时间
    } else { // 否则(向后兼容:迁移旧的全局应用锁状态到当前用户)
      _enabled = prefs.getBool(_enabledKey) ?? false; // 从全局键获取启用状态
      _password = prefs.getString(_passwordKey) ?? ''; // 从全局键获取密码
      _idleMinutes = prefs.getInt(_idleMinutesKey) ?? 0; // 从全局键获取空闲时间
      if (_password.isNotEmpty || _enabled || _idleMinutes > 0) { // 如果有旧数据
        await prefs.setBool(userEnabledKey, _enabled); // 迁移启用状态到用户特定键
        if (_password.isNotEmpty) { // 如果密码不为空
          await prefs.setString(userPasswordKey, _password); // 迁移密码到用户特定键
        }
        await prefs.setInt(userIdleKey, _idleMinutes); // 迁移空闲时间到用户特定键
      }
    }
    _unlocked = false; // 新登录/会话在启用时总是需要解锁
    if (_password.isEmpty) { // 如果密码为空
      _enabled = false; // 禁用应用锁
    }
    _ready = true; // 设置为已就绪
    _armIdleTimerIfNeeded(); // 如果需要则启动空闲计时器
    notifyListeners(); // 通知监听器
  }

  /// 确保 Provider 与给定的用户 ID 同步
  /// 此方法避免在构建阶段通知监听器
  Future<void> ensureSynced(String? uid) async { // 确保同步(不通知监听器)
    if (_activeUid == uid && _ready) return; // 如果用户 ID 相同且已就绪,直接返回
    _idleTimer?.cancel(); // 取消空闲计时器
    _ready = false; // 设置为未就绪
    _activeUid = uid; // 更新活跃用户 ID
    if (uid == null || uid.isEmpty) { // 如果用户 ID 为空
      _enabled = false; // 禁用应用锁
      _password = ''; // 清空密码
      _idleMinutes = 0; // 重置空闲时间
      _unlocked = false; // 设置为未解锁
      _ready = true; // 设置为已就绪
      return; // 返回(不通知监听器)
    }

    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    final userEnabledKey = _k(_enabledKey); // 生成用户特定的启用状态键名
    final userPasswordKey = _k(_passwordKey); // 生成用户特定的密码键名
    final userIdleKey = _k(_idleMinutesKey); // 生成用户特定的空闲时间键名
    final hasUserScoped = prefs.containsKey(userEnabledKey) || // 检查是否有用户特定的配置
        prefs.containsKey(userPasswordKey) ||
        prefs.containsKey(userIdleKey);

    if (hasUserScoped) { // 如果有用户特定的配置
      _enabled = prefs.getBool(userEnabledKey) ?? false; // 获取启用状态
      _password = prefs.getString(userPasswordKey) ?? ''; // 获取密码
      _idleMinutes = prefs.getInt(userIdleKey) ?? 0; // 获取空闲时间
    } else { // 否则(向后兼容:迁移旧的全局应用锁状态到当前用户)
      _enabled = prefs.getBool(_enabledKey) ?? false; // 从全局键获取启用状态
      _password = prefs.getString(_passwordKey) ?? ''; // 从全局键获取密码
      _idleMinutes = prefs.getInt(_idleMinutesKey) ?? 0; // 从全局键获取空闲时间
      if (_password.isNotEmpty || _enabled || _idleMinutes > 0) { // 如果有旧数据
        await prefs.setBool(userEnabledKey, _enabled); // 迁移启用状态到用户特定键
        if (_password.isNotEmpty) { // 如果密码不为空
          await prefs.setString(userPasswordKey, _password); // 迁移密码到用户特定键
        }
        await prefs.setInt(userIdleKey, _idleMinutes); // 迁移空闲时间到用户特定键
      }
    }
    _unlocked = false; // 设置为未解锁
    if (_password.isEmpty) { // 如果密码为空
      _enabled = false; // 禁用应用锁
    }
    _ready = true; // 设置为已就绪
    _armIdleTimerIfNeeded(); // 如果需要则启动空闲计时器
  }

  Future<void> enableWithPassword(String password) async { // 使用密码启用应用锁
    final next = password.trim(); // 去除密码前后空格
    if (next.isEmpty) { // 如果密码为空
      throw Exception('empty_password'); // 抛出异常
    }
    _password = next; // 设置密码
    _enabled = true; // 启用应用锁
    _unlocked = true; // 设置为已解锁
    _armIdleTimerIfNeeded(); // 启动空闲计时器
    notifyListeners(); // 通知监听器
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setString(_k(_passwordKey), _password); // 保存密码
    await prefs.setBool(_k(_enabledKey), true); // 保存启用状态
  }

  Future<void> enable() async { // 启用应用锁(需要已设置密码)
    if (_password.isEmpty) { // 如果密码为空
      throw Exception('empty_password'); // 抛出异常
    }
    _enabled = true; // 启用应用锁
    _unlocked = true; // 设置为已解锁
    _armIdleTimerIfNeeded(); // 启动空闲计时器
    notifyListeners(); // 通知监听器
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setBool(_k(_enabledKey), true); // 保存启用状态
  }

  Future<void> disable() async { // 禁用应用锁
    _enabled = false; // 禁用应用锁
    _unlocked = true; // 设置为已解锁
    _idleTimer?.cancel(); // 取消空闲计时器
    notifyListeners(); // 通知监听器
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setBool(_k(_enabledKey), false); // 保存禁用状态
  }

  Future<void> updatePassword(String password) async { // 更新密码
    final next = password.trim(); // 去除密码前后空格
    if (next.isEmpty) { // 如果密码为空
      throw Exception('empty_password'); // 抛出异常
    }
    _password = next; // 更新密码
    notifyListeners(); // 通知监听器
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setString(_k(_passwordKey), _password); // 保存新密码
  }

  Future<void> setIdleMinutes(int minutes) async { // 设置自动锁定空闲分钟数
    _idleMinutes = minutes < 0 ? 0 : minutes; // 如果为负数则设为 0
    _armIdleTimerIfNeeded(); // 启动空闲计时器
    notifyListeners(); // 通知监听器
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setInt(_k(_idleMinutesKey), _idleMinutes); // 保存空闲时间
  }

  Future<bool> unlock(String input) async { // 解锁
    if (input.trim() != _password) return false; // 如果输入密码不匹配,返回 false
    _unlocked = true; // 设置为已解锁
    _armIdleTimerIfNeeded(); // 启动空闲计时器
    notifyListeners(); // 通知监听器
    return true; // 返回成功
  }

  void lockSession() { // 锁定会话
    if (!_enabled) return; // 如果未启用,直接返回
    _unlocked = false; // 设置为未解锁
    _idleTimer?.cancel(); // 取消空闲计时器
    notifyListeners(); // 通知监听器
  }

  void recordActivity() { // 记录活动(重置空闲计时器)
    _armIdleTimerIfNeeded(); // 启动空闲计时器
  }

  void _armIdleTimerIfNeeded() { // 私有方法:如果需要则启动空闲计时器
    _idleTimer?.cancel(); // 取消现有计时器
    if (!_enabled || !_unlocked || _idleMinutes <= 0) return; // 如果未启用、已解锁或空闲时间为 0,直接返回
    _idleTimer = Timer(Duration(minutes: _idleMinutes), () { // 创建新的计时器
      if (!_enabled) return; // 如果未启用,直接返回
      _unlocked = false; // 设置为未解锁
      notifyListeners(); // 通知监听器
    });
  }

  @override // 重写 dispose 方法
  void dispose() { // 组件销毁时调用
    _idleTimer?.cancel(); // 取消空闲计时器
    super.dispose(); // 调用父类的 dispose
  }
}

