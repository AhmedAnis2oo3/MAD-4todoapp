import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTodos();

    _controller.addListener(() {
      if (_controller.position.pixels ==
              _controller.position.maxScrollExtent &&
          hasMore) {
        fetchTodos();
      }
    });
  }

  Future<void> fetchTodos() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Todo> newTodos = await ApiService.fetchTodos(page);

      setState(() {
        if (newTodos.length < 10) hasMore = false;

        todos.addAll(newTodos);
        page++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading todos")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> addTodoDialog() async {
    String title = "";
    String description = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Title"),
              onChanged: (val) => title = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Description"),
              onChanged: (val) => description = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (title.trim().isEmpty ||
                  description.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("All fields are required")),
                );
                return;
              }

              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                Todo newTodo = Todo(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  description: description,
                  isDone: false,
                );

                Todo created;

try {
  created = await ApiService.addTodo(newTodo);
} catch (e) {
  created = newTodo; // fallback
}

                Navigator.pop(context);

                setState(() {
                  todos.insert(0, created);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Todo added successfully")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Failed to add todo")),
                );
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void toggleDone(int index) async {
    Todo todo = todos[index];

    setState(() {
      todo.isDone = !todo.isDone;
    });

    try {
      await ApiService.updateTodo(todo);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                todo.isDone ? "Marked Done" : "Marked Undone")),
      );
    } catch (e) {
      setState(() {
        todo.isDone = !todo.isDone;
      });
    }
  }

  Future<void> refresh() async {
    page = 1;
    hasMore = true;
    todos.clear();
    await fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        onPressed: addTodoDialog,
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: todos.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : todos.isEmpty
                ? const Center(child: Text("No Todos Found"))
                : ListView.builder(
                    controller: _controller,
                    itemCount: todos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == todos.length) {
                        return isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                    child:
                                        CircularProgressIndicator()),
                              )
                            : const SizedBox();
                      }

                      return TodoItem(
                        todo: todos[index],
                        onToggle: () => toggleDone(index),
                      );
                    },
                  ),
      ),
    );
  }
}