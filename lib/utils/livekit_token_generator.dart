import 'dart:convert'; // 导入 JSON 编解码库

import 'package:crypto/crypto.dart'; // 导入加密库

import 'package:kantankanri/config/livekit_config.dart'; // 导入 LiveKit 配置

/// 客户端侧 JWT 生成(生产环境建议替换为服务器发行令牌)
class LivekitTokenGenerator { // LiveKit 令牌生成器类
  LivekitTokenGenerator._(); // 私有构造函数,防止实例化

  static String generateToken({ // 生成令牌方法
    required String roomName, // 必需:房间名称
    required String participantIdentity, // 必需:参与者身份 ID
    String? participantName, // 可选:参与者名称
    int ttl = 21600, // 令牌有效期(秒),默认 6 小时
  }) { // 异步方法
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // 当前时间戳(秒)
    final exp = now + ttl; // 过期时间戳

    final header = { // JWT 头部
      'alg': 'HS256', // 算法: HMAC-SHA256
      'typ': 'JWT', // 类型: JWT
    };

    final payload = { // JWT 载荷
      'iss': LiveKitConfig.apiKey, // 发行者: API Key
      'exp': exp, // 过期时间
      'nbf': now - 1, // 生效时间(提前 1 秒)
      'sub': participantIdentity, // 主题:参与者 ID
      if (participantName != null) 'name': participantName, // 如果提供名称则添加
      'video': { // 视频权限
        'room': roomName, // 房间名称
        'roomJoin': true, // 允许加入房间
      },
    };

    final encodedHeader = _base64UrlEncode(jsonEncode(header)); // Base64URL 编码头部
    final encodedPayload = _base64UrlEncode(jsonEncode(payload)); // Base64URL 编码载荷

    final signature = _createSignature( // 创建签名
      '$encodedHeader.$encodedPayload', // 待签名数据
      LiveKitConfig.apiSecret, // 密钥
    );

    return '$encodedHeader.$encodedPayload.$signature'; // 返回完整的 JWT 令牌
  }

  static String _base64UrlEncode(String input) { // Base64URL 编码方法
    final bytes = utf8.encode(input); // UTF-8 编码
    final base64 = base64Encode(bytes); // Base64 编码
    return base64
        .replaceAll('+', '-') // 替换 + 为 -
        .replaceAll('/', '_') // 替换 / 为 _
        .replaceAll('=', ''); // 移除填充符 =
  }

  static String _createSignature(String data, String secret) { // 创建 HMAC-SHA256 签名
    final key = utf8.encode(secret); // UTF-8 编码密钥
    final message = utf8.encode(data); // UTF-8 编码数据
    final hmac = Hmac(sha256, key); // 创建 HMAC 实例(SHA256)
    final digest = hmac.convert(message); // 计算摘要
    final base64 = base64Encode(digest.bytes); // Base64 编码
    return base64
        .replaceAll('+', '-') // 替换 + 为 -
        .replaceAll('/', '_') // 替换 / 为 _
        .replaceAll('=', ''); // 移除填充符 =
  }
}
