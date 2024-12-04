enum Priority { low, medium, high }

class Todo {
  final String title;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final DateTime? completionDate;

  Todo({
    required this.title,
    required this.dueDate,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.completionDate,
  });

  Todo copyWith({
    String? title,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    DateTime? completionDate,
  }) {
    return Todo(
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
    );
  }
}

class TodoState {
  final List<Todo> activeTodos;
  final List<Todo> completedTodos;

  TodoState({
    this.activeTodos = const [],
    this.completedTodos = const [],
  });

  TodoState copyWith({
    List<Todo>? activeTodos,
    List<Todo>? completedTodos,
  }) {
    return TodoState(
      activeTodos: activeTodos ?? this.activeTodos,
      completedTodos: completedTodos ?? this.completedTodos,
    );
  }
}
