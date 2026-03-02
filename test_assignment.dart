import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TaskMasterApp());

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      home: const TheRoyalCourt(),
    );
  }
}

class TheRoyalCourt extends StatefulWidget {
  const TheRoyalCourt({super.key});

  @override
  State<TheRoyalCourt> createState() => _TheRoyalCourtState();
}

class _TheRoyalCourtState extends State<TheRoyalCourt> {
  final String _realmUrl = "https://jsonplaceholder.typicode.com/posts";
  List<dynamic> _scrolls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    summonAllScrolls();
  }

  // 1. GET - Sob data niye asha
  Future<void> summonAllScrolls() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(_realmUrl));
      if (response.statusCode == 200) {
        setState(() {
          _scrolls = json.decode(response.body);
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. POST - Notun task jog kora
  Future<void> proclaimNewTask() async {
    final response = await http.post(
      Uri.parse(_realmUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": "NEW TASK", "body": "Assignment Task", "userId": 1}),
    );

    if (response.statusCode == 201) {
      setState(() {
        _scrolls.insert(0, {"id": 101, "title": "NEW TASK", "body": "Assignment Task"});
      });
      _showMessenger("✨ Created! Status: 201");
    }
  }

  // 3. PUT - Edit kora (IMPORTANT FIX)
  Future<void> rectifyScroll(int id, int index) async {
    final response = await http.put(
      Uri.parse('$_realmUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "title": "EDITED TITLE", "body": "Updated content"}),
    );

    // API success hole amra local list-eo change kore dibo
    if (response.statusCode == 200) {
      setState(() {
        _scrolls[index]['title'] = "EDITED TITLE";
        _scrolls[index]['body'] = "Updated content";
      });
      _showMessenger("🛠️ Edited! Status: 200");
    }
  }

  // 4. DELETE - Muche phela (IMPORTANT FIX)
  Future<void> banishTask(int id, int index) async {
    final response = await http.delete(Uri.parse('$_realmUrl/$id'));

    // API success hole list theke remove kore dibo
    if (response.statusCode == 200) {
      setState(() {
        _scrolls.removeAt(index);
      });
      _showMessenger("⚔️ Deleted! Status: 200");
    }
  }

  void _showMessenger(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏰 Task Master CRUD"), backgroundColor: Colors.amber),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _scrolls.length > 10 ? 10 : _scrolls.length,
        itemBuilder: (context, index) {
          final scroll = _scrolls[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.amber),
              title: Text(scroll['title'].toString().toUpperCase()),
              subtitle: Text(scroll['body']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => rectifyScroll(scroll['id'], index), // Pass index
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => banishTask(scroll['id'], index), // Pass index
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: proclaimNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}