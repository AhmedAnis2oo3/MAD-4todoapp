class Todo {
  int id;
  String title;
  String description;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isDone: json['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "isDone": isDone,
    };
  }
}