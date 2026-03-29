import 'package:flutter/material.dart';
import 'package:kantankanri/pages/jobPage/calendarView/calendar.dart';
import 'package:kantankanri/pages/jobPage/job_page.dart';
import 'package:kantankanri/pages/jobPage/staff_page.dart';
import 'package:kantankanri/pages/managementTools/account.dart';
import 'package:kantankanri/pages/managementTools/management_tools.dart';
import 'package:kantankanri/pages/managementTools/note.dart';
import 'package:kantankanri/pages/managementTools/schoolFestivalAccount.dart';
import 'package:kantankanri/pages/managementTools/timer.dart';
import 'package:kantankanri/pages/othersApplication/dicee.dart';
import 'package:kantankanri/pages/othersApplication/futureVision/quizzler.dart';
import 'package:kantankanri/pages/othersApplication/others_application.dart';
import 'package:kantankanri/pages/othersApplication/randomPerson.dart';
import 'package:kantankanri/pages/othersApplication/testPage.dart';
import 'package:kantankanri/pages/othersApplication/testPage2.dart';
import 'package:kantankanri/pages/othersApplication/todo_page.dart';
import 'package:kantankanri/pages/othersApplication/Xylophone.dart';
import 'package:kantankanri/app/home_page.dart';
import 'package:kantankanri/screens/login_screen.dart';

/// 名前付きルートを一箇所で管理する
Map<String, WidgetBuilder> buildAppRoutes() {
  return {
    '/login': (_) => const LoginScreen(),
    '/home': (_) => const HomePage(),
    '/job': (_) => JobPage(),
    '/staff': (_) => StaffPage(),
    '/management_tools': (_) => management_tools(),
    '/note': (_) => note(),
    '/timer': (_) => timer(),
    '/todo': (_) => const todo_page(),
    '/account': (_) => accounting(),
    '/schoolFestivalAccount': (_) => SchoolFestivalAccount(),
    '/calendar': (_) => calendar(),
    '/othersApplication': (_) => othersApplication(),
    '/testpage': (_) => testPage(),
    '/testpage2': (_) => testPage2(),
    '/draw': (_) => RandomPersonPickerPage(),
    '/dicee': (_) => DicePage(),
    '/piano': (_) => XylophoneApp(),
    '/futureVision': (_) => Quizzler(),
  };
}
