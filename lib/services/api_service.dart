import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  static const String baseUrl = "https://apimocker.com/todos";

  // GET TODOS
  static Future<List<Todo>> fetchTodos(int page) async {
    final response =
        await http.get(Uri.parse("$baseUrl?page=$page&limit=10"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  // ADD TODO
  static Future<Todo> addTodo(Todo todo) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      // 🔥 fallback (API didn’t save)
      return todo;
    }
  } catch (e) {
    // 🔥 fallback (API failed completely)
    return todo;
  }
}
  // UPDATE TODO
  static Future<void> updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse("$baseUrl/${todo.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update todo");
    }
  }
}