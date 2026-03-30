import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_options.dart';

class ProfileMediaService {
  ProfileMediaService._();

  static final String _bucketGsUri = () {
    final b = DefaultFirebaseOptions.currentPlatform.storageBucket ?? '';
    if (b.isEmpty) {
      throw StateError('firebase_options 缺少 storageBucket');
    }
    return b.startsWith('gs://') ? b : 'gs://$b';
  }();

  static final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    app: Firebase.app(),
    bucket: _bucketGsUri,
  );

  static Future<String> uploadAvatar(XFile xFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('未登录');
    final bytes = await xFile.readAsBytes();
    final mime = xFile.mimeType ?? 'image/jpeg';
    final ext = mime == 'image/png' ? 'png' : 'jpg';
    final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref().child('users').child(uid).child('avatars').child(name);
    await ref.putData(bytes, SettableMetadata(contentType: mime));
    return ref.getDownloadURL();
  }
}
