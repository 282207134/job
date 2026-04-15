import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库

/// Firebase Auth 的代码转为用户友好的文本密钥(传递给 `AppLanguageProvider.tr`)
class FirebaseAuthMessages { // Firebase 认证消息类
  FirebaseAuthMessages._(); // 私有构造函数,防止实例化

  static String loginErrorKey(FirebaseAuthException e) { // 获取登录错误密钥
    switch (e.code) { // 根据错误代码切换
      case 'invalid-email': // 邮箱格式无效
        return 'auth_invalid_email'; // 返回对应的密钥
      case 'wrong-password': // 密码错误
      case 'user-not-found': // 用户不存在
      case 'invalid-credential': // 凭证无效
      case 'invalid-login-credentials': // 登录凭证无效
      case 'user-disabled': // 用户被禁用
      case 'user-mismatch': // 用户不匹配
        return 'auth_wrong_credentials'; // 返回凭证错误密钥
      case 'too-many-requests': // 请求过多
        return 'auth_too_many_requests'; // 返回请求限制密钥
      case 'network-request-failed': // 网络请求失败
        return 'auth_network_error'; // 返回网络错误密钥
      default: // 其他情况
        return 'auth_login_failed'; // 返回登录失败密钥
    }
  }

  static String signupErrorKey(FirebaseAuthException e) { // 获取注册错误密钥
    switch (e.code) { // 根据错误代码切换
      case 'invalid-email': // 邮箱格式无效
        return 'auth_invalid_email'; // 返回对应的密钥
      case 'email-already-in-use': // 邮箱已被使用
        return 'auth_email_in_use'; // 返回邮箱已占用密钥
      case 'weak-password': // 密码太弱
        return 'auth_weak_password'; // 返回弱密码密钥
      case 'operation-not-allowed': // 操作不允许
        return 'auth_operation_not_allowed'; // 返回操作禁止密钥
      case 'too-many-requests': // 请求过多
        return 'auth_too_many_requests'; // 返回请求限制密钥
      case 'network-request-failed': // 网络请求失败
        return 'auth_network_error'; // 返回网络错误密钥
      default: // 其他情况
        return 'auth_signup_failed'; // 返回注册失败密钥
    }
  }
}
