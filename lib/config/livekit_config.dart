import 'package:flutter_dotenv/flutter_dotenv.dart'; // 导入环境变量管理包

/// LiveKit 连接配置（从 [仪表板](https://cloud.livekit.io) 获取值）
///
/// 优先级: 根目录的 `.env`（flutter_dotenv）→ `--dart-define=LIVEKIT_*`
class LiveKitConfig { // LiveKit 配置类
  LiveKitConfig._(); // 私有构造函数,防止实例化

  static String _fromDotEnv(String key) { // 从 dotenv 获取配置值的私有方法
    if (!dotenv.isInitialized) return ''; // 如果 dotenv 未初始化,返回空字符串
    return dotenv.maybeGet(key)?.trim() ?? ''; // 获取配置值并去除空格,如果为空则返回空字符串
  }

  static String get url { // 获取 LiveKit URL 的 getter
    final v = _fromDotEnv('LIVEKIT_URL'); // 从 dotenv 获取 URL
    if (v.isNotEmpty) return v; // 如果不为空,返回该值
    return const String.fromEnvironment('LIVEKIT_URL', defaultValue: ''); // 否则从编译时环境变量获取
  }

  static String get apiKey { // 获取 LiveKit API Key 的 getter
    final v = _fromDotEnv('LIVEKIT_API_KEY'); // 从 dotenv 获取 API Key
    if (v.isNotEmpty) return v; // 如果不为空,返回该值
    return const String.fromEnvironment('LIVEKIT_API_KEY', defaultValue: ''); // 否则从编译时环境变量获取
  }

  static String get apiSecret { // 获取 LiveKit API Secret 的 getter
    final v = _fromDotEnv('LIVEKIT_API_SECRET'); // 从 dotenv 获取 API Secret
    if (v.isNotEmpty) return v; // 如果不为空,返回该值
    return const String.fromEnvironment('LIVEKIT_API_SECRET', defaultValue: ''); // 否则从编译时环境变量获取
  }

  static bool get isConfigured => // 检查是否已配置的 getter
      url.isNotEmpty && apiKey.isNotEmpty && apiSecret.isNotEmpty; // 当 URL、API Key 和 API Secret 都不为空时返回 true
}
