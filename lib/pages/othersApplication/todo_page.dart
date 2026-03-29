import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoEntry {
  TodoEntry({required this.title, required this.done});

  final String title;
  final bool done;

  Map<String, dynamic> toJson() => {'title': title, 'done': done};

  factory TodoEntry.fromJson(Map<String, dynamic> json) => TodoEntry(
        title: json['title'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );
}

/// ローカル保存のシンプルな Todo 一覧
class todo_page extends StatefulWidget {
  const todo_page({super.key});

  @override
  State<todo_page> createState() => _todo_pageState();
}

class _todo_pageState extends State<todo_page> {
  static const _prefsKey = 'todo_items_v1';
  final TextEditingController _controller = TextEditingController();
  final List<TodoEntry> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(
            decoded.map(
              (e) => TodoEntry.fromJson(Map<String, dynamic>.from(e as Map)),
            ),
          );
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.insert(0, TodoEntry(title: text, done: false));
      _controller.clear();
    });
    _save();
  }

  void _toggle(int index) {
    setState(() {
      final e = _items[index];
      _items[index] = TodoEntry(title: e.title, done: !e.done);
    });
    _save();
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '新しいタスク',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                  ),
                ),
                IconButton(
                  onPressed: _add,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'タスクがありません',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.done,
                            onChanged: (_) => _toggle(index),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item.done ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
