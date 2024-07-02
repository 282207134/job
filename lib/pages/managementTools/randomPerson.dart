import 'package:flutter/material.dart';
import 'dart:math';

class RandomPersonPickerPage extends StatefulWidget {
  @override
  _RandomPersonPickerPageState createState() => _RandomPersonPickerPageState();
}

class _RandomPersonPickerPageState extends State<RandomPersonPickerPage> {
  List<Map<String, String>> people = [
    {'name': '赤羽 将', 'staff_id': 'J22003'},
    {'name': '粟野浩大', 'staff_id': 'J22019'},
    {'name': '石毛 澪司', 'staff_id': 'J22029'},
    {'name': '伊藤大貴', 'staff_id': 'J22047'},
    {'name': '加藤圭汰', 'staff_id': 'J22104'},
    {'name': '鎌形奏汰', 'staff_id': 'J22111'},
    {'name': '工藤丈朋', 'staff_id': 'J22141'},
    {'name': '佐瀬元一', 'staff_id': 'J22194'},
    {'name': 'シ　サイトウ', 'staff_id': 'J22206'},
    {'name': '田川 天真', 'staff_id': 'J22264'},
    {'name': '多田裕志', 'staff_id': 'J22276'},
    {'name': '西脇　諒', 'staff_id': 'J22346'},
    {'name': '野呂 温輝', 'staff_id': 'J22354'},
    {'name': '松井 干里', 'staff_id': 'J22409'},
    {'name': '三浦あわい', 'staff_id': 'J22419'},
    {'name': '森田 和真', 'staff_id': 'J22433'},
    {'name': '伊藤　翼', 'staff_id': 'j21046'},
    {'name': '大垣　颯悟', 'staff_id': 'j21070'},
    {'name': '小川　颯輝', 'staff_id': 'j21087'},
    {'name': '小野　祥太', 'staff_id': 'j21099'},
    {'name': '河野　ひより', 'staff_id': 'j21153'},
    {'name': '助森　ひなた', 'staff_id': 'j21231'},
    {'name': '高橋　雅弥', 'staff_id': 'j21255'},
    {'name': '滝口　光正', 'staff_id': 'j21268'},
    {'name': '中居　瑠太', 'staff_id': 'j21303'},
    {'name': '能登　胡羽', 'staff_id': 'j21332'},
    {'name': '茂垣　光', 'staff_id': 'j21407'},
    {'name': '森久　勇太', 'staff_id': 'j21413'},
    {'name': '山口　丈瑠', 'staff_id': 'j21422'},
    {'name': 'りゅう ぎょく', 'staff_id': 'j21446'},
  ];

  String? selectedPerson;

  void pickRandomPerson() {
    final random = Random();
    int index = random.nextInt(people.length);
    setState(() {
      selectedPerson = '${people[index]['name']} (${people[index]['staff_id']})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 设置返回图标
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
        title: Text('抽選'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (selectedPerson != null)
              Text(
                '抽選された方は:\n\n $selectedPerson',
                style: TextStyle(fontSize: 24),
              )else
                Text('抽選ボタンを押してください',
                  style: TextStyle(fontSize: 24),),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickRandomPerson,
              child: Text('抽選'),
            ),
          ],
        ),
      ),
    );
  }
}
