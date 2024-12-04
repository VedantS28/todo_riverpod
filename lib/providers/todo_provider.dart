import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/models/todo.dart';

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState());

  void addTodo(Todo todo) {
    state = state.copyWith(
      activeTodos: [...state.activeTodos, todo],
    );
  }

  void completeTodo(Todo todo) {
    final updatedTodo = todo.copyWith(
      isCompleted: true,
      completionDate: DateTime.now(),
    );

    state = state.copyWith(
      activeTodos: state.activeTodos.where((t) => t != todo).toList(),
      completedTodos: [...state.completedTodos, updatedTodo],
    );
  }

  void restoreTodo(Todo todo) {
    final updatedTodo = todo.copyWith(
      isCompleted: false,
      completionDate: null,
    );

    state = state.copyWith(
      completedTodos: state.completedTodos.where((t) => t != todo).toList(),
      activeTodos: [...state.activeTodos, updatedTodo],
    );
  }

  void updateTodoPriority(Todo todo, Priority priority) {
    final updatedTodos = state.activeTodos.map((t) {
      if (t == todo) {
        return t.copyWith(priority: priority);
      }
      return t;
    }).toList();

    state = state.copyWith(activeTodos: updatedTodos);
  }

  void deleteTodo(Todo todo) {
    if (todo.isCompleted) {
      state = state.copyWith(
        completedTodos: state.completedTodos.where((t) => t != todo).toList(),
      );
    } else {
      state = state.copyWith(
        activeTodos: state.activeTodos.where((t) => t != todo).toList(),
      );
    }
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});
