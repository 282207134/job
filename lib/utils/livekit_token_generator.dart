import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:kantankanri/config/livekit_config.dart';

/// クライアント側 JWT 生成（本番ではサーバー発行トークンに差し替え推奨）
class LivekitTokenGenerator {
  LivekitTokenGenerator._();

  static String generateToken({
    required String roomName,
    required String participantIdentity,
    String? participantName,
    int ttl = 21600,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = now + ttl;

    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final payload = {
      'iss': LiveKitConfig.apiKey,
      'exp': exp,
      'nbf': now - 1,
      'sub': participantIdentity,
      if (participantName != null) 'name': participantName,
      'video': {
        'room': roomName,
        'roomJoin': true,
      },
    };

    final encodedHeader = _base64UrlEncode(jsonEncode(header));
    final encodedPayload = _base64UrlEncode(jsonEncode(payload));

    final signature = _createSignature(
      '$encodedHeader.$encodedPayload',
      LiveKitConfig.apiSecret,
    );

    return '$encodedHeader.$encodedPayload.$signature';
  }

  static String _base64UrlEncode(String input) {
    final bytes = utf8.encode(input);
    final base64 = base64Encode(bytes);
    return base64
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  static String _createSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final message = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(message);
    final base64 = base64Encode(digest.bytes);
    return base64
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }
}
