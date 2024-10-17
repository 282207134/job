import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SchoolFestivalAccount extends StatefulWidget {
  @override
  _SchoolFestivalAccountState createState() => _SchoolFestivalAccountState();
}

class _SchoolFestivalAccountState extends State<SchoolFestivalAccount> {
  double balance = 0; // 总营业收入
  int g3Count = 0; // 记录菜单“餃子3個”的购买次数
  int g6Count = 0; // 记录菜单“餃子6個”的购买次数
  int friedRiceCount = 0; // 记录菜单“炒飯”的购买次数
  int coinCount = 0; // 记录菜单“ワンコイン”的购买次数
  int drinkCount = 0; // 记录菜单“ドリンク”的购买次数
  int toppingCount = 0; // 记录菜单“トッピング”的购买次数
  int lotteryCount = 0; // 记录菜单“100円くじ”的购买次数

  double totalAmount = 0; // 选择的菜单总金额
  double receivedAmount = 0; // 收到的金额

  final TextEditingController _receivedAmountController = TextEditingController(); // 控制输入框内容的controller

  @override
  void initState() {
    super.initState();
    loadBalance(); // 初始化时加载总营业收入
  }

  Future<void> loadBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('balance') ?? 0; // 获取储存的总营业收入
    });
  }

  Future<void> _addAmount(double amount, String menu) async {
    setState(() {
      balance += amount; // 增加金额到余额
      _incrementCount(menu); // 增加该菜单的计数
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance); // 保存数据到本地
  }

  Future<void> _deductAmount(double amount, String menu) async {
    setState(() {
      balance -= amount; // 减少金额从余额
      _decrementCount(menu); // 减少该菜单的计数
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance); // 保存数据到本地
  }

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

  @override
  void dispose() {
    _receivedAmountController.dispose(); // 释放输入框的controller资源
    super.dispose();
  }

  int _calculateTotalOrderCount() {
    return g3Count + g6Count + friedRiceCount + coinCount + drinkCount + toppingCount + lotteryCount; // 计算总订单数
  }

  double _calculateTotalOrderAmount() {
    return (g3Count * 150) +
        (g6Count * 250) +
        (friedRiceCount * 300) +
        (coinCount * 500) +
        (drinkCount * 100) +
        (toppingCount * 100) +
        (lotteryCount * 100); // 计算总金额
  }

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
                Tab(text: "注文",), // 第一个 Tab
                Tab(text: "まとめ注文"), // 第二个 Tab
                Tab(text: "統計"), // 第三个 Tab
              ],
              labelColor: Colors.yellow, // 设置选中标签的颜色
            ),
          ),
          body: TabBarView(
            children: [
              _buildAccountTab(), // 账户Tab
              _buildPaymentTab(), // 收款与找零Tab
              _buildMenuStatisticsTab(), // 菜单统计Tab
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return Container(
      padding: EdgeInsets.all(20), // 使用20像素的整体内边距
      color: Colors.blueGrey.shade900, // 设置背景颜色
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
          Container(width: double.infinity,
            child: Card(
              child: Text(textAlign: TextAlign.center,
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

  Widget _buildMenuItem(String title, double price, String menu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // 垂直对齐于末端
      children: [
        Text(title, style: TextStyle(fontSize: 20)), // 菜单项名称
        SizedBox(width: 5), // 增加5像素的水平间距
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // 按钮背景颜色
              padding: EdgeInsets.all(5)), // 按钮内边距
          onPressed: () => _addAmount(price, menu), // 点击增加金额
          child: Text("+1", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
        ),
        SizedBox(width: 5), // 增加5像素的水平间距
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // 按钮背景颜色
              padding: EdgeInsets.all(5)), // 按钮内边距
          onPressed: () => _deductAmount(price, menu), // 点击减少金额
          child: Text("-1", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
        ),
      ],
    );
  }

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
                DataCell(Text('餃子3個')), // 行数据
                DataCell(Text('$g3Count')), // 显示“餃子3個”的计数
                DataCell(Text('${NumberFormat.simpleCurrency().format(150 * g3Count)}')), // 格式化后的金额
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
          SizedBox(height: 20), // 增加20像素的垂直间距
          Text(
            "注文総数: ${_calculateTotalOrderCount()}", // 显示总订单数量
            style: TextStyle(fontSize: 18, color: Colors.blue), // 设置文本样式
          ),
          Text(
            "営業総金額: ${NumberFormat.simpleCurrency().format(_calculateTotalOrderAmount())}", // 显示总金额
            style: TextStyle(fontSize: 18, color: Colors.amberAccent), // 设置文本样式
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20), // 设置20像素的内边距
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(width: double.infinity,
              child: Card(
                child: Text(textAlign: TextAlign.center,
                  'メニュー', // 显示菜单
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
                color: Colors.amberAccent.shade200, // 设置背景颜色
              ),
            ),
            _buildMenuSelector("餃子3個(150円)", 150, 'g3', g3Count), // 构建菜单选择器“餃子3個”
            _buildMenuSelector("餃子6個(250円)", 250, 'g6', g6Count), // 构建菜单选择器“餃子6個”
            _buildMenuSelector("炒飯(300円)", 300, 'friedRice', friedRiceCount), // 构建菜单选择器“炒飯”
            _buildMenuSelector("ワンコイン(500円)", 500, 'coin', coinCount), // 构建菜单选择器“ワンコイン”
            _buildMenuSelector("ドリンク(100円)", 100, 'drink', drinkCount), // 构建菜单选择器“ドリンク”
            _buildMenuSelector("トッピング(100円)", 100, 'topping', toppingCount), // 构建菜单选择器“トッピング”
            _buildMenuSelector("100円くじ(100円)", 100, 'lottery', lotteryCount), // 构建菜单选择器“100円くじ”
            Text("総金額: ${NumberFormat.simpleCurrency().format(totalAmount)}", // 显示总金额
                style: TextStyle(fontSize: 25, color: Colors.yellow)), // 设置文本样式
            TextField(textAlign: TextAlign.center, // 输入框
              style: TextStyle(fontSize: 20), // 设置输入框文本大小
              controller: _receivedAmountController, // 绑定controller
              decoration: InputDecoration(
                border: OutlineInputBorder(), // 设置输入框边框
                hintText: '預かった金額を入力してください', // 输入框标签
                hintStyle: TextStyle(color: Colors.grey.shade700,fontSize: 17),
                // 设置输入框标签样式
              ),
              keyboardType: TextInputType.number, // 输入框键盘类型
              onChanged: (value) {
                setState(() {
                  receivedAmount = double.tryParse(value) ?? 0; // 解析输入的金额
                });
              },
            ),
            Text(
              receivedAmount - totalAmount < 0 ? "金額不足" : "お釣り: ${NumberFormat.simpleCurrency().format(receivedAmount - totalAmount)}", // 根据金额显示文字
              style: TextStyle(fontSize: 25, color: receivedAmount - totalAmount < 0 ? Colors.red : Colors.blue), // 设置文本样式
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 子元素之间的间距相等
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, padding: EdgeInsets.all(5)), // 按钮样式
                  onPressed: _addToBalance, // 点击增加到余额
                  child: Text("営業収入に追加して、リセット", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
                ),
                SizedBox(width: 10), // 增加10像素的水平间距
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, padding: EdgeInsets.all(5)), // 按钮样式
                  onPressed: _clearTotalAmount, // 点击清空金额
                  child: Text("リセット", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelector(String title, double price, String menu, int count) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 15)), // 显示菜单项名称
        Spacer(),
        Text("数量: $count"), // 显示购买数量
        SizedBox(width: 10),
        SizedBox(
          width: 35,
          height: 35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.all(5)), // 按钮样式
            onPressed: () {
              setState(() {
                _incrementCount(menu); // 增加计数
                totalAmount += price; // 增加总金额
              });
            },
            child: Text("+", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 35,
          height: 35,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.all(5)), // 按钮样式
            onPressed: () {
              setState(() {
                _decrementCount(menu); // 减少计数
                totalAmount -= (price * (count > 0 ? 1 : 0)); // 减少总金额
              });
            },
            child: Text("-", style: TextStyle(fontSize: 15, color: Colors.white)), // 按钮文本
          ),
        ),
      ],
    );
  }

  void _addToBalance() {
    setState(() {
      balance += totalAmount; // 增加到总营业收入
      totalAmount = 0; // 清零总金额
      _receivedAmountController.clear(); // 清空預かった金額输入框

      // 清零所有计数器
      g3Count = 0;
      g6Count = 0;
      friedRiceCount = 0;
      coinCount = 0;
      drinkCount = 0;
      toppingCount = 0;
      lotteryCount = 0;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('balance', balance); // 保存数据到本地
    });
  }

  void _clearTotalAmount() {
    setState(() {
      totalAmount = 0; // 清零总金额
      _receivedAmountController.clear(); // 清空預かった金額输入框

      // 清零所有计数器
      g3Count = 0;
      g6Count = 0;
      friedRiceCount = 0;
      coinCount = 0;
      drinkCount = 0;
      toppingCount = 0;
      lotteryCount = 0;
    });
  }
}
