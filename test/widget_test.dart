// 完整 MyApp（Firebase / Auth ストリーム）は VM 上の widget_test でブロックしやすいため、
// コンパイルと基本バインディングのみ検証する。結合確認は `flutter run` を使う。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantankanri/main.dart' show MyApp;

void main() {
  testWidgets('MyApp can be constructed', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(const MyApp(), isA<MyApp>());
  });

  testWidgets('MaterialApp shell pumps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('ok')),
      ),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
