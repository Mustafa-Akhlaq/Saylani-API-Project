import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smit/Model/todo_model.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  List<TodoModel> todos = [];
  List<TodoModel> filteredTodos = [];
  String _sortOption = 'Low to High';
  String _filterOption = 'All';

  Future<void> fetchTasks() async {
    String url = "https://api.todoist.com/rest/v2/tasks";
    var uri = Uri.parse(url);
    String apiToken = "f68d4a8d4741cb90934db7cb967dafe182f337b9";
    var response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      List<TodoModel> fetchedTodos = [];
      var body = jsonDecode(response.body);
      for (var map in body) {
        var todoObj = TodoModel.fromJson(map);
        fetchedTodos.add(todoObj);
      }
      setState(() {
        todos = fetchedTodos;
        _sortAndFilterTasks();
      });
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  void _sortAndFilterTasks() {
    if (_filterOption == 'All') {
      filteredTodos = List.from(todos);
    } else {
      int filterPriority = int.parse(_filterOption);
      filteredTodos =
          todos.where((task) => task.priority == filterPriority).toList();
    }

    if (_sortOption == 'Low to High') {
      filteredTodos.sort((a, b) => a.priority!.compareTo(b.priority!));
    } else if (_sortOption == 'High to Low') {
      filteredTodos.sort((a, b) => b.priority!.compareTo(a.priority!));
    }
  }

  Future<void> addTask(String content, int priority) async {
    String url = "https://api.todoist.com/rest/v2/tasks";
    var uri = Uri.parse(url);
    String apiToken = "f68d4a8d4741cb90934db7cb967dafe182f337b9";
    var response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'priority': priority,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchTasks();
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<void> deleteTask(String id) async {
    String url = "https://api.todoist.com/rest/v2/tasks/$id";
    var uri = Uri.parse(url);
    String apiToken = "f68d4a8d4741cb90934db7cb967dafe182f337b9";
    var response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 204) {
      fetchTasks();
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  Future<void> updateTask(String id, String content, int priority) async {
    String url = "https://api.todoist.com/rest/v2/tasks/$id";
    var uri = Uri.parse(url);
    String apiToken = "f68d4a8d4741cb90934db7cb967dafe182f337b9";
    var response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'priority': priority,
      }),
    );

    if (response.statusCode == 204) {
      fetchTasks();
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

  void _showAddTaskDialog() {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController priorityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Task Content"),
              ),
              TextField(
                controller: priorityController,
                decoration: const InputDecoration(labelText: "Priority (1-4)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String content = contentController.text;
                int priority = int.parse(priorityController.text);
                addTask(content, priority);
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(TodoModel task) {
    final TextEditingController contentController =
        TextEditingController(text: task.content);
    final TextEditingController priorityController =
        TextEditingController(text: task.priority.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Task Content"),
              ),
              TextField(
                controller: priorityController,
                decoration: const InputDecoration(labelText: "Priority (1-4)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String updatedContent = contentController.text;
                int updatedPriority = int.parse(priorityController.text);
                updateTask(task.id!, updatedContent, updatedPriority);
                Navigator.of(context).pop();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[200],
        actions: [
          DropdownButton<String>(
            value: _sortOption,
            onChanged: (String? newValue) {
              setState(() {
                _sortOption = newValue!;
                _sortAndFilterTasks();
              });
            },
            items: <String>['Low to High', 'High to Low']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(
            width: 150,
          ),
          DropdownButton<String>(
            value: _filterOption,
            onChanged: (String? newValue) {
              setState(() {
                _filterOption = newValue!;
                _sortAndFilterTasks();
              });
            },
            items: <String>['All', '1', '2', '3', '4']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Text(value == 'All' ? 'All Priorities' : 'Priority $value'),
              );
            }).toList(),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = filteredTodos[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Text(todo.id.toString()),
              title: Text(todo.content ?? 'No Title'),
              subtitle: Text('Priority: ${todo.priority}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditTaskDialog(todo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(todo.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(
          Icons.add,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
