import 'package:flutter/material.dart'; // 导入 Flutter Material Design 组件库
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart'; // 导入日历页面
import 'package:kantankanri/pages/jobPage/job_page.dart'; // 导入工作页面
import 'package:kantankanri/pages/jobPage/staff_page.dart'; // 导入员工页面
import 'package:kantankanri/pages/othersApplication/todo_page.dart'; // 导入待办事项页面
import 'package:kantankanri/app/home_page.dart'; // 导入主页
import 'package:kantankanri/screens/login_screen.dart'; // 导入登录屏幕

/// 集中管理命名路由
Map<String, WidgetBuilder> buildAppRoutes() { // 构建应用路由表的函数
  return { // 返回路由映射表
    '/login': (_) => const LoginScreen(), // 登录页面路由
    '/home': (_) => const HomePage(), // 主页路由
    '/job': (_) => JobPage(), // 工作页面路由
    '/staff': (_) => StaffPage(), // 员工页面路由
    '/todo': (_) => const todo_page(), // 待办事项页面路由
    '/calendar': (_) => calendar(), // 日历页面路由
  };
}
