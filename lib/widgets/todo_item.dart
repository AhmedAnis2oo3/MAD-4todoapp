import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration:
                todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(todo.description),
        ),
        trailing: Checkbox(
          value: todo.isDone,
          activeColor: Colors.indigo,
          onChanged: (_) => onToggle(),
        ),
      ),
    );
  }
}