import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 设计包
import 'dart:io'; // 导入 Dart 的 IO 库，用于文件操作
import 'package:image_picker/image_picker.dart'; // 导入 Image Picker 包，用于选择图片
import 'package:shared_preferences/shared_preferences.dart'; // 导入 Shared Preferences 包，用于持久化存储

class testPage extends StatefulWidget { // 定义一个状态组件 testPage
  const testPage({Key? key}) : super(key: key); // 构造函数

  @override
  _testPageState createState() => _testPageState(); // 创建状态对象
}

class _testPageState extends State<testPage> {
  late File _selectedImage; // 定义一个文件类型的变量，用于存储选中的图片
  late SharedPreferences _prefs; // 定义一个 SharedPreferences 类型的变量

  @override
  void initState() {
    super.initState(); // 调用父类的 initState
    _loadPrefs(); // 调用 _loadPrefs 方法来初始化 _selectedImage 变量
  }

  Future<File> _loadPrefs() async { // 异步方法，加载共享偏好

    _prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    final imagePath = _prefs.getString('imagePath'); // 获取存储的图片路径
    imagePath== AssetImage('images/panda.png');
    if (imagePath != null) {
      return File(imagePath); // 如果路径存在，返回对应的文件
    } else {
      return File('images/panda.png'); // 否则返回默认头像
    }
  }

  Future<void> _saveImagePath(String imagePath) async { // 保存图片路径的方法
    await _prefs.setString('imagePath', imagePath); // 将路径保存到 SharedPreferences
  }

  Future<void> _pickImage(ImageSource source) async { // 选择图片的方法
    final picker = ImagePicker(); // 创建 ImagePicker 实例
    final pickedImage = await picker.pickImage(source: source); // 从指定来源选择图片
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path); // 更新选中的图片
      });
      _saveImagePath(pickedImage.path); // 保存图片路径
    }
  }

  void _updateSelectedImage(File image) { // 更新选中图片的方法
    setState(() {
      _selectedImage = image; // 更新 _selectedImage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16), // 设置内边距
            color: Colors.grey[200], // 设置背景颜色
            child: Row(
              children: [
                FutureBuilder(
                  future: _loadPrefs(),
                  builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('选择头像'), // 对话框标题
                                actions: [
                                  TextButton(
                                    child: Text('从相册选择'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (pickedImage != null) {
                                        _updateSelectedImage(File(pickedImage.path));
                                        _saveImagePath(pickedImage.path);
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: Text('拍照'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                                      if (pickedImage != null) {
                                        _updateSelectedImage(File(pickedImage.path));
                                        _saveImagePath(pickedImage.path);
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 40, // 设置半径
                          backgroundImage: snapshot.data != null
                              ? FileImage(snapshot.data!) as ImageProvider<Object>
                              : AssetImage('images/panda.png'), // 默认显示 `images/panda.png`
                        ),
                      );
                    } else {
                      return CircularProgressIndicator(); // 显示加载指示器
                    }
                  },
                ),


              ],
            ),
          ),

        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon; // 图标
  final String title; // 标题

  const SettingItem({required this.icon, required this.title}); // 构造函数

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon), // 图标显示在前面
      title: Text(title), // 显示标题
      trailing: Icon(Icons.arrow_forward_ios), // 右侧图标
      onTap: () => {}, // 点击事件
    );
  }
}
