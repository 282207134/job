import 'package:cloud_firestore/cloud_firestore.dart'; // 引入Cloud Firestore库
import 'package:flutter/material.dart'; // 引入Flutter材料设计库
import 'package:provider/provider.dart'; // 引入状态管理库
import '../providers/userProvider.dart'; // 引入用户提供者

// 定义ChatroomScreen类，一个有状态的小部件
class ChatroomScreen extends StatefulWidget {
  String chatroomName; // 聊天室名称
  String chatroomId; // 聊天室ID

  // 构造函数
  ChatroomScreen(
      {super.key, required this.chatroomName, required this.chatroomId});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState(); // 创建状态
}

// 定义_ChatroomScreenState类，是ChatroomScreen的状态
class _ChatroomScreenState extends State<ChatroomScreen> {
  var db = FirebaseFirestore.instance; // 获取Firestore实例
  TextEditingController messageText = TextEditingController(); // 创建消息文本编辑控制器

  // 定义发送消息的方法
  Future<void> sendMessage() async {
    if (messageText.text.isEmpty) {
      return; // 如果消息为空则不执行任何操作
    }
    Map<String, dynamic> messageToSend = {
      "text": messageText.text, // 消息文本
      "sender_name":
          Provider.of<UserProvider>(context, listen: false).userName, // 发送者姓名
      "sender_id":
          Provider.of<UserProvider>(context, listen: false).userId, // 发送者ID
      "chatroom_id": widget.chatroomId, // 聊天室ID
      "timestamp": FieldValue.serverTimestamp(), // 消息时间戳
    };
    messageText.text = ""; // 清空输入框

    try {
      await db.collection("messages").add(messageToSend); // 将消息添加到Firestore
    } catch (e) {} // 捕获并忽略任何错误
  }

  // 定义单条聊天消息的布局
  Widget singleChatItem({
    required String sender_name, // 发送者姓名
    required String text, // 消息文本
    required String sender_id, // 发送者ID
    required Timestamp? timestamp, // 消息时间戳
  }) {
    DateTime dateTime =
        timestamp?.toDate() ?? DateTime.now(); // 将时间戳转换为DateTime
    String formattedTime = "${dateTime.hour}:${dateTime.minute}"; // 格式化时间
    return Column(
      crossAxisAlignment:
          sender_id == Provider.of<UserProvider>(context, listen: false).userId
              ? CrossAxisAlignment.end // 如果消息是由当前用户发送，右对齐
              : CrossAxisAlignment.start, // 如果消息是由他人发送，左对齐
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6),
          child: Text(sender_name,
              style: TextStyle(fontWeight: FontWeight.bold)), // 发送者姓名
        ),
        Container(
            decoration: BoxDecoration(
                color: sender_id ==
                        Provider.of<UserProvider>(context, listen: false).userId
                    ? Colors.grey[300] // 当前用户消息背景
                    : Colors.blueGrey[900], // 其他用户消息背景
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedTime, // 显示消息时间
                      style: TextStyle(
                          color: sender_id ==
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .userId
                              ? Colors.black54
                              : Colors.white70,
                          fontSize: 10)),
                  SizedBox(height: 5), // 间隔
                  Text(text,
                      style: TextStyle(
                          color: sender_id ==
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .userId
                              ? Colors.black // 当前用户消息文本颜色
                              : Colors.white)), // 其他用户消息文本颜色
                ],
              ),
            )),
        SizedBox(height: 8) // 间隔
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.chatroomName)), // 应用栏显示聊天室名称
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder(
              stream: db
                  .collection("messages") // 指定消息集合
                  .where("chatroom_id",
                      isEqualTo: widget.chatroomId) // 过滤条件，指定聊天室ID
                  .limit(100) // 限制显示消息数量为最近100条,
                  .orderBy("timestamp", descending: true) // 按时间戳降序排列
                  .snapshots(), // 从Firestore订阅消息数据

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("Some error has occurred!"); // 显示错误信息
                }

                var allMessages = snapshot.data?.docs ?? []; // 获取所有消息

                if (allMessages.length < 1) {
                  return Center(child: Text("No messages here")); // 没有消息时显示
                }
                return ListView.builder(
                    reverse: true, // 消息列表反向排序，新消息在下
                    itemCount: allMessages.length, // 消息条数
                    itemBuilder: (BuildContext context, int index) {
                      var message = allMessages[index].data()
                          as Map<String, dynamic>; // 获取单条消息数据
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: singleChatItem(
                            sender_name: message["sender_name"],
                            text: message["text"],
                            sender_id: message["sender_id"],
                            timestamp: message["timestamp"]), // 显示单条消息
                      );
                    });
              },
            )),
            Container(
              color: Colors.grey[200], // 输入框背景颜色
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                    controller: messageText, // 绑定文本控制器
                    decoration: InputDecoration(
                        hintText: "Write message here...", // 消息输入提示
                        border: InputBorder.none), // 无边框
                  )),
                  InkWell(onTap: sendMessage, child: Icon(Icons.send)) // 发送按钮
                ]),
              ),
            )
          ],
        ));
  }
}
