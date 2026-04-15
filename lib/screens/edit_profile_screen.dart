import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库
import 'package:flutter/src/widgets/framework.dart'; // 导入 Flutter 框架基础库
import 'package:provider/provider.dart'; // 导入状态管理 Provider 包
import 'package:cloud_firestore/cloud_firestore.dart'; // 导入 Cloud Firestore 数据库库

import '../providers/app_language_provider.dart'; // 导入应用语言状态管理器
import '../providers/userProvider.dart'; // 导入用户状态管理器

// 定义编辑个人资料屏幕类(有状态组件)
class EditProfileScreen extends StatefulWidget { // 编辑个人资料屏幕
  const EditProfileScreen({super.key}); // 构造函数,传递 key 参数

  @override // 重写父类方法
  State<EditProfileScreen> createState() => _EditProfileScreenState(); // 创建并返回状态对象
}

// 定义编辑个人资料屏幕的状态类
class _EditProfileScreenState extends State<EditProfileScreen> { // 编辑个人资料屏幕的状态
  Map<String, dynamic>? userData = {}; // 存储用户数据的映射

  var db = FirebaseFirestore.instance; // 获取 Firestore 数据库实例

  TextEditingController nameText = TextEditingController(); // 创建姓名文本编辑控制器

  var editProfileForm = GlobalKey<FormState>(); // 创建表单的全局键,用于验证表单

  @override // 重写 initState 生命周期方法
  void initState() { // 初始化状态时调用
    super.initState(); // 调用父类的 initState
    // 使用 Provider 获取当前用户的名称,并设置为文本字段的初始值
    nameText.text = Provider.of<UserProvider>(context, listen: false).userName;
  }

  void updateData() { // 更新用户数据的方法
    Map<String, dynamic> dataToUpdate = { // 准备要更新的数据
      "name": nameText.text, // 新的姓名
    };

    // 更新 Firestore 中的用户文档
    db
        .collection("users") // 访问 users 集合
        .doc(Provider.of<UserProvider>(context, listen: false).userId) // 指定用户文档
        .update(dataToUpdate); // 更新文档数据

    // 调用 getUserDetails 来更新本地用户数据
    Provider.of<UserProvider>(context, listen: false).getUserDetails();
    Navigator.pop(context); // 返回上一个屏幕
  }

  @override // 重写 build 方法
  Widget build(BuildContext context) { // 构建 UI 组件
    final t = Provider.of<AppLanguageProvider>(context, listen: false).tr; // 获取翻译函数

    return Scaffold( // Material Design 脚手架
      appBar: AppBar( // 应用栏
        title: Text(t('edit_name')), // 应用栏标题:编辑姓名
        actions: [ // 应用栏右侧操作按钮
          InkWell( // 可点击区域
            onTap: () { // 点击事件
              if (editProfileForm.currentState!.validate()) { // 如果表单验证通过
                updateData(); // 调用 updateData 方法更新数据
              }
            },
            child: Padding( // 内边距
              padding: const EdgeInsets.all(8.0), // 四周 8 像素的内边距
              child: Icon(Icons.check), // 显示勾选图标,表示完成编辑
            ),
          )
        ],
      ),
      body: Container( // 容器组件
        width: double.infinity, // 宽度占满
        child: Padding( // 内边距
          padding: const EdgeInsets.all(8.0), // 四周 8 像素的内边距
          child: Form( // 表单组件
            key: editProfileForm, // 设置表单的全局键
            child: Column(children: [ // 列布局
              SizedBox( // 固定尺寸的盒子
                width: 300, // 宽度 300 像素
                child: TextFormField( // 文本表单字段
                    textAlign: TextAlign.center, // 文本居中对齐
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                    validator: (value) { // 验证器函数
                      if (value == null || value.isEmpty) { // 如果值为空
                        return t('name_empty'); // 返回姓名不能为空的错误消息
                      }
                      return null; // 验证通过
                    },
                    controller: nameText, // 使用 nameText 控制器
                    decoration: InputDecoration( // 输入框装饰
                      label: Text(t('name')), // 标签:姓名
                      filled: true, // 启用填充
                      fillColor: Colors.grey.shade100, // 填充颜色为浅灰色
                    )),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
