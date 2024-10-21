import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入共享偏好设置库
import 'package:intl/intl.dart'; // 导入国际化库，用于格式化金额
import 'package:path_provider/path_provider.dart'; // 导入路径提供器库，用于获取存储路径
import 'package:excel/excel.dart'; // 导入 Excel 库，用于处理 Excel 文件
import 'dart:io'; // 导入 Dart 的 IO 库，用于文件操作
import 'dart:html' as html; // 导入 HTML 库，用于 Web 中的文件下载
import 'dart:async'; // 导入 Timer 所需的包

class SchoolFestivalAccount extends StatefulWidget {
  @override
  _SchoolFestivalAccountState createState() => _SchoolFestivalAccountState();
}

// 状态类
class _SchoolFestivalAccountState extends State<SchoolFestivalAccount> {
  double balance = 0; // 总营业收入
  int g3Count = 0; // 记录菜单“餃子3個”的购买次数
  int g6Count = 0; // 记录菜单“餃子6個”的购买次数
  int friedRiceCount = 0; // 记录菜单“炒飯”的购买次数
  int coinCount = 0; // 记录菜单“ワンコイン”的购买次数
  int drinkCount = 0; // 记录菜单“ドリンク”的购买次数
  int toppingCount = 0; // 记录菜单“トッピング”的购买次数
  int lotteryCount = 0; // 记录菜单“100円くじ”的购买次数
  int menuCount = 0; // 总注文数

  double totalAmount = 0; // 选择的菜单总金额
  double receivedAmount = 0; // 收到的金额

  Timer? _timer; // 在类中声明一个 Timer 变量

