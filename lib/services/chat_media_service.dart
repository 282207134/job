import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
  /// 自分がアップロードした `directChats/{pairId}/{自分UID}/...` のみ削除（Storage ルール上、相手フォルダは削除不可）
  static Future<void> tryDeleteMyChatFilesForPair(String pairId) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return;
    try {
      final base =
          _storage.ref().child('directChats').child(pairId).child(me);
      await _deleteStorageRefRecursive(base);
    } catch (e, st) {
      debugPrint('tryDeleteMyChatFilesForPair $pairId: $e\n$st');
    }
  }

  static Future<void> _deleteStorageRefRecursive(Reference ref) async {
    final list = await ref.listAll();
    for (final item in list.items) {
      try {
        await item.delete();
      } catch (_) {}
    }
    for (final prefix in list.prefixes) {
      await _deleteStorageRefRecursive(prefix);
    }
  }

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
