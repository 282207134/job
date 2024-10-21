import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class SchoolFestivalAccount extends StatefulWidget {
  @override
  _SchoolFestivalAccountState createState() => _SchoolFestivalAccountState();
}

class _SchoolFestivalAccountState extends State<SchoolFestivalAccount> {
  double balance = 0;
  int g3Count = 0;
  int g6Count = 0;
  int friedRiceCount = 0;
  int coinCount = 0;
  int drinkCount = 0;
  int toppingCount = 0;
  int lotteryCount = 0;

  double totalAmount = 0;
  double receivedAmount = 0;

  Timer? _timer;

  final TextEditingController _receivedAmountController = TextEditingController();

  int tempG3Count = 0;
  int tempG6Count = 0;
  int tempFriedRiceCount = 0;
  int tempCoinCount = 0;
  int tempDrinkCount = 0;
  int tempToppingCount = 0;
  int tempLotteryCount = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission(); // 请求存储权限
    loadBalance();
    loadCounts();
  }
  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }
  Future<void> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('balance') ?? 0;
    });
  }

  Future<void> loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      g3Count = prefs.getInt('g3Count') ?? 0;
      g6Count = prefs.getInt('g6Count') ?? 0;
      friedRiceCount = prefs.getInt('friedRiceCount') ?? 0;
      coinCount = prefs.getInt('coinCount') ?? 0;
      drinkCount = prefs.getInt('drinkCount') ?? 0;
      toppingCount = prefs.getInt('toppingCount') ?? 0;
      lotteryCount = prefs.getInt('lotteryCount') ?? 0;
    });
  }

  Future<void> _addAmount(double amount, String menu) async {
    setState(() {
      balance += amount;
      _incrementCount(menu);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
    await _saveCounts();
  }

  Future<void> _deductAmount(double amount, String menu) async {
    setState(() {
      balance -= amount;
      _decrementCount(menu);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
    await _saveCounts();
  }

  Future<void> _saveCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('g3Count', g3Count);
    await prefs.setInt('g6Count', g6Count);
    await prefs.setInt('friedRiceCount', friedRiceCount);
    await prefs.setInt('coinCount', coinCount);
    await prefs.setInt('drinkCount', drinkCount);
    await prefs.setInt('toppingCount', toppingCount);
    await prefs.setInt('lotteryCount', lotteryCount);
  }

  void _incrementCount(String menu) {
    switch (menu) {
      case 'g3': g3Count++; break;
      case 'g6': g6Count++; break;
      case 'friedRice': friedRiceCount++; break;
      case 'coin': coinCount++; break;
      case 'drink': drinkCount++; break;
      case 'topping': toppingCount++; break;
      case 'lottery': lotteryCount++; break;
    }
  }

  void _decrementCount(String menu) {
    switch (menu) {
      case 'g3': if (g3Count > 0) g3Count--; break;
      case 'g6': if (g6Count > 0) g6Count--; break;
      case 'friedRice': if (friedRiceCount > 0) friedRiceCount--; break;
      case 'coin': if (coinCount > 0) coinCount--; break;
      case 'drink': if (drinkCount > 0) drinkCount--; break;
      case 'topping': if (toppingCount > 0) toppingCount--; break;
      case 'lottery': if (lotteryCount > 0) lotteryCount--; break;
    }
  }

  @override
  void dispose() {
    _receivedAmountController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('メニュー'),
      TextCellValue('注文総数'),
      TextCellValue('金額'),
    ]);

    // 添加数据行
    sheet.appendRow([
      TextCellValue('餃子3個'),
      IntCellValue(g3Count),
      DoubleCellValue(150 * g3Count.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('餃子6個'),
      IntCellValue(g6Count),
      DoubleCellValue(250 * g6Count.toDouble()),
    ]);


    sheet.appendRow([
      TextCellValue('炒飯'),
      IntCellValue(friedRiceCount),
      DoubleCellValue(300 * friedRiceCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('ワンコイン'),
      IntCellValue(coinCount),
      DoubleCellValue(500 * coinCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('ドリンク'),
      IntCellValue(drinkCount),
      DoubleCellValue(100 * drinkCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('トッピング'),
      IntCellValue(toppingCount),
      DoubleCellValue(100 * toppingCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('100円くじ'),
      IntCellValue(lotteryCount),
      DoubleCellValue(100 * lotteryCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('合計'),
      IntCellValue(_calculateTotalOrderCount()),
      DoubleCellValue(_calculateTotalOrderAmount()),
    ]);

    var fileBytes = excel.save();

    if (!kIsWeb && fileBytes != null) {
      // 使用外部存储目录，将文件保存到 Downloads 文件夹
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String path = '${directory.path}/Download/SchoolFestivalAccount.xlsx';

        if (await Permission.storage.request().isGranted) {
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          print('Excel file exported to $path');
        } else {
          print('Storage permission denied.');
        }
      }
    } else if (kIsWeb) {
      excel.save(fileName: 'SchoolFestivalAccount.xlsx');
    }
  }
  int _calculateTotalOrderCount() {
    return g3Count + g6Count + friedRiceCount + coinCount + drinkCount + toppingCount + lotteryCount;
  }

  double _calculateTotalOrderAmount() {
    return (g3Count * 150) + (g6Count * 250) + (friedRiceCount * 300) +
        (coinCount * 500) + (drinkCount * 100) + (toppingCount * 100) +
        (lotteryCount * 100);
  }


  void _resetAllData() async {
    setState(() {
      g3Count = g6Count = friedRiceCount = coinCount = drinkCount = toppingCount = lotteryCount = 0;
      balance = totalAmount = receivedAmount = 0;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
    await prefs.setInt('g3Count', g3Count);
    await prefs.setInt('g6Count', g6Count);
    await prefs.setInt('friedRiceCount', friedRiceCount);
    await prefs.setInt('coinCount', coinCount);
    await prefs.setInt('drinkCount', drinkCount);
    await prefs.setInt('toppingCount', toppingCount);
    await prefs.setInt('lotteryCount', lotteryCount);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("学園祭会計app"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: "注文"),
                Tab(text: "まとめ注文"),
                Tab(text: "統計"),
              ],
              labelColor: Colors.yellow,
            ),
          ),
          body: TabBarView(
            children: [
              _buildAccountTab(),
              _buildPaymentTab(),
              _buildMenuStatisticsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("営業収入:", style: TextStyle(fontSize: 27)),
          Text(
            '${NumberFormat.simpleCurrency().format(balance)}',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          Container(
            width: double.infinity,
            child: Card(
              child: Text(
                textAlign: TextAlign.center,
                'メニュー',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              color: Colors.amberAccent.shade200,
            ),
          ),
          _buildMenuItem("餃子3個(150円)", 150, 'g3'),
          _buildMenuItem("餃子6個(250円)", 250, 'g6'),
          _buildMenuItem("炒飯(300円)", 300, 'friedRice'),
          _buildMenuItem("ワンコイン(500円)", 500, 'coin'),
          _buildMenuItem("ドリンク(100円)", 100, 'drink'),
          _buildMenuItem("トッピング(100円)", 100, 'topping'),
          _buildMenuItem("100円くじ(100円)", 100, 'lottery'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, double price, String menu) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20)),
          SizedBox(width: 5),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, padding: EdgeInsets.all(5)),
                onPressed: () => _addAmount(price, menu),
                child: Text("+1",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
                onPressed: () => _deductAmount(price, menu),
                child: Text("-1",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuStatisticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DataTable(
            columns: [
              DataColumn(label: Text('メニュー')),
              DataColumn(label: Text('注文総数')),
              DataColumn(label: Text('金額')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('餃子3個')),
                DataCell(Text('$g3Count')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(150 * g3Count)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('餃子6個')),
                DataCell(Text('$g6Count')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(250 * g6Count)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('炒飯')),
                DataCell(Text('$friedRiceCount')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(300 * friedRiceCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('ワンコイン')),
                DataCell(Text('$coinCount')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(500 * coinCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('ドリンク')),
                DataCell(Text('$drinkCount')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * drinkCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('トッピング')),
                DataCell(Text('$toppingCount')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * toppingCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('100円くじ')),
                DataCell(Text('$lotteryCount')),
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * lotteryCount)}')),
              ]),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "注文総数: ${_calculateTotalOrderCount()}",
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
          Text(
            "営業総金額: ${NumberFormat.simpleCurrency().format(_calculateTotalOrderAmount())}",
            style: TextStyle(fontSize: 18, color: Colors.amberAccent),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              ElevatedButton(
                onPressed: _exportToExcel,
                child: Text('Excelファイルに出力',
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onLongPressStart: (details) {
                  _timer = Timer(Duration(seconds: 3), () {
                    _resetAllData();
                  });
                },
                onLongPressEnd: (details) {
                  _timer?.cancel();
                },
                onLongPressCancel: () {
                  _timer?.cancel();
                },
                child: ElevatedButton(
                  child: Text(
                    '長押し、システムをリセットする',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _exportExcelFile() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('メニュー'),
      TextCellValue('注文総数'),
      TextCellValue('金額'),
    ]);

    sheet.appendRow([
      TextCellValue('餃子3個'),
      IntCellValue(g3Count),
      DoubleCellValue(150 * g3Count.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('餃子6個'),
      IntCellValue(g6Count),
      DoubleCellValue(250 * g6Count.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('炒飯'),
      IntCellValue(friedRiceCount),
      DoubleCellValue(300 * friedRiceCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('ワンコイン'),
      IntCellValue(coinCount),
      DoubleCellValue(500 * coinCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('ドリンク'),
      IntCellValue(drinkCount),
      DoubleCellValue(100 * drinkCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('トッピング'),
      IntCellValue(toppingCount),
      DoubleCellValue(100 * toppingCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('100円くじ'),
      IntCellValue(lotteryCount),
      DoubleCellValue(100 * lotteryCount.toDouble()),
    ]);

    sheet.appendRow([
      TextCellValue('合計'),
      IntCellValue(_calculateTotalOrderCount()),
      DoubleCellValue(_calculateTotalOrderAmount()),
    ]);

    var fileBytes = excel.save();



    if (!kIsWeb) {
      // 先请求存储权限
      if (await Permission.storage.request().isGranted) {
        Directory directory = await getApplicationDocumentsDirectory();
        // 获取当前日期时间并格式化为 yyyymmddHHmm 的格式
        String formattedDate = DateFormat('yyyyMMddHHmm').format(DateTime.now());
        String fileName = '統計データ$formattedDate.xlsx';
        String path = '${directory.path}/$fileName';

        if (fileBytes != null) {
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          print('Excel file exported to $path');
        } else {
          print('Error: Unable to save file.');
        }
      } else {
        print('Storage permission denied.');
      }
    } else {
      // Web环境
      // 获取当前日期时间并格式化为 yyyymmddHHmm 的格式
      String formattedDate = DateFormat('yyyyMMddHHmm').format(DateTime.now());
      String fileName = '統計データ$formattedDate.xlsx';

      // 使用动态生成的文件名保存Excel文件
      excel.save(fileName: fileName);
    }
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Card(
                child: Text(
                  textAlign: TextAlign.center,
                  'メニュー',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                color: Colors.amberAccent.shade200,
              ),
            ),
            _buildMenuSelector("餃子3個(150円)", 150, 'g3', tempG3Count),
            _buildMenuSelector("餃子6個(250円)", 250, 'g6', tempG6Count),
            _buildMenuSelector("炒飯(300円)", 300, 'friedRice', tempFriedRiceCount),
            _buildMenuSelector("ワンコイン(500円)", 500, 'coin', tempCoinCount),
            _buildMenuSelector("ドリンク(100円)", 100, 'drink', tempDrinkCount),
            _buildMenuSelector("トッピング(100円)", 100, 'topping', tempToppingCount),
            _buildMenuSelector("100円くじ(100円)", 100, 'lottery', tempLotteryCount),
            Text("総金額: ${NumberFormat.simpleCurrency().format(totalAmount)}",
                style: TextStyle(fontSize: 20, color: Colors.yellow)),
            TextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
              controller: _receivedAmountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '預かった金額を入力してください',
                hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  receivedAmount = double.tryParse(value) ?? 0;
                });
              },
            ),
            Text(
              receivedAmount - totalAmount < 0
                  ? "金額不足"
                  : "お釣り: ${NumberFormat.simpleCurrency().format(receivedAmount - totalAmount)}",
              style: TextStyle(
                  fontSize: 20,
                  color: receivedAmount - totalAmount < 0
                      ? Colors.red
                      : Colors.blue.shade300),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(4)),
                  onPressed: () {
                    _addToBalance();
                    _clearTempCounts();
                    _clearReceivedAmount();
                  },
                  child: Text("営業収入に追加して、リセット",
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
                  onPressed: () {
                    _clearTotalAmount();
                    _clearTempCounts();
                    _clearReceivedAmount();
                  },
                  child: Text("リセット",
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelector(String title, double price, String menu, int tempCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 15)),
          Spacer(),
          Text("数量: $tempCount"),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, padding: EdgeInsets.all(5)),
            onPressed: () {
              setState(() {
                _incrementTempCount(menu);
                totalAmount += price;
              });
            },
            child: Text("+1",
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
            onPressed: () {
              setState(() {
                _decrementTempCount(menu);
                totalAmount -= price;
              });
            },
            child: Text("-1",
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearReceivedAmount() {
    setState(() {
      receivedAmount = 0;
      _receivedAmountController.clear();
    });
  }

  void _clearTempCounts() {
    setState(() {
      tempG3Count = 0;
      tempG6Count = 0;
      tempFriedRiceCount = 0;
      tempCoinCount = 0;
      tempDrinkCount = 0;
      tempToppingCount = 0;
      tempLotteryCount = 0;
    });
  }

  void _addToBalance() async {
    setState(() {
      g3Count += tempG3Count;
      g6Count += tempG6Count;
      friedRiceCount += tempFriedRiceCount;
      coinCount += tempCoinCount;
      drinkCount += tempDrinkCount;
      toppingCount += tempToppingCount;
      lotteryCount += tempLotteryCount;

      tempG3Count = 0;
      tempG6Count = 0;
      tempFriedRiceCount = 0;
      tempCoinCount = 0;
      tempDrinkCount = 0;
      tempToppingCount = 0;
      tempLotteryCount = 0;

      balance += totalAmount;
      totalAmount = 0;
      _receivedAmountController.clear();
    });

    await _saveCounts();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
  }

  void _clearTotalAmount() {
    setState(() {
      totalAmount = 0;
      _receivedAmountController.clear();
      receivedAmount = 0;
    });
  }

  void _incrementTempCount(String menu) {
    switch (menu) {
      case 'g3': tempG3Count++; break;
      case 'g6': tempG6Count++; break;
      case 'friedRice': tempFriedRiceCount++; break;
      case 'coin': tempCoinCount++; break;
      case 'drink': tempDrinkCount++; break;
      case 'topping': tempToppingCount++; break;
      case 'lottery': tempLotteryCount++; break;
    }
  }

  void _decrementTempCount(String menu) {
    switch (menu) {
      case 'g3': if (tempG3Count > 0) tempG3Count--; break;
      case 'g6': if (tempG6Count > 0) tempG6Count--; break;
      case 'friedRice': if (tempFriedRiceCount > 0) tempFriedRiceCount--; break;
      case 'coin': if (tempCoinCount > 0) tempCoinCount--; break;
      case 'drink': if (tempDrinkCount > 0) tempDrinkCount--; break;
      case 'topping': if (tempToppingCount > 0) tempToppingCount--; break;
      case 'lottery': if (tempLotteryCount > 0) tempLotteryCount--; break;
    }
  }
}
