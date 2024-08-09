import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class accounting extends StatefulWidget {
  @override
  _accountingState createState() => _accountingState();
}

class _accountingState extends State<accounting> {
  double balance = 0;
  final TextEditingController _customValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBalance(); // Load the balance when the widget is initialized
  }

  Future<void> _addAmount(double amount) async {
    setState(() {
      balance += amount;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
  }

  Future<void> _deductAmount(double amount) async {
    setState(() {
      balance -= amount;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);
  }

  Future<void> loadBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('balance') ?? 0;
    });
  }

  @override
  void dispose() {
    _customValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("会計app"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // 设置返回图标
            onPressed: () {
              Navigator.pop(context); // 返回上一个页面
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          color: Colors.blueGrey.shade700,
          height: double.infinity,
          width: double.infinity,
          child: Column(


                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("営業収入:"),
                  SizedBox(height: 50),
                  Text(
                    '${NumberFormat.simpleCurrency().format(balance)}',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _addAmount(100),
                        child: Text("残高 +100"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => _deductAmount(100),
                        child: Text("残高 -100"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _addAmount(300),
                        child: Text("残高 +300"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => _deductAmount(300),
                        child: Text("残高 -300"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _addAmount(500),
                        child: Text("残高 +500"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => _deductAmount(500),
                        child: Text("残高 -500"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        child: TextField(
                          controller: _customValueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'カスタム値',
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          double value =
                              double.tryParse(_customValueController.text) ?? 0;
                          _addAmount(value);
                        },
                        child: Text("+"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          double value =
                              double.tryParse(_customValueController.text) ?? 0;
                          _deductAmount(value);
                        },
                        child: Text("-"),
                      ),
                    ],
                  ),
                ],
              ),

          ),
        ),

    );
  }
}
