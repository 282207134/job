import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kantankanri/pages/jobPage/calendarView/src/calendar_event_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HolidayService {
  HolidayService._();

  static const String _countriesKey = 'holiday_country_codes';
  static const String jp = 'JP';
  static const String cn = 'CN';
  static final ValueNotifier<int> selectionVersion = ValueNotifier<int>(0);
  static Set<String> _selectedCountriesCache = <String>{jp};
  static final Set<String> _importingYearCountry = <String>{};

  static Future<Set<String>> getSelectedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_countriesKey);
    if (list == null) {
      _selectedCountriesCache = <String>{jp};
      return _selectedCountriesCache;
    }
    final valid = list.where((e) => e == jp || e == cn).toSet();
    _selectedCountriesCache = valid;
    return _selectedCountriesCache;
  }

  static Set<String> get selectedCountriesSnapshot => _selectedCountriesCache;

  static Future<void> setSelectedCountries(Set<String> countries) async {
    final valid = countries.where((e) => e == jp || e == cn).toSet();
    final next = valid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_countriesKey, next.toList());
    _selectedCountriesCache = next;
    selectionVersion.value++;
  }

  static String countryLabel(String code) {
    switch (code) {
      case cn:
        return '中国节日';
      case jp:
      default:
        return '日本祝日';
    }
  }

  static bool isHolidayEventData(CalendarEventData event) {
    if ((event.id ?? '').startsWith('holiday_')) return true;
    final raw = event.event;
    if (raw is Map) {
      return raw['source'] == 'holiday_api' || raw['country_code'] != null;
    }
    return false;
  }

  static String? holidayCountryOf(CalendarEventData event) {
    final raw = event.event;
    if (raw is Map && raw['country_code'] != null) {
      return '${raw['country_code']}';
    }
    final id = event.id ?? '';
    if (id.startsWith('holiday_jp_')) return jp;
    if (id.startsWith('holiday_cn_')) return cn;
    return null;
  }

  static bool shouldShowHolidayEvent(CalendarEventData event) {
    if (!isHolidayEventData(event)) return true;
    final code = holidayCountryOf(event);
    if (code == null) return true;
    return _selectedCountriesCache.contains(code);
  }

  static Future<List<_HolidayItem>> _fetchHolidays({
    required int year,
    required String countryCode,
  }) async {
    final uri = Uri.parse(
      'https://date.nager.at/api/v3/PublicHolidays/$year/$countryCode',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('节日 API 请求失败: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    if (data is! List) return const [];
    return data.map<_HolidayItem>((e) {
      final m = e as Map<String, dynamic>;
      return _HolidayItem(
        date: DateTime.parse('${m['date']}'),
        localName: '${m['localName'] ?? m['name'] ?? 'Holiday'}',
        englishName: '${m['name'] ?? m['localName'] ?? 'Holiday'}',
      );
    }).toList();
  }

  static String _slug(String s) {
    final lower = s.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return cleaned.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  }

  static String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  /// 导入指定国家某年节日到 events 集合（幂等）
  static Future<int> importYearHolidays({
    required int year,
    required String country,
  }) async {
    final list = await _fetchHolidays(year: year, countryCode: country);
    if (list.isEmpty) return 0;

    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    var i = 0;
    for (final h in list) {
      final day = DateTime(h.date.year, h.date.month, h.date.day);
      var slug = _slug(h.localName);
      if (slug.isEmpty) slug = 'holiday-$i';
      final id = 'holiday_${country.toLowerCase()}_${_ymd(day)}_$slug';
      final ref = db.collection('events').doc(id);
      batch.set(ref, {
        'title': h.localName,
        'description': '${countryLabel(country)}: ${h.englishName}',
        'date': Timestamp.fromDate(day),
        'endDate': Timestamp.fromDate(day),
        'startTime': null,
        'endTime': null,
        'color': country == cn ? 0xFFE53935 : 0xFF1E88E5,
        'source': 'holiday_api',
        'country_code': country,
        'holiday_key': '${country}_${_ymd(day)}_${h.localName}',
      }, SetOptions(merge: true));
      i++;
    }
    await batch.commit();
    return list.length;
  }

  /// 切换月份时自动补齐所选国家的该年节日
  static Future<void> ensureMonthHolidays(DateTime month) async {
    final countries = await getSelectedCountries();
    final year = month.year;
    for (final c in countries) {
      final key = '${c}_$year';
      if (_importingYearCountry.contains(key)) continue;
      _importingYearCountry.add(key);
      try {
        await importYearHolidays(year: year, country: c);
      } finally {
        _importingYearCountry.remove(key);
      }
    }
  }
}

class _HolidayItem {
  const _HolidayItem({
    required this.date,
    required this.localName,
    required this.englishName,
  });

  final DateTime date;
  final String localName;
  final String englishName;
}
