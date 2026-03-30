import 'package:flutter/material.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/jobPage/job_page.dart';
import 'package:kantankanri/pages/jobPage/staff_page.dart';
import 'package:kantankanri/pages/othersApplication/todo_page.dart';
import 'package:kantankanri/app/home_page.dart';
import 'package:kantankanri/screens/login_screen.dart';

/// 名前付きルートを一箇所で管理する
Map<String, WidgetBuilder> buildAppRoutes() {
  return {
    '/login': (_) => const LoginScreen(),
    '/home': (_) => const HomePage(),
    '/job': (_) => JobPage(),
    '/staff': (_) => StaffPage(),
    '/todo': (_) => const todo_page(),
    '/calendar': (_) => calendar(),
  };
}
