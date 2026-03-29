import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_options.dart';

/// Storage パスは [storage.rules] と一致させる:
/// `directChats/{pairId}/{送信者UID}/images/...`
class ChatMediaService {
  ChatMediaService._();

  /// `firebase_options.dart` の bucket と必ず一致させる（未設定だと別バケットに書こうとして権限エラーになりやすい）
  static final String _bucketGsUri = () {
    final b = DefaultFirebaseOptions.currentPlatform.storageBucket ?? '';
    if (b.isEmpty) {
      throw StateError('firebase_options に storageBucket がありません');
    }
    return b.startsWith('gs://') ? b : 'gs://$b';
  }();

  static final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    app: Firebase.app(),
    bucket: _bucketGsUri,
  );

  static Reference _imageRef(String pairId, String fileName) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('ログインが必要です');
    }
    return _storage
        .ref()
        .child('directChats')
        .child(pairId)
        .child(uid)
        .child('images')
        .child(fileName);
  }

  /// Firebase Storage の例外をユーザー向け日本語に寄せる
  static String messageForStorageError(Object e) {
    if (e is FirebaseException) {
      final c = e.code;
      if (c == 'unauthorized' ||
          c.contains('unauthorized') ||
          c == 'storage/unauthorized') {
        return 'Storage の権限がありません。確認: (1) Firebase プロジェクト '
            '${DefaultFirebaseOptions.currentPlatform.projectId} の Console→Storage でバケットが '
            '$_bucketGsUri と一致 (2) Storage→ルールに storage.rules を貼り「公開」'
            '(3) App Check で Storage を強制している場合は無効化またはアプリを登録';
      }
      if (c == 'object-not-found' || c.contains('object-not-found')) {
        return 'ファイルが見つかりません: ${e.message ?? c}';
      }
      if (c == 'quota-exceeded' || c.contains('quota')) {
        return 'ストレージ容量の上限に達しています。';
      }
      return '${e.message ?? e.code} (${e.code})';
    }
    return e.toString();
  }

  /// 選択した画像をアップロードし、ダウンロード URL を返す。
  static Future<String> uploadChatImage({
    required String pairId,
    required XFile xFile,
  }) async {
    try {
      final bytes = await xFile.readAsBytes();
      final mime = xFile.mimeType ?? 'image/jpeg';
      final ext = mime == 'image/png' ? 'png' : 'jpg';
      final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = _imageRef(pairId, name);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: mime),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(messageForStorageError(e));
    }
  }
}
