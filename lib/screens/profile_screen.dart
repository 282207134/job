//个人情报界面
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:firebase_auth/firebase_auth.dart'; // 引入Firebase认证库
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../services/profile_media_service.dart';
import 'edit_profile_screen.dart'; // 引入状态管理库

// 定义ProfileScreen类，一个有状态的小部件
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // 构造函数

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // 创建状态
}

// 定义_ProfileScreenState类，是ProfileScreen的状态
class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData = {}; // 用于存储用户数据的Map
  bool _uploadingAvatar = false;

  Future<void> _changeAvatar() async {
    if (_uploadingAvatar) return;
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (x == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await ProfileMediaService.uploadAvatar(x);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('未登录');
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatar_url': url,
      });
      if (!mounted) return;
      await Provider.of<UserProvider>(context, listen: false).getUserDetails();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像已更新')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('头像更新失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); // 从Provider获取UserProvider实例

    return Scaffold(
      appBar: AppBar(
        title: const Text("个人信息"), // 设置应用栏标题
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity, // 容器宽度设置为无限
        color: const Color(0xFFF7F7FB),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 72,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: userProvider.userAvatarUrl.isNotEmpty
                        ? NetworkImage(userProvider.userAvatarUrl)
                        : const AssetImage('images/panda.png') as ImageProvider,
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: '更换头像',
                      onPressed: _uploadingAvatar ? null : _changeAvatar,
                      icon: _uploadingAvatar
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt_outlined, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                userProvider.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 6),
              Text(
                userProvider.userEmail,
                style: const TextStyle(fontSize: 22, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // 点击按钮时导航到编辑个人资料页面
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const EditProfileScreen(); // 跳转到编辑个人资料的屏幕
                  }));
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text("修改姓名"),
              ),
            ],
              ),
            ), // 显示用户名称的首字母的圆形头像
          ],
        ),
      ),
    );
  }
}
