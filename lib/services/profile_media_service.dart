import 'package:firebase_auth/firebase_auth.dart'; // 导入 Firebase 认证库
import 'package:firebase_core/firebase_core.dart'; // 导入 Firebase 核心库
import 'package:firebase_storage/firebase_storage.dart'; // 导入 Firebase 存储库
import 'package:image_picker/image_picker.dart'; // 导入图片选择器库

import '../firebase_options.dart'; // 导入 Firebase 配置选项

class ProfileMediaService { // 个人资料媒体服务类
  ProfileMediaService._(); // 私有构造函数,防止实例化

  static final String _bucketGsUri = () { // 获取 Storage Bucket URI
    final b = DefaultFirebaseOptions.currentPlatform.storageBucket ?? ''; // 从配置获取 bucket
    if (b.isEmpty) { // 如果为空
      throw StateError('firebase_options 缺少 storageBucket'); // 抛出错误
    }
    return b.startsWith('gs://') ? b : 'gs://$b'; // 确保以 gs:// 开头
  }();

  static final FirebaseStorage _storage = FirebaseStorage.instanceFor( // 创建 Firebase Storage 实例
    app: Firebase.app(), // Firebase 应用
    bucket: _bucketGsUri, // Storage Bucket
  );

  static Future<String> uploadAvatar(XFile xFile) async { // 上传头像方法
    final uid = FirebaseAuth.instance.currentUser?.uid; // 获取当前用户 ID
    if (uid == null) throw Exception('未登录'); // 如果未登录,抛出异常
    final bytes = await xFile.readAsBytes(); // 读取文件字节
    final mime = xFile.mimeType ?? 'image/jpeg'; // 获取 MIME 类型,默认 JPEG
    final ext = mime == 'image/png' ? 'png' : 'jpg'; // 根据 MIME 类型确定扩展名
    final name = '${DateTime.now().millisecondsSinceEpoch}.$ext'; // 生成文件名(时间戳)
    final ref = _storage.ref().child('users').child(uid).child('avatars').child(name); // 创建存储引用
    await ref.putData(bytes, SettableMetadata(contentType: mime)); // 上传数据
    return ref.getDownloadURL(); // 返回下载 URL
  }
}
