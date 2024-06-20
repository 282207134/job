import 'package:flutter/material.dart';

class StaffPage extends StatelessWidget {
  // 人员管理界面

  Widget build(BuildContext context) {
    final List<Map<String, String>> staffList = [
      {'name': '赤羽 将', 'staff_id': 'J22003', 'department': '3年'},
      {'name': '粟野浩大', 'staff_id': 'J22019', 'department': '3年'},
      {'name': '石毛 澪司', 'staff_id': 'J22029', 'department': '3年'},
      {'name': '伊藤大貴', 'staff_id': 'J22047', 'department': '3年'},
      {'name': '加藤圭汰', 'staff_id': 'J22104', 'department': '3年'},
      {'name': '鎌形奏汰', 'staff_id': 'J22111', 'department': '3年'},
      {'name': '工藤丈朋', 'staff_id': 'J22141', 'department': '3年'},
      {'name': '佐瀬元一', 'staff_id': 'J22194', 'department': '3年'},
      {'name': 'シ　サイトウ', 'staff_id': 'J22206', 'department': '3年'},
      {'name': '田川 天真', 'staff_id': 'J22264', 'department': '3年'},
      {'name': '多田裕志', 'staff_id': 'J22276', 'department': '3年'},
      {'name': '西脇　諒', 'staff_id': 'J22346', 'department': '3年'},
      {'name': '野呂 温輝', 'staff_id': 'J22354', 'department': '3年'},
      {'name': '松井 干里', 'staff_id': 'J22409', 'department': '3年'},
      {'name': '三浦あわい', 'staff_id': 'J22419', 'department': '3年'},
      {'name': '森田 和真', 'staff_id': 'J22433', 'department': '3年'},
      {'name': '伊藤　翼', 'staff_id': 'j21046', 'department': '4年'},
      {'name': '大垣　颯悟', 'staff_id': 'j21070', 'department': '4年'},
      {'name': '小川　颯輝', 'staff_id': 'j21087', 'department': '4年'},
      {'name': '小野　祥太', 'staff_id': 'j21099', 'department': '4年'},
      {'name': '河野　ひより', 'staff_id': 'j21153', 'department': '4年'},
      {'name': '助森　ひなた', 'staff_id': 'j21231', 'department': '4年'},
      {'name': '高橋　雅弥', 'staff_id': 'j21255', 'department': '4年'},
      {'name': '滝口　光正', 'staff_id': 'j21268', 'department': '4年'},
      {'name': '中居　瑠太', 'staff_id': 'j21303', 'department': '4年'},
      {'name': '能登　胡羽', 'staff_id': 'j21332', 'department': '4年'},
      {'name': '茂垣　光', 'staff_id': 'j21407', 'department': '4年'},
      {'name': '森久　勇太', 'staff_id': 'j21413', 'department': '4年'},
      {'name': '山口　丈瑠', 'staff_id': 'j21422', 'department': '4年'},
      {'name': 'りゅう ぎょく', 'staff_id': 'j21446', 'department': '4年'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("スタッフ管理"),
      ),
      body: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.greenAccent,
            child: ListTile(
              leading: Icon(Icons.account_circle), // 列表项图标。
              title: Text(
                staffList[index]['name']!,
                textAlign: TextAlign.center,
              ), // 标题文本。
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    staffList[index]['staff_id']!,
                  ),
                  Text(
                    staffList[index]['department']!,
                    textAlign: TextAlign.center,
                  ),
                ],
              ), // 子标题文本。
            ),
          );
        },
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}