  final TextEditingController _receivedAmountController =
      TextEditingController(); // 输入框控制器

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
    loadBalance(); // 初始化时加载总营业收入
    loadCounts(); // 加载菜单项计数
  }

  // 异步方法：加载总营业收入
  Future<void> loadBalance() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance(); // 获取共享偏好设置实例
    setState(() {
      balance = prefs.getDouble('balance') ?? 0; // 获取存储的总营业收入，如果不存在则为0
    });
  }

  // 异步方法：加载菜单项计数
  Future<void> loadCounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

  // 异步方法：增加金额并更新相应的菜单计数
  Future<void> _addAmount(double amount, String menu) async {
    setState(() {
      balance += amount; // 增加金额到余额
      _incrementCount(menu); // 增加该菜单的计数
    });
    final SharedPreferences prefs =
        await SharedPreferences.getInstance(); // 获取共享偏好设置实例
    await prefs.setDouble('balance', balance); // 保存数据到本地
    await _saveCounts(); // 保存计数器
  }

  // 异步方法：减少金额并更新相应的菜单计数
  Future<void> _deductAmount(double amount, String menu) async {
    setState(() {
      balance -= amount; // 减少金额从余额
      _decrementCount(menu); // 减少该菜单的计数
    });
    final SharedPreferences prefs =
        await SharedPreferences.getInstance(); // 获取共享偏好设置实例
    await prefs.setDouble('balance', balance); // 保存数据到本地
    await _saveCounts(); // 保存计数器
  }

  // 保存计数器到 SharedPreferences
  Future<void> _saveCounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('g3Count', g3Count);
    await prefs.setInt('g6Count', g6Count);
    await prefs.setInt('friedRiceCount', friedRiceCount);
    await prefs.setInt('coinCount', coinCount);
    await prefs.setInt('drinkCount', drinkCount);
    await prefs.setInt('toppingCount', toppingCount);
    await prefs.setInt('lotteryCount', lotteryCount);
  }

  // 根据菜单名称增加对应的计数器
  void _incrementCount(String menu) {
    switch (menu) {
      case 'g3':
        g3Count++; // 增加“餃子3個”的计数
        break;
      case 'g6':
        g6Count++; // 增加“餃子6個”的计数
        break;
      case 'friedRice':
        friedRiceCount++; // 增加“炒飯”的计数
        break;
      case 'coin':
        coinCount++; // 增加“ワンコイン”的计数
        break;
      case 'drink':
        drinkCount++; // 增加“ドリンク”的计数
        break;
      case 'topping':
        toppingCount++; // 增加“トッピング”的计数
        break;
      case 'lottery':
        lotteryCount++; // 增加“100円くじ”的计数
        break;
    }
  }

  // 根据菜单名称减少对应的计数器
  void _decrementCount(String menu) {
    switch (menu) {
      case 'g3':
        if (g3Count > 0) g3Count--; // 若计数大于0，减少“餃子3個”的计数
        break;
      case 'g6':
        if (g6Count > 0) g6Count--; // 若计数大于0，减少“餃子6個”的计数
        break;
      case 'friedRice':
        if (friedRiceCount > 0) friedRiceCount--; // 若计数大于0，减少“炒飯”的计数
        break;
      case 'coin':
        if (coinCount > 0) coinCount--; // 若计数大于0，减少“ワンコイン”的计数
        break;
      case 'drink':
        if (drinkCount > 0) drinkCount--; // 若计数大于0，减少“ドリンク”的计数
        break;
      case 'topping':
        if (toppingCount > 0) toppingCount--; // 若计数大于0，减少“トッピング”的计数
        break;
      case 'lottery':
        if (lotteryCount > 0) lotteryCount--; // 若计数大于0，减少“100円くじ”的计数
        break;
    }
  }

  // 释放资源：在State销毁时释放controller
  @override
  void dispose() {
    _receivedAmountController.dispose(); // 释放输入框的controller资源
    _timer?.cancel(); // 销毁计时器
    super.dispose();
  }

  // 计算总订单数量
  int _calculateTotalOrderCount() {
    return g3Count +
        g6Count +
        friedRiceCount +
        coinCount +
        drinkCount +
        toppingCount +
        lotteryCount; // 计算总订单数
  }

  // 计算总订单金额
  double _calculateTotalOrderAmount() {
    return (g3Count * 150) +
        (g6Count * 250) +
        (friedRiceCount * 300) +
        (coinCount * 500) +
        (drinkCount * 100) +
        (toppingCount * 100) +
        (lotteryCount * 100); // 计算总金额
  }

  void _resetAllData() async {
    setState(() {
      // Reset all menu counters
      g3Count = 0;
      g6Count = 0;
      friedRiceCount = 0;
      coinCount = 0;
      drinkCount = 0;
      toppingCount = 0;
      lotteryCount = 0;

      // Reset temporary counters
      tempG3Count = 0;
      tempG6Count = 0;
      tempFriedRiceCount = 0;
      tempCoinCount = 0;
      tempDrinkCount = 0;
      tempToppingCount = 0;
      tempLotteryCount = 0;

      // Reset financial values
      balance = 0;
      totalAmount = 0;
      receivedAmount = 0;
    });

    // Clear the SharedPreferences data
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

  // 构建界面
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 设置Tab的数量为3
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // 关闭debug条幅
        theme: ThemeData.dark(), // 使用黑暗主题
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("学園祭会計app"), // 设置应用标题
            leading: IconButton(
              icon: Icon(Icons.arrow_back), // 返回图标
              onPressed: () {
                Navigator.pop(context); // 返回上一个页面
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "注文",
                ), // 第一个 Tab
                Tab(text: "まとめ注文"), // 第二个 Tab
                Tab(text: "統計"), // 第三个 Tab
              ],
              labelColor: Colors.yellow, // 设置选中标签的颜色
            ),
          ),
          body: TabBarView(
            children: [
              _buildAccountTab(), // 账户 Tab 的内容
              _buildPaymentTab(), // 收款与找零 Tab 的内容
              _buildMenuStatisticsTab(), // 菜单统计 Tab 的内容
            ],
          ),
        ),
      ),
    );
  }

  // 构建账户 Tab 界面
  Widget _buildAccountTab() {
    return Container(
      padding: EdgeInsets.all(20),
      // 使用20像素的整体内边距
      color: Colors.black,
      // 设置背景颜色
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 平均分布子元素
        children: [
          Text("営業収入:", style: TextStyle(fontSize: 27)), // 显示总营业收入标题
          Text(
            '${NumberFormat.simpleCurrency().format(balance)}', // 格式化后的总营业收入
            style: TextStyle(fontSize: 24, color: Colors.white), // 设置文本样式
          ),
          Container(
            width: double.infinity,
            child: Card(
              child: Text(
                textAlign: TextAlign.center,
                'メニュー', // 显示菜单标题
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              color: Colors.amberAccent.shade200, // 设置背景颜色
            ),
          ),
          _buildMenuItem("餃子3個(150円)", 150, 'g3'), // 构建菜单项“餃子3個”
          _buildMenuItem("餃子6個(250円)", 250, 'g6'), // 构建菜单项“餃子6個”
          _buildMenuItem("炒飯(300円)", 300, 'friedRice'), // 构建菜单项“炒飯”
          _buildMenuItem("ワンコイン(500円)", 500, 'coin'), // 构建菜单项“ワンコイン”
          _buildMenuItem("ドリンク(100円)", 100, 'drink'), // 构建菜单项“ドリンク”
          _buildMenuItem("トッピング(100円)", 100, 'topping'), // 构建菜单项“トッピング”
          _buildMenuItem("100円くじ(100円)", 100, 'lottery'), // 构建菜单项“100円くじ”
        ],
      ),
    );
  }

  // 构建单个菜单项组件
  Widget _buildMenuItem(String title, double price, String menu) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 垂直对齐于末端
        children: [
          Text(title, style: TextStyle(fontSize: 20)), // 菜单项名称
          SizedBox(width: 5), // 增加5像素的水平间距
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, padding: EdgeInsets.all(5)),
                // 按钮样式
                onPressed: () => _addAmount(price, menu),
                // 点击增加金额
                child: Text("+1",
                    style:
                        TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
              ),
              SizedBox(width: 5), // 增加5像素的水平间距
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
                // 按钮样式
                onPressed: () => _deductAmount(price, menu),
                // 点击减少金额
                child: Text("-1",
                    style:
                        TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建菜单统计 Tab 界面
  Widget _buildMenuStatisticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DataTable(
            columns: [
              DataColumn(label: Text('メニュー')), // 表格列“菜单”
              DataColumn(label: Text('注文総数')), // 表格列“总订单数”
              DataColumn(label: Text('金額')), // 表格列“金额”
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('餃子3個')),
                // 行数据
                DataCell(Text('$g3Count')),
                // 显示“餃子3個”的计数
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(150 * g3Count)}')),
                // 格式化后的金额
              ]),
              DataRow(cells: [
                DataCell(Text('餃子6個')),
                DataCell(Text('$g6Count')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(250 * g6Count)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('炒飯')),
                DataCell(Text('$friedRiceCount')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(300 * friedRiceCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('ワンコイン')),
                DataCell(Text('$coinCount')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(500 * coinCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('ドリンク')),
                DataCell(Text('$drinkCount')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(100 * drinkCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('トッピング')),
                DataCell(Text('$toppingCount')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(100 * toppingCount)}')),
              ]),
              DataRow(cells: [
                DataCell(Text('100円くじ')),
                DataCell(Text('$lotteryCount')),
                DataCell(Text(
                    '${NumberFormat.simpleCurrency().format(100 * lotteryCount)}')),
              ]),
            ],
          ),
          SizedBox(height: 20), // 增加20像素的垂直间距
          Text(
            "注文総数: ${_calculateTotalOrderCount()}", // 显示总订单数量
            style: TextStyle(fontSize: 18, color: Colors.blue), // 设置文本样式
          ),
          Text(
            "営業総金額: ${NumberFormat.simpleCurrency().format(_calculateTotalOrderAmount())}", // 显示总金额
            style: TextStyle(fontSize: 18, color: Colors.amberAccent), // 设置文本样式
          ),
          SizedBox(height: 20), // 增加20像素的垂直间距
          Row(
            children: [
              ElevatedButton(
                onPressed: _exportToExcel, // 点击导出文件
                child: Text('Excelファイルに出力',
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              Spacer(),
              GestureDetector(
                onLongPressStart: (details) {
                  // 开始长按时启动计时器
                  _timer = Timer(Duration(seconds: 3), () {
                    // 长按3秒后执行清空操作
                    _resetAllData();
                  });
                },
                onLongPressEnd: (details) {
                  // 长按结束时取消计时器
                  _timer?.cancel();
                },
                onLongPressCancel: () {
                  // 如果长按被取消，确保计时器被取消
                  _timer?.cancel();
                },
                child: ElevatedButton(
                  child: Text(
                    '長押し、システムをリセットする',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {}, // 留空以避免单击事件
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 导出到 Excel 文件
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel(); // 创建 Excel 实例

    Sheet sheet = excel['Sheet1']; // 获取工作表

    sheet.appendRow([
      // 添加标题行
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
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);
    sheet.appendRow([
      TextCellValue('合計'),
      IntCellValue(_calculateTotalOrderCount()),
      DoubleCellValue(_calculateTotalOrderAmount()),
    ]);
    // 处理文件保存
    if (kIsWeb) {
      // 如果是 Web
      List<int>? fileBytes = excel.save(); // 生成文件字节
      final blob = html.Blob([
        fileBytes
      ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'); // 创建 blob
      final url = html.Url.createObjectUrl(blob); // 创建 URL
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '統計データ.xlsx') // 设置下载文件名
        ..click(); // 触发下载
      html.Url.revokeObjectUrl(url); // 撤销 URL
    } else {
      // 移动设备
      Directory? directory =
          await getApplicationDocumentsDirectory(); // 获取应用文档目录
      String path = '${directory.path}/My_Excel_File_Name.xlsx'; // 文件路径
      List<int>? fileBytes = excel.save(); // 生成文件字节

      if (fileBytes != null) {
        // 如果文件字节不为空
        File(path) // 创建文件
          ..createSync(recursive: true) // 创建目录
          ..writeAsBytesSync(fileBytes); // 写入字节到文件
        print('已导出为 $path'); // 打印文件路径
      }
    }
  }

  // 构建收款与找零 Tab 界面
  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15), // 设置20像素的内边距
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Card(
                child: Text(
                  textAlign: TextAlign.center,
                  'メニュー', // 显示菜单
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                color: Colors.amberAccent.shade200, // 设置背景颜色
              ),
            ),
            // 构建菜单选择器
            _buildMenuSelector("餃子3個(150円)", 150, 'g3', tempG3Count),
            _buildMenuSelector("餃子6個(250円)", 250, 'g6', tempG6Count),
            _buildMenuSelector(
                "炒飯(300円)", 300, 'friedRice', tempFriedRiceCount),
            _buildMenuSelector("ワンコイン(500円)", 500, 'coin', tempCoinCount),
            _buildMenuSelector("ドリンク(100円)", 100, 'drink', tempDrinkCount),
            _buildMenuSelector("トッピング(100円)", 100, 'topping', tempToppingCount),
            _buildMenuSelector(
                "100円くじ(100円)", 100, 'lottery', tempLotteryCount),
            Text("総金額: ${NumberFormat.simpleCurrency().format(totalAmount)}",
                // 显示总金额
                style: TextStyle(fontSize: 20, color: Colors.yellow)), // 设置文本样式
            TextField(
              textAlign: TextAlign.center,
              // 输入框文本居中
              style: TextStyle(fontSize: 18),
              // 设置输入框文本大小
              controller: _receivedAmountController,
              // 绑定controller
              decoration: InputDecoration(
                border: OutlineInputBorder(), // 设置边框样式
                hintText: '預かった金額を入力してください', // 提示文本
                hintStyle: TextStyle(
                    color: Colors.grey.shade700, fontSize: 15), // 提示文本样式
              ),
              keyboardType: TextInputType.number,
              // 设置键盘为数字输入
              onChanged: (value) {
                setState(() {
                  receivedAmount = double.tryParse(value) ?? 0; // 解析输入金额
                });
              },
            ),
            Text(
              receivedAmount - totalAmount < 0
                  ? "金額不足"
                  : "お釣り: ${NumberFormat.simpleCurrency().format(receivedAmount - totalAmount)}", // 根据金额显示文字
              style: TextStyle(
                  fontSize: 20,
                  color: receivedAmount - totalAmount < 0
                      ? Colors.red
                      : Colors.blue.shade300), // 设置文本样式
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子元素之间的间距相等
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(4)), // 按钮样式
                  onPressed: () {
                    _addToBalance(); // 将临时计数器的值添加到总营业收入
                    _clearTempCounts(); // 清空临时计数器
                    _clearReceivedAmount(); // 清零输入金额
                  },
                  child: Text("営業収入に追加して、リセット",
                      style:
                          TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
                ),
                SizedBox(width: 10), // 增加10像素的水平间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
                  // 按钮样式
                  onPressed: () {
                    _clearTotalAmount(); // 清空总金额
                    _clearTempCounts(); // 清空临时计数器
                    _clearReceivedAmount(); // 清零输入金额
                  },
                  child: Text("リセット",
                      style:
                          TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建菜单选择器组件
  Widget _buildMenuSelector(
      String title, double price, String menu, int tempCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 15)), // 显示菜单项名称
          Spacer(),
          Text("数量: $tempCount"), // 显示购买数量
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, padding: EdgeInsets.all(5)),
            // 按钮样式
            onPressed: () {
              setState(() {
                _incrementTempCount(menu); // 增加临时计数
                totalAmount += price; // 增加总金额
              });
            },
            child: Text("+1",
                style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.all(5)), // 按钮样式
            onPressed: () {
              setState(() {
                _decrementTempCount(menu); // 减少临时计数
                totalAmount -= price; // 减少总金额
              });
            },
            child: Text("-1",
                style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
        ],
      ),
    );
  }

  // 清零输入金额
  void _clearReceivedAmount() {
    setState(() {
      receivedAmount = 0;
      _receivedAmountController.clear(); // 清空输入框
    });
  }

  // 清空临时计数器
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

  // 增加到余额并重置总金额
  void _addToBalance() async {
    setState(() {
      // 将临时计数器的值加到总计数器
      g3Count += tempG3Count;
      g6Count += tempG6Count;
      friedRiceCount += tempFriedRiceCount;
      coinCount += tempCoinCount;
      drinkCount += tempDrinkCount;
      toppingCount += tempToppingCount;
      lotteryCount += tempLotteryCount;

      // 清空临时计数器
      tempG3Count = 0;
      tempG6Count = 0;
      tempFriedRiceCount = 0;
      tempCoinCount = 0;
      tempDrinkCount = 0;
      tempToppingCount = 0;
      tempLotteryCount = 0;

      balance += totalAmount; // 增加到总营业收入
      totalAmount = 0; // 清零总金额
      _receivedAmountController.clear(); // 清空預かった金額输入框
    });

    await _saveCounts(); // 保存累积的计数到本地
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance); // 保存数据到本地
  }

  // 清空总金额和收到的金额
  void _clearTotalAmount() {
    setState(() {
      totalAmount = 0; // 清零仅当前选择的总金额
      _receivedAmountController.clear(); // 清空預かった金額输入框
      receivedAmount = 0; // 清零收到的金额
    });
  }

  // 增加临时计数器
  void _incrementTempCount(String menu) {
    switch (menu) {
      case 'g3':
        tempG3Count++;
        break;
      case 'g6':
        tempG6Count++;
        break;
      case 'friedRice':
        tempFriedRiceCount++;
        break;
      case 'coin':
        tempCoinCount++;
        break;
      case 'drink':
        tempDrinkCount++;
        break;
      case 'topping':
        tempToppingCount++;
        break;
      case 'lottery':
        tempLotteryCount++;
        break;
    }
  }

  // 减少临时计数器
  void _decrementTempCount(String menu) {
    switch (menu) {
      case 'g3':
        if (tempG3Count > 0) tempG3Count--;
        break;
      case 'g6':
        if (tempG6Count > 0) tempG6Count--;
        break;
      case 'friedRice':
        if (tempFriedRiceCount > 0) tempFriedRiceCount--;
        break;
      case 'coin':
        if (tempCoinCount > 0) tempCoinCount--;
        break;
      case 'drink':
        if (tempDrinkCount > 0) tempDrinkCount--;
        break;
      case 'topping':
        if (tempToppingCount > 0) tempToppingCount--;
        break;
      case 'lottery':
        if (tempLotteryCount > 0) tempLotteryCount--;
        break;
    }
  }
}
