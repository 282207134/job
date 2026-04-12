import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth のコードをユーザー向け文言キーへ（`AppLanguageProvider.tr` に渡す）
class FirebaseAuthMessages {
  FirebaseAuthMessages._();

  static String loginErrorKey(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'auth_invalid_email';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-disabled':
      case 'user-mismatch':
        return 'auth_wrong_credentials';
      case 'too-many-requests':
        return 'auth_too_many_requests';
      case 'network-request-failed':
        return 'auth_network_error';
      default:
        return 'auth_login_failed';
    }
  }

  static String signupErrorKey(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'auth_invalid_email';
      case 'email-already-in-use':
        return 'auth_email_in_use';
      case 'weak-password':
        return 'auth_weak_password';
      case 'operation-not-allowed':
        return 'auth_operation_not_allowed';
      case 'too-many-requests':
        return 'auth_too_many_requests';
      case 'network-request-failed':
        return 'auth_network_error';
      default:
        return 'auth_signup_failed';
    }
  }
}
