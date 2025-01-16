import 'package:flutter/material.dart'; // 导入 flutter/material.dart 包，提供 Material Design 组件

import '../../extension.dart'; // 导入扩展方法文件
import '../../widgets/day_view_widget.dart'; // 导入日视图 Widget
import '../../widgets/month_view_widget.dart'; // 导入月视图 Widget
import '../../widgets/week_view_widget.dart'; // 导入周视图 Widget
import '../create_event_page.dart'; // 导入创建事件页面

// 创建 MobileHomePage 类，继承 StatelessWidget
class MobileHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // 使用默认的 TabController，管理选项卡
      length: 3, // 设置选项卡的数量
      child: Scaffold( // 返回一个脚手架组件
        floatingActionButton: FloatingActionButton( // 浮动操作按钮
          child: Icon(Icons.add), // 按钮图标为添加图标
          elevation:5, // 设置按钮阴影高度
          onPressed: () => context.pushRoute(CreateEventPage()), // 按钮点击时跳转到创建事件页面
        ),
        appBar: AppBar( // 应用栏组件
          bottom: PreferredSize( // 设置自定义的底部高度
            preferredSize: Size.fromHeight(0), // 设置 TabBar 的高度为 0
            child: TabBar( // TabBar 组件
              indicatorSize: TabBarIndicatorSize.tab, // 指示器大小设置为标签大小
              labelColor: Colors.red, // 选中标签的颜色
              unselectedLabelColor: Colors.green, // 未选中标签的颜色
              tabs: [ // 标签列表
                Tab(text: "月"), // 月视图标签
                Tab(text: "週"), // 周视图标签
                Tab(text: "日"), // 日视图标签
              ],
            ),
          ),
          centerTitle: true, // 应用栏标题居中
        ),
        body: TabBarView( // TabBarView 组件，展示选项卡的内容
          children: [
            MonthViewWidget(), // 月视图组件
            WeekViewWidget(), // 周视图组件
            DayViewWidget() // 日视图组件
          ],
        ),
      ),
    );
  }
}
