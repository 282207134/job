import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:firebase_core/firebase_core.dart'; // 导入 Firebase 核心库
import 'package:firebase_storage/firebase_storage.dart'; // 导入 Firebase 存储库
import 'package:flutter/foundation.dart'; // 导入 Flutter 基础工具库
import 'package:image_picker/image_picker.dart'; // 导入图片选择器库

import '../firebase_options.dart'; // 导入 Firebase 配置选项

/// Storage 路径与 [storage.rules] 保持一致:
/// `directChats/{pairId}/{发送者UID}/images/...`
class ChatMediaService { // 聊天媒体服务类
  ChatMediaService._(); // 私有构造函数,防止实例化

  /// `firebase_options.dart` 中的 bucket 必须一致(未设置会写入其他 bucket 导致权限错误)
  static final String _bucketGsUri = () { // 获取 Storage Bucket URI
    final b = DefaultFirebaseOptions.currentPlatform.storageBucket ?? ''; // 从配置获取
    if (b.isEmpty) { // 如果为空
      throw StateError('firebase_options に storageBucket がありません'); // 抛出错误
    }
    return b.startsWith('gs://') ? b : 'gs://$b'; // 确保以 gs:// 开头
  }();

  static final FirebaseStorage _storage = FirebaseStorage.instanceFor( // 创建 Firebase Storage 实例
    app: Firebase.app(), // Firebase 应用
    bucket: _bucketGsUri, // Storage Bucket
  );

  static Reference _imageRef(String pairId, String fileName) { // 创建图片引用
    final uid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (uid == null) { // 如果未登录
      throw StateError('ログインが必要です'); // 抛出错误
    }
    return _storage
        .ref() // 根引用
        .child('directChats') // directChats 目录
        .child(pairId) // 配对 ID
        .child(uid) // 用户 ID
        .child('images') // images 子目录
        .child(fileName); // 文件名
  }

  /// Firebase Storage 的异常转为用户友好的日语消息
  static String messageForStorageError(Object e) { // 处理存储错误消息
    if (e is FirebaseException) { // 如果是 Firebase 异常
      final c = e.code; // 获取错误代码
      if (c == 'unauthorized' || // 未授权错误
          c.contains('unauthorized') ||
          c == 'storage/unauthorized') {
        return 'Storage の権限がありません。確認: (1) Firebase プロジェクト ' // 权限错误提示
            '${DefaultFirebaseOptions.currentPlatform.projectId} の Console→Storage でバケットが '
            '$_bucketGsUri と一致 (2) Storage→ルールに storage.rules を貼り「公開」'
            '(3) App Check で Storage を強制している場合は無効化またはアプリを登録';
      }
      if (c == 'object-not-found' || c.contains('object-not-found')) { // 对象未找到
        return 'ファイルが見つかりません: ${e.message ?? c}'; // 文件未找到
      }
      if (c == 'quota-exceeded' || c.contains('quota')) { // 配额超限
        return 'ストレージ容量の上限に達しています。'; // 容量已满
      }
      return '${e.message ?? e.code} (${e.code})'; // 其他错误
    }
    return e.toString(); // 非 Firebase 异常
  }

  /// 删除自己上传的文件 `directChats/{pairId}/{自己UID}/...`
  static Future<void> tryDeleteMyChatFilesForPair(String pairId) async { // 尝试删除聊天文件
    final me = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (me == null) return; // 如果未登录,直接返回
    try { // 尝试删除
      final base =
          _storage.ref().child('directChats').child(pairId).child(me); // 基础路径
      await _deleteStorageRefRecursive(base); // 递归删除
    } catch (e, st) { // 捕获异常
      debugPrint('tryDeleteMyChatFilesForPair $pairId: $e\n$st'); // 打印错误
    }
  }

  static Future<void> _deleteStorageRefRecursive(Reference ref) async { // 递归删除存储引用
    final list = await ref.listAll(); // 列出所有项
    for (final item in list.items) { // 遍历文件
      try { // 尝试删除
        await item.delete(); // 删除文件
      } catch (_) {} // 忽略错误
    }
    for (final prefix in list.prefixes) { // 遍历子目录
      await _deleteStorageRefRecursive(prefix); // 递归删除
    }
  }

  static Future<String> uploadChatImage({ // 上传聊天图片
    required String pairId, // 配对 ID
    required XFile xFile, // 图片文件
  }) async { // 异步方法
    try { // 尝试上传
      final bytes = await xFile.readAsBytes(); // 读取文件字节
      final mime = xFile.mimeType ?? 'image/jpeg'; // 获取 MIME 类型
      final ext = mime == 'image/png' ? 'png' : 'jpg'; // 确定扩展名
      final name = '${DateTime.now().millisecondsSinceEpoch}.$ext'; // 生成文件名
      final ref = _imageRef(pairId, name); // 创建引用
      await ref.putData( // 上传数据
        bytes, // 文件字节
        SettableMetadata(contentType: mime), // 元数据
      );
      return await ref.getDownloadURL(); // 返回下载 URL
    } on FirebaseException catch (e) { // 捕获 Firebase 异常
      throw Exception(messageForStorageError(e)); // 抛出友好错误消息
    }
  }
}
