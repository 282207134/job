import 'package:flutter/foundation.dart'; // 导入基础功能包
import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 包
import 'package:shared_preferences/shared_preferences.dart'; // 导入 Shared Preferences 包，用于持久化存储
import 'package:intl/intl.dart'; // 导入国际化日期格式化包
import 'package:path_provider/path_provider.dart'; // 导入路径提供者包，用于获取文件路径
import 'package:excel/excel.dart'; // 导入 Excel 包，用于操作 Excel 文件
import 'dart:io'; // 导入 Dart 的 IO 库，用于文件操作
import 'dart:async'; // 导入异步操作包
import 'package:flutter/foundation.dart' show kIsWeb; // 导入 Flutter 的 Web 相关功能
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理包，用于请求权限

// 定义 SchoolFestivalAccount 组件，继承 StatefulWidget
class SchoolFestivalAccount extends StatefulWidget {
  @override
  _SchoolFestivalAccountState createState() => _SchoolFestivalAccountState(); // 创建状态对象
}

// 状态类
class _SchoolFestivalAccountState extends State<SchoolFestivalAccount> {
  double balance = 0; // 初始化余额
  int g3Count = 0; // 餃子3个的数量
  int g6Count = 0; // 餃子6个的数量
  int friedRiceCount = 0; // 炒饭的数量
  int coinCount = 0; // 一元硬币的数量
  int drinkCount = 0; // 饮料的数量
  int toppingCount = 0; // 配料的数量
  int lotteryCount = 0; // 彩票的数量

  double totalAmount = 0; // 总金额
  double receivedAmount = 0; // 收到的金额

  Timer? _timer; // 定时器

  final TextEditingController _receivedAmountController = // 输入控制器
  TextEditingController();

  // 临时计数变量
  int tempG3Count = 0; // 临时 餃子3个数量
  int tempG6Count = 0; // 临时 餃子6个数量
  int tempFriedRiceCount = 0; // 临时 炒饭数量
  int tempCoinCount = 0; // 临时 一元硬币数量
  int tempDrinkCount = 0; // 临时 饮料数量
  int tempToppingCount = 0; // 临时 配料数量
  int tempLotteryCount = 0; // 临时 彩票数量

  @override
  void initState() {
    super.initState(); // 调用父类初始化方法
    _requestPermission(); // 请求存储权限
    loadBalance(); // 加载余额
    loadCounts(); // 加载各个项目的数量
  }

