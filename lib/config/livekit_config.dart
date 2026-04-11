import 'package:flutter_dotenv/flutter_dotenv.dart';

/// LiveKit 接続用（[ダッシュボード](https://cloud.livekit.io) の値）
///
/// 優先順: ルートの `.env`（flutter_dotenv）→ `--dart-define=LIVEKIT_*`
class LiveKitConfig {
  LiveKitConfig._();

  static String _fromDotEnv(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.maybeGet(key)?.trim() ?? '';
  }

  static String get url {
    final v = _fromDotEnv('LIVEKIT_URL');
    if (v.isNotEmpty) return v;
    return const String.fromEnvironment('LIVEKIT_URL', defaultValue: '');
  }

  static String get apiKey {
    final v = _fromDotEnv('LIVEKIT_API_KEY');
    if (v.isNotEmpty) return v;
    return const String.fromEnvironment('LIVEKIT_API_KEY', defaultValue: '');
  }

  static String get apiSecret {
    final v = _fromDotEnv('LIVEKIT_API_SECRET');
    if (v.isNotEmpty) return v;
    return const String.fromEnvironment('LIVEKIT_API_SECRET', defaultValue: '');
  }

  static bool get isConfigured =>
      url.isNotEmpty && apiKey.isNotEmpty && apiSecret.isNotEmpty;
}
