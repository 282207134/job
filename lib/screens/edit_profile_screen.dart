import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:flutter/src/widgets/framework.dart'; // 引入Flutter框架基础库
import 'package:flutter/src/widgets/placeholder.dart'; // 引入占位符库
import 'package:provider/provider.dart'; // 引入状态管理库
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/userProvider.dart'; // 引入Cloud Firestore库

// 定义EditProfileScreen类，一个有状态的小部件
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key}); // 构造函数

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState(); // 创建状态
}

// 定义_EditProfileScreenState类，是EditProfileScreen的状态
class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? userData = {}; // 存储用户数据的变量

  var db = FirebaseFirestore.instance; // 获取Firestore实例

  TextEditingController nameText = TextEditingController(); // 创建文本编辑控制器

  var editProfileForm = GlobalKey<FormState>(); // 创建表单的全局键

  @override
  void initState() {
    super.initState(); // 调用父类的initState
    // 使用Provider获取当前用户的名称，并设置为文本字段的初始值
    nameText.text = Provider.of<UserProvider>(context, listen: false).userName;
  }

  void updateData() {
    Map<String, dynamic> dataToUpdate = {
      "name": nameText.text, // 将新的姓名数据准备更新
    };

    // 更新Firestore中的用户文档
    db
        .collection("users")
        .doc(Provider.of<UserProvider>(context, listen: false).userId)
        .update(dataToUpdate);

    // 调用getUserDetails来更新本地用户数据
    Provider.of<UserProvider>(context, listen: false).getUserDetails();
    Navigator.pop(context); // 返回上一个屏幕
  }

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); // 从Provider中获取UserProvider实例

    return Scaffold(
      appBar: AppBar(
        title: Text("名前変更"), // 应用栏标题
        actions: [
          InkWell(
            onTap: () {
              if (editProfileForm.currentState!.validate()) {
                // 如果表单验证通过
                updateData(); // 调用updateData方法更新数据
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check), // 显示一个勾选图标，表示完成编辑
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: editProfileForm, // 将全局键赋给Form小部件
            child: Column(children: [
              SizedBox(
                width: 300,
                child: TextFormField(
                    textAlign: TextAlign.center,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name cannot be empty."; // 验证姓名输入是否为空
                      }
                    },
                    controller: nameText, // 使用nameText控制器
                    decoration: InputDecoration(
                      label: Text("Name"), filled: true,
                      fillColor: Colors.grey.shade100, // 名称输入框装饰
                    )),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
