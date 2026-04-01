import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockProvider extends ChangeNotifier {
  AppLockProvider() {
    _load();
  }

  static const _enabledKey = 'app_lock_enabled';
  static const _passwordKey = 'app_lock_password';
  static const _idleMinutesKey = 'app_lock_idle_minutes';

  bool _ready = false;
  bool _enabled = false;
  bool _unlocked = false;
  String _password = '';
  String? _activeUid;
  int _idleMinutes = 0;
  Timer? _idleTimer;

  bool get ready => _ready;
  bool get enabled => _enabled;
  bool get unlocked => _unlocked;
  bool get hasPassword => _password.isNotEmpty;
  int get idleMinutes => _idleMinutes;
  bool get shouldRequireUnlock => _enabled && _password.isNotEmpty && !_unlocked;

  Future<void> _load() async {
    await syncWithUser(null);
  }

  String _k(String base) {
    final uid = _activeUid;
    if (uid == null || uid.isEmpty) return base;
    return '${base}_$uid';
  }

  Future<void> syncWithUser(String? uid) async {
    if (_activeUid == uid && _ready) return;
    _idleTimer?.cancel();
    _ready = false;
    _activeUid = uid;
    if (uid == null || uid.isEmpty) {
      _enabled = false;
      _password = '';
      _idleMinutes = 0;
      _unlocked = false;
      _ready = true;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userEnabledKey = _k(_enabledKey);
    final userPasswordKey = _k(_passwordKey);
    final userIdleKey = _k(_idleMinutesKey);
    final hasUserScoped = prefs.containsKey(userEnabledKey) ||
        prefs.containsKey(userPasswordKey) ||
        prefs.containsKey(userIdleKey);

    if (hasUserScoped) {
      _enabled = prefs.getBool(userEnabledKey) ?? false;
      _password = prefs.getString(userPasswordKey) ?? '';
      _idleMinutes = prefs.getInt(userIdleKey) ?? 0;
    } else {
      // Backward compatibility: migrate old global app-lock state to current user.
      _enabled = prefs.getBool(_enabledKey) ?? false;
      _password = prefs.getString(_passwordKey) ?? '';
      _idleMinutes = prefs.getInt(_idleMinutesKey) ?? 0;
      if (_password.isNotEmpty || _enabled || _idleMinutes > 0) {
        await prefs.setBool(userEnabledKey, _enabled);
        if (_password.isNotEmpty) {
          await prefs.setString(userPasswordKey, _password);
        }
        await prefs.setInt(userIdleKey, _idleMinutes);
      }
    }
    _unlocked = false; // new login/session always requires unlock when enabled
    if (_password.isEmpty) {
      _enabled = false;
    }
    _ready = true;
    _armIdleTimerIfNeeded();
    notifyListeners();
  }

  /// Ensures the provider is synced with the given user ID.
  /// This method avoids notifying listeners during build phase.
  Future<void> ensureSynced(String? uid) async {
    if (_activeUid == uid && _ready) return;
    _idleTimer?.cancel();
    _ready = false;
    _activeUid = uid;
    if (uid == null || uid.isEmpty) {
      _enabled = false;
      _password = '';
      _idleMinutes = 0;
      _unlocked = false;
      _ready = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userEnabledKey = _k(_enabledKey);
    final userPasswordKey = _k(_passwordKey);
    final userIdleKey = _k(_idleMinutesKey);
    final hasUserScoped = prefs.containsKey(userEnabledKey) ||
        prefs.containsKey(userPasswordKey) ||
        prefs.containsKey(userIdleKey);

    if (hasUserScoped) {
      _enabled = prefs.getBool(userEnabledKey) ?? false;
      _password = prefs.getString(userPasswordKey) ?? '';
      _idleMinutes = prefs.getInt(userIdleKey) ?? 0;
    } else {
      // Backward compatibility: migrate old global app-lock state to current user.
      _enabled = prefs.getBool(_enabledKey) ?? false;
      _password = prefs.getString(_passwordKey) ?? '';
      _idleMinutes = prefs.getInt(_idleMinutesKey) ?? 0;
      if (_password.isNotEmpty || _enabled || _idleMinutes > 0) {
        await prefs.setBool(userEnabledKey, _enabled);
        if (_password.isNotEmpty) {
          await prefs.setString(userPasswordKey, _password);
        }
        await prefs.setInt(userIdleKey, _idleMinutes);
      }
    }
    _unlocked = false;
    if (_password.isEmpty) {
      _enabled = false;
    }
    _ready = true;
    _armIdleTimerIfNeeded();
  }

  Future<void> enableWithPassword(String password) async {
    final next = password.trim();
    if (next.isEmpty) {
      throw Exception('empty_password');
    }
    _password = next;
    _enabled = true;
    _unlocked = true;
    _armIdleTimerIfNeeded();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k(_passwordKey), _password);
    await prefs.setBool(_k(_enabledKey), true);
  }

  Future<void> enable() async {
    if (_password.isEmpty) {
      throw Exception('empty_password');
    }
    _enabled = true;
    _unlocked = true;
    _armIdleTimerIfNeeded();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_k(_enabledKey), true);
  }

  Future<void> disable() async {
    _enabled = false;
    _unlocked = true;
    _idleTimer?.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_k(_enabledKey), false);
  }

  Future<void> updatePassword(String password) async {
    final next = password.trim();
    if (next.isEmpty) {
      throw Exception('empty_password');
    }
    _password = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k(_passwordKey), _password);
  }

  Future<void> setIdleMinutes(int minutes) async {
    _idleMinutes = minutes < 0 ? 0 : minutes;
    _armIdleTimerIfNeeded();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_k(_idleMinutesKey), _idleMinutes);
  }

  Future<bool> unlock(String input) async {
    if (input.trim() != _password) return false;
    _unlocked = true;
    _armIdleTimerIfNeeded();
    notifyListeners();
    return true;
  }

  void lockSession() {
    if (!_enabled) return;
    _unlocked = false;
    _idleTimer?.cancel();
    notifyListeners();
  }

  void recordActivity() {
    _armIdleTimerIfNeeded();
  }

  void _armIdleTimerIfNeeded() {
    _idleTimer?.cancel();
    if (!_enabled || !_unlocked || _idleMinutes <= 0) return;
    _idleTimer = Timer(Duration(minutes: _idleMinutes), () {
      if (!_enabled) return;
      _unlocked = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }
}

