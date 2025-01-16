import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class note extends StatefulWidget {
  const note({Key? key}) : super(key: key);

  @override
  State<note> createState() => _noteState();
}

class _noteState extends State<note> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadnotes();
  }

  Future<void> _loadnotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? notes = prefs.getStringList('notes');
    if (notes != null) {
      setState(() {
        _notes.addAll(notes);
      });
    }
  }

  Future<void> _savenotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
  }

  void _addnote() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _notes.add(_textController.text.trim());
        _textController.clear();
        _savenotes();
      });
    }
  }

  void _deletenote(int index) {
    setState(() {
      _notes.removeAt(index);
      _savenotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ノート'),
      ),
      body: Container(
        color: Colors.yellow.shade100,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'メモを入力してください',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addnote,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deletenote(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
