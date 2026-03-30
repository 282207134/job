import 'package:flutter/material.dart';

import '../../../../services/holiday_service.dart';

class HolidaySettingsSheet extends StatefulWidget {
  const HolidaySettingsSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const HolidaySettingsSheet(),
    );
  }

  @override
  State<HolidaySettingsSheet> createState() => _HolidaySettingsSheetState();
}

class _HolidaySettingsSheetState extends State<HolidaySettingsSheet> {
  Set<String> _countries = <String>{HolidayService.jp};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = await HolidayService.getSelectedCountries();
    if (!mounted) return;
    setState(() {
      _countries = c;
      _loading = false;
    });
  }

  Future<void> _toggle(String country, bool selected) async {
    final next = {..._countries};
    if (selected) {
      next.add(country);
    } else {
      next.remove(country);
    }
    setState(() => _countries = next);
    await HolidayService.setSelectedCountries(next);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: _loading
          ? const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '节日设置',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _countries.contains(HolidayService.jp),
                  onChanged: (v) => _toggle(HolidayService.jp, v ?? false),
                  title: const Text('日本祝日'),
                ),
                CheckboxListTile(
                  value: _countries.contains(HolidayService.cn),
                  onChanged: (v) => _toggle(HolidayService.cn, v ?? false),
                  title: const Text('中国节日'),
                ),
              ],
            ),
    );
  }
}