  // 请求存储权限的方法
  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) { // 请求存储权限
      print('Storage permission granted'); // 输出权限被授予
    } else {
      print('Storage permission denied'); // 输出权限被拒绝
    }
  }

  // 加载余额的方法
  Future<void> loadBalance() async {
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    setState(() {
      balance = prefs.getDouble('balance') ?? 0; // 从存储中读取余额
    });
  }

  // 加载各个项目数量的方法
  Future<void> loadCounts() async {
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    setState(() {
      g3Count = prefs.getInt('g3Count') ?? 0; // 从存储中读取 餃子3个 数量
      g6Count = prefs.getInt('g6Count') ?? 0; // 从存储中读取 餃子6个 数量
      friedRiceCount = prefs.getInt('friedRiceCount') ?? 0; // 从存储中读取 炒饭 数量
      coinCount = prefs.getInt('coinCount') ?? 0; // 从存储中读取 一元硬币 数量
      drinkCount = prefs.getInt('drinkCount') ?? 0; // 从存储中读取 饮料 数量
      toppingCount = prefs.getInt('toppingCount') ?? 0; // 从存储中读取 配料 数量
      lotteryCount = prefs.getInt('lotteryCount') ?? 0; // 从存储中读取 彩票 数量
    });
  }

  // 添加金额的方法
  Future<void> _addAmount(double amount, String menu) async {
    setState(() {
      balance += amount; // 增加余额
      _incrementCount(menu); // 增加对应项目的数量
    });
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setDouble('balance', balance); // 保存余额
    await _saveCounts(); // 保存数量
  }

  // 扣除金额的方法
  Future<void> _deductAmount(double amount, String menu) async {
    setState(() {
      balance -= amount; // 减少余额
      _decrementCount(menu); // 减少对应项目的数量
    });
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setDouble('balance', balance); // 保存余额
    await _saveCounts(); // 保存数量
  }

  // 保存数量的方法
  Future<void> _saveCounts() async {
    final prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setInt('g3Count', g3Count); // 保存 餃子3个 数量
    await prefs.setInt('g6Count', g6Count); // 保存 餃子6个 数量
    await prefs.setInt('friedRiceCount', friedRiceCount); // 保存 炒饭 数量
    await prefs.setInt('coinCount', coinCount); // 保存 一元硬币 数量
    await prefs.setInt('drinkCount', drinkCount); // 保存 饮料 数量
    await prefs.setInt('toppingCount', toppingCount); // 保存 配料 数量
    await prefs.setInt('lotteryCount', lotteryCount); // 保存 彩票 数量
  }

  // 增加数量的辅助方法
  void _incrementCount(String menu) {
    switch (menu) { // 根据菜单名称增加对应数量
      case 'g3':
        g3Count++; // 增加 餃子3个 数量
        break;
      case 'g6':
        g6Count++; // 增加 餃子6个 数量
        break;
      case 'friedRice':
        friedRiceCount++; // 增加 炒饭 数量
        break;
      case 'coin':
        coinCount++; // 增加 一元硬币 数量
        break;
      case 'drink':
        drinkCount++; // 增加 饮料 数量
        break;
      case 'topping':
        toppingCount++; // 增加 配料 数量
        break;
      case 'lottery':
        lotteryCount++; // 增加 彩票 数量
        break;
    }
  }

  // 扣除数量的辅助方法
  void _decrementCount(String menu) {
    switch (menu) { // 根据菜单名称减少对应数量
      case 'g3':
        if (g3Count > 0) g3Count--; // 保证数量不小于 0
        break;
      case 'g6':
        if (g6Count > 0) g6Count--; // 保证数量不小于 0
        break;
      case 'friedRice':
        if (friedRiceCount > 0) friedRiceCount--; // 保证数量不小于 0
        break;
      case 'coin':
        if (coinCount > 0) coinCount--; // 保证数量不小于 0
        break;
      case 'drink':
        if (drinkCount > 0) drinkCount--; // 保证数量不小于 0
        break;
      case 'topping':
        if (toppingCount > 0) toppingCount--; // 保证数量不小于 0
        break;
      case 'lottery':
        if (lotteryCount > 0) lotteryCount--; // 保证数量不小于 0
        break;
    }
  }

  @override
  void dispose() { // 被销毁时调用
    _receivedAmountController.dispose(); // 释放控制器
    _timer?.cancel(); // 取消定时器
    super.dispose(); // 调用父类的 dispose
  }

  // 导出到 Excel 的方法
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel(); // 创建 Excel 实例
    Sheet sheet = excel['Sheet1']; // 获取第一个工作表

    

    sheet.appendRow([ // 添加标题行
      TextCellValue('メニュー'), // 菜单
      TextCellValue('注文総数'), // 订单总数
      TextCellValue('金額'), // 金额
    ]);

    // 添加数据行
    sheet.appendRow([
      TextCellValue('餃子3個'), // 餃子3个
      IntCellValue(g3Count), // 订单总数
      DoubleCellValue(150 * g3Count.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('餃子6個'), // 餃子6个
      IntCellValue(g6Count), // 订单总数
      DoubleCellValue(250 * g6Count.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('炒飯'), // 炒饭
      IntCellValue(friedRiceCount), // 订单总数
      DoubleCellValue(300 * friedRiceCount.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('ワンコイン'), // 一元硬币
      IntCellValue(coinCount), // 订单总数
      DoubleCellValue(500 * coinCount.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('ドリンク'), // 饮料
      IntCellValue(drinkCount), // 订单总数
      DoubleCellValue(100 * drinkCount.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('トッピング'), // 配料
      IntCellValue(toppingCount), // 订单总数
      DoubleCellValue(100 * toppingCount.toDouble()), // 金额
    ]);

    sheet.appendRow([
      TextCellValue('100円くじ'), // 彩票
      IntCellValue(lotteryCount), // 订单总数
      DoubleCellValue(100 * lotteryCount.toDouble()), // 金额
    ]);

    sheet.appendRow([ // 添加总计行
      TextCellValue('合計'), // 合计
      IntCellValue(_calculateTotalOrderCount()), // 总订单数
      DoubleCellValue(_calculateTotalOrderAmount()), // 总金额
    ]);


    var fileBytes = excel.save();

    if (!kIsWeb && fileBytes != null) {
      String formattedDate = DateFormat('yyyyMMddHHmm').format(DateTime.now());
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String fileName = '統計データ$formattedDate.xlsx';
        String path = '${directory.path}/Download/$fileName';
        if (await Permission.storage.request().isGranted) {
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          _showDialog("ファイルルート: $path");
        } else {
          print('Storage permission denied.');
        }
      }
    } else if (kIsWeb) {
      String formattedDate = DateFormat('yyyyMMddHHmm').format(DateTime.now());
      excel.save(fileName: '統計データ$formattedDate.xlsx');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('データ保存しました'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  // 计算订单总数的方法
  int _calculateTotalOrderCount() {
    return g3Count +
        g6Count +
        friedRiceCount +
        coinCount +
        drinkCount +
        toppingCount +
        lotteryCount; // 返回总数量
  }

  // 计算订单总金额的方法
  double _calculateTotalOrderAmount() {
    return (g3Count * 150) +
        (g6Count * 250) +
        (friedRiceCount * 300) +
        (coinCount * 500) +
        (drinkCount * 100) +
        (toppingCount * 100) +
        (lotteryCount * 100); // 返回总金额
  }

  // 重置所有数据的方法
  void _resetAllData() async {
    setState(() {
      g3Count = g6Count = friedRiceCount =
          coinCount = drinkCount = toppingCount = lotteryCount = 0; // 重置所有计数
      balance = totalAmount = receivedAmount = 0; // 重置金额
    });

    SharedPreferences prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setDouble('balance', balance); // 保存余额
    await prefs.setInt('g3Count', g3Count); // 保存 餃子3个 数量
    await prefs.setInt('g6Count', g6Count); // 保存 餃子6个 数量
    await prefs.setInt('friedRiceCount', friedRiceCount); // 保存 炒饭 数量
    await prefs.setInt('coinCount', coinCount); // 保存 一元硬币 数量
    await prefs.setInt('drinkCount', drinkCount); // 保存 饮料 数量
    await prefs.setInt('toppingCount', toppingCount); // 保存 配料 数量
    await prefs.setInt('lotteryCount', lotteryCount); // 保存 彩票 数量
  }

  @override
  Widget build(BuildContext context) { // 构建 UI 的方法
    return DefaultTabController( // 使用默认的 TabController，管理选项卡
      length: 3, // 设置选项卡的数量
      child: MaterialApp( // 返回一个 Material App
        debugShowCheckedModeBanner: false, // 不显示调试模式横幅
        theme: ThemeData.dark(), // 设置主题为暗色模式
        home: Scaffold( // 返回一个脚手架组件
          appBar: AppBar( // 应用栏组件
            centerTitle: true, // 标题居中
            title: Text("学園祭会計app"), // 应用栏标题
            leading: IconButton( // 返回按钮
              icon: Icon(Icons.arrow_back), // 返回图标
              onPressed: () {
                Navigator.pop(context); // 返回上一个页面
              },
            ),
            bottom: TabBar( // TabBar 组件
              tabs: [ // 标签列表
                Tab(text: "注文"), // 订单标签
                Tab(text: "まとめ注文"), // 汇总订单标签
                Tab(text: "統計"), // 统计标签
              ],
              labelColor: Colors.yellow, // 选中标签颜色
            ),
          ),
          body: TabBarView( // TabBarView 组件，用于显示不同的内容
            children: [ // 标签对应的内容
              _buildAccountTab(), // 订单视图
              _buildPaymentTab(), // 汇总订单视图
              _buildMenuStatisticsTab(), // 统计视图
            ],
          ),
        ),
      ),
    );
  }

  // 构建订单视图的方法
  Widget _buildAccountTab() {
    return Container( // 返回容器组件
      padding: EdgeInsets.all(20), // 设置内边距
      color: Colors.black, // 背景颜色为黑色
      height: double.infinity, // 高度为无限大
      width: double.infinity, // 宽度为无限大
      child: Column( // 垂直排列子组件
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 主轴均匀分布
        children: [
          Text("営業収入:", style: TextStyle(fontSize: 27)), // 显示营业收入文本
          Text(
            '${NumberFormat.simpleCurrency().format(balance)}', // 显示余额
            style: TextStyle(fontSize: 24, color: Colors.white), // 设置文本样式
          ),
          Container(
            width: double.infinity, // 宽度为无限大
            child: Card( // 卡片组件
              child: Text(
                textAlign: TextAlign.center, // 文本居中
                'メニュー', // 菜单文本
                style: TextStyle(fontSize: 20, color: Colors.red), // 设置文本样式
              ),
              color: Colors.amberAccent.shade200, // 设置卡片背景颜色
            ),
          ),
          // 构建菜单项
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

  // 构建菜单项的方法
  Widget _buildMenuItem(String title, double price, String menu) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900), // 背景颜色
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子组件均匀分布
        children: [
          Text(title, style: TextStyle(fontSize: 20)), // 显示菜单项标题
          SizedBox(width: 5), // 添加间距
          Row(
            children: [
              ElevatedButton( // 增加数量按钮
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, padding: EdgeInsets.all(5)),
                onPressed: () => _addAmount(price, menu), // 添加金额和菜单项目
                child: Text("+1",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
              SizedBox(width: 5), // 添加间距
              ElevatedButton( // 减少数量按钮
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, padding: EdgeInsets.all(5)),
                onPressed: () => _deductAmount(price, menu), // 扣除金额和菜单项目
                child: Text("-1",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建统计视图的方法
  Widget _buildMenuStatisticsTab() {
    return SingleChildScrollView( // 使内容可滚动
      child: Column(
        children: [
          DataTable( // 数据表组件
            columns: [
              DataColumn(label: Text('メニュー')), // 菜单列
              DataColumn(label: Text('注文総数')), // 订单总数列
              DataColumn(label: Text('金額')), // 金额列
            ],
            rows: [ // 数据行
              DataRow(cells: [
                DataCell(Text('餃子3個')), // 菜单项
                DataCell(Text('$g3Count')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(150 * g3Count)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('餃子6個')), // 菜单项
                DataCell(Text('$g6Count')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(250 * g6Count)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('炒飯')), // 菜单项
                DataCell(Text('$friedRiceCount')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(300 * friedRiceCount)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('ワンコイン')), // 菜单项
                DataCell(Text('$coinCount')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(500 * coinCount)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('ドリンク')), // 菜单项
                DataCell(Text('$drinkCount')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * drinkCount)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('トッピング')), // 菜单项
                DataCell(Text('$toppingCount')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * toppingCount)}')), // 金额
              ]),
              DataRow(cells: [
                DataCell(Text('100円くじ')), // 菜单项
                DataCell(Text('$lotteryCount')), // 订单总数
                DataCell(Text('${NumberFormat.simpleCurrency().format(100 * lotteryCount)}')), // 金额
              ]),
            ],
          ),
          SizedBox(height: 20), // 添加间距
          Text(
            "注文総数: ${_calculateTotalOrderCount()}", // 显示总订单数
            style: TextStyle(fontSize: 18, color: Colors.blue), // 设置样式
          ),
          Text(
            "営業総金額: ${NumberFormat.simpleCurrency().format(_calculateTotalOrderAmount())}", // 显示总金额
            style: TextStyle(fontSize: 18, color: Colors.amberAccent), // 设置样式
          ),
          SizedBox(height: 20), // 添加间距
          Column(
            children: [
              ElevatedButton( // 导出到 Excel 按钮
                onPressed: _exportToExcel, // 导出方法
                child: Text('Excelファイルに出力',
                    style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 背景颜色
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 内边距
                ),
              ),
              SizedBox(height: 10), // 添加间距
              GestureDetector( // 手势检测器，支持长按操作
                onLongPressStart: (details) {
                  _timer = Timer(Duration(seconds: 3), () { // 长按三秒后重置数据
                    _resetAllData();
                  });
                },
                onLongPressEnd: (details) {
                  _timer?.cancel(); // 取消定时器
                },
                onLongPressCancel: () {
                  _timer?.cancel(); // 取消定时器
                },
                child: ElevatedButton( // 重置按钮
                  child: Text(
                    '長押し、システムをリセットする', // 显示文本
                    style: TextStyle(fontSize: 15, color: Colors.white), // 按钮文本样式
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // 背景颜色为红色
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10), // 内边距
                  ),
                  onPressed: () {}, // 按钮点击无操作
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建汇总订单视图的方法
  Widget _buildPaymentTab() {
    return SingleChildScrollView( // 使内容可滚动
      child: Container(
        padding: EdgeInsets.all(15), // 设置内边距
        child: Column(
          children: [
            Container(
              width: double.infinity, // 宽度为无限
              child: Card( // 卡片组件
                child: Text(
                  textAlign: TextAlign.center, // 文本居中
                  'メニュー', // 显示菜单文本
                  style: TextStyle(fontSize: 18, color: Colors.red), // 设置文本样式
                ),
                color: Colors.amberAccent.shade200, // 设置卡片背景颜色
              ),
            ),
            // 构建菜单选择器项
            _buildMenuSelector("餃子3個(150円)", 150, 'g3', tempG3Count),
            _buildMenuSelector("餃子6個(250円)", 250, 'g6', tempG6Count),
            _buildMenuSelector(
                "炒飯(300円)", 300, 'friedRice', tempFriedRiceCount),
            _buildMenuSelector("ワンコイン(500円)", 500, 'coin', tempCoinCount),
            _buildMenuSelector("ドリンク(100円)", 100, 'drink', tempDrinkCount),
            _buildMenuSelector("トッピング(100円)", 100, 'topping', tempToppingCount),
            _buildMenuSelector(
                "100円くじ(100円)", 100, 'lottery', tempLotteryCount),
            // 显示总金额
            Text("総金額: ${NumberFormat.simpleCurrency().format(totalAmount)}",
                style: TextStyle(fontSize: 20, color: Colors.yellow)),
            TextField( // 输入框组件
              textAlign: TextAlign.center, // 文本居中
              style: TextStyle(fontSize: 18), // 设置样式
              controller: _receivedAmountController, // 控制器
              decoration: InputDecoration(
                border: OutlineInputBorder(), // 边框
                hintText: '預かった金額を入力してください', // 提示文本
                hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 15), // 提示文本样式
              ),
              keyboardType: TextInputType.number, // 数字键盘
              onChanged: (value) {
                setState(() {
                  receivedAmount = double.tryParse(value) ?? 0; // 更新收到的金额
                });
              },
            ),
            Text(
              receivedAmount - totalAmount < 0
                  ? "金額不足" // 不足金额提示
                  : "お釣り: ${NumberFormat.simpleCurrency().format(receivedAmount - totalAmount)}", // 显示找零金额
              style: TextStyle(
                  fontSize: 20,
                  color: receivedAmount - totalAmount < 0
                      ? Colors.red // 不足金额显示为红色
                      : Colors.blue.shade300), // 找零金额显示为蓝色
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子组件均匀分布
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(4)), // 增加收入按钮
                  onPressed: () {
                    _addToBalance(); // 添加到余额
                    _clearTempCounts(); // 清空临时计数
                    _clearReceivedAmount(); // 清空收到金额
                  },
                  child: Text("営業収入に追加して、リセット",
                      style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本样式
                ),
                SizedBox(width: 10), // 添加间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, padding: EdgeInsets.all(5)), // 重置按钮
                  onPressed: () {
                    _clearTotalAmount(); // 清空总金额
                    _clearTempCounts(); // 清空临时计数
                    _clearReceivedAmount(); // 清空收到金额
                  },
                  child: Text("リセット",
                      style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本样式
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建菜单选择器的方法
  Widget _buildMenuSelector(
      String title, double price, String menu, int tempCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2), // 设置垂直方向的边距
      decoration: BoxDecoration(color: Colors.grey.shade900), // 背景颜色
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 15)), // 显示菜单项标题
          Spacer(), // 占位组件
          Text("数量: $tempCount"), // 显示数量
          SizedBox(width: 10), // 添加间距
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, padding: EdgeInsets.all(5)), // 加数量按钮
            onPressed: () {
              setState(() {
                _incrementTempCount(menu); // 增加临时数量
                totalAmount += price; // 增加总金额
              });
            },
            child:
            Text("+1", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
          SizedBox(width: 5), // 添加间距
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, padding: EdgeInsets.all(5)), // 减数量按钮
            onPressed: () {
              setState(() {
                _decrementTempCount(menu); // 减少临时数量
                totalAmount -= price; // 减少总金额
              });
            },
            child:
            Text("-1", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
        ],
      ),
    );
  }

  // 清空收到金额的方法
  void _clearReceivedAmount() {
    setState(() {
      receivedAmount = 0; // 清空收到金额
      _receivedAmountController.clear(); // 清空输入框
    });
  }

  // 清空临时计数的方法
  void _clearTempCounts() {
    setState(() {
      tempG3Count = 0; // 重置临时 餃子3个 计数
      tempG6Count = 0; // 重置临时 餃子6个 计数
      tempFriedRiceCount = 0; // 重置临时 炒饭 计数
      tempCoinCount = 0; // 重置临时 一元硬币 计数
      tempDrinkCount = 0; // 重置临时 饮料 计数
      tempToppingCount = 0; // 重置临时 配料 计数
      tempLotteryCount = 0; // 重置临时 彩票 计数
    });
  }

  // 添加金额到余额的方法
  void _addToBalance() async {
    setState(() {
      g3Count += tempG3Count; // 更新 餃子3个 的数量到总数
      g6Count += tempG6Count; // 更新 餃子6个 的数量到总数
      friedRiceCount += tempFriedRiceCount; // 更新 炒饭 的数量到总数
      coinCount += tempCoinCount; // 更新 一元硬币 的数量到总数
      drinkCount += tempDrinkCount; // 更新 饮料 的数量到总数
      toppingCount += tempToppingCount; // 更新 配料 的数量到总数
      lotteryCount += tempLotteryCount; // 更新 彩票 的数量到总数

      // 清空临时计数
      tempG3Count = 0;
      tempG6Count = 0;
      tempFriedRiceCount = 0;
      tempCoinCount = 0;
      tempDrinkCount = 0;
      tempToppingCount = 0;
      tempLotteryCount = 0;

      balance += totalAmount; // 将总金额加到余额上
      totalAmount = 0; // 清空总金额
      _receivedAmountController.clear(); // 清空输入框
    });

    await _saveCounts(); // 保存数量
    SharedPreferences prefs = await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    await prefs.setDouble('balance', balance); // 保存余额
  }

  // 清空总金额的方法
  void _clearTotalAmount() {
    setState(() {
      totalAmount = 0; // 清空总金额
      _receivedAmountController.clear(); // 清空输入框
      receivedAmount = 0; // 清空收到金额
    });
  }

  // 增加临时计数的方法
  void _incrementTempCount(String menu) {
    switch (menu) { // 根据菜单名称增加临时计数
      case 'g3':
        tempG3Count++; // 餃子3个数量 +1
        break;
      case 'g6':
        tempG6Count++; // 餃子6个数量 +1
        break;
      case 'friedRice':
        tempFriedRiceCount++; // 炒饭数量 +1
        break;
      case 'coin':
        tempCoinCount++; // 一元硬币数量 +1
        break;
      case 'drink':
        tempDrinkCount++; // 饮料数量 +1
        break;
      case 'topping':
        tempToppingCount++; // 配料数量 +1
        break;
      case 'lottery':
        tempLotteryCount++; // 彩票数量 +1
        break;
    }
  }

  // 减少临时计数的方法
  void _decrementTempCount(String menu) {
    switch (menu) { // 根据菜单名称减少临时计数
      case 'g3':
        if (tempG3Count > 0) tempG3Count--; // 餃子3个数量 -1，但不小于 0
        break;
      case 'g6':
        if (tempG6Count > 0) tempG6Count--; // 餃子6个数量 -1，但不小于 0
        break;
      case 'friedRice':
        if (tempFriedRiceCount > 0) tempFriedRiceCount--; // 炒饭数量 -1，但不小于 0
        break;
      case 'coin':
        if (tempCoinCount > 0) tempCoinCount--; // 一元硬币数量 -1，但不小于 0
        break;
      case 'drink':
        if (tempDrinkCount > 0) tempDrinkCount--; // 饮料数量 -1，但不小于 0
        break;
      case 'topping':
        if (tempToppingCount > 0) tempToppingCount--; // 配料数量 -1，但不小于 0
        break;
      case 'lottery':
        if (tempLotteryCount > 0) tempLotteryCount--; // 彩票数量 -1，但不小于 0
        break;
    }
  }
}
