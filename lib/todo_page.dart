import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/todo.dart';

import 'providers/todo_provider.dart';

class TodoPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<Priority, Color> priorityColors = {
    Priority.high: Colors.red[100]!,
    Priority.medium: Colors.orange[100]!,
    Priority.low: Colors.green[100]!,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final groupedTodos = groupByDate(todoState.activeTodos);
    final groupedCompletedTodos = groupByDate(todoState.completedTodos);

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Active Tasks'),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${todoState.activeTodos.length}'),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Completed'),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${todoState.completedTodos.length}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTodoList(groupedTodos),
            _buildTodoList(groupedCompletedTodos, isCompleted: true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        label: Text('Add Task'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList(Map<DateTime, List<Todo>> grouped,
      {bool isCompleted = false}) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        DateTime date = grouped.keys.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                DateFormat('EEEE, MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ...grouped[date]!.map((todo) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: isCompleted
                      ? _buildCompletedTodoItem(todo)
                      : _buildTodoItem(todo),
                )),
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Dismissible(
      key: Key(todo.title + todo.dueDate.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(todoProvider.notifier).deleteTodo(todo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(todoProvider.notifier).addTodo(todo);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: priorityColors[todo.priority]!,
                width: 6,
              ),
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (bool? value) {
                if (value ?? false) {
                  ref.read(todoProvider.notifier).completeTodo(todo);
                  _tabController.animateTo(1);
                }
              },
            ),
            title: Text(
              todo.title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(todo.dueDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: DropdownButton<Priority>(
              value: todo.priority,
              underline: Container(),
              icon: Icon(Icons.flag, color: priorityColors[todo.priority]),
              items: Priority.values.map((Priority priority) {
                return DropdownMenuItem<Priority>(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(Icons.flag,
                          color: priorityColors[priority], size: 20),
                      SizedBox(width: 8),
                      Text(priority.toString().split('.').last),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Priority? newValue) {
                if (newValue != null) {
                  ref
                      .read(todoProvider.notifier)
                      .updateTodoPriority(todo, newValue);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedTodoItem(Todo todo) {
    return Dismissible(
      key: Key(todo.title + todo.completionDate.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(todoProvider.notifier).deleteTodo(todo);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Completed task deleted'),
          ),
        );
      },
      child: ListTile(
        leading: IconButton(
          icon: Icon(Icons.restore),
          onPressed: () {
            ref.read(todoProvider.notifier).restoreTodo(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(decoration: TextDecoration.lineThrough),
        ),
        subtitle: Text(
          'Completed: ${DateFormat('MMM dd, yyyy').format(todo.completionDate!)}',
        ),
      ),
    );
  }

  Map<DateTime, List<Todo>> groupByDate(List<Todo> todoList) {
    Map<DateTime, List<Todo>> grouped = {};
    for (var todo in todoList) {
      DateTime date = DateTime(
        todo.dueDate.year,
        todo.dueDate.month,
        todo.dueDate.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(todo);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  void _addTodo() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    DateTime dueDate = DateTime.now();
    Priority priority = Priority.medium;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      title = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Due Date', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setState) => InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            dueDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        child: Text(DateFormat('MMM dd, yyyy').format(dueDate)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Priority', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  DropdownButtonFormField<Priority>(
                    value: priority,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (Priority? newValue) {
                      if (newValue != null) {
                        setState(() {
                          priority = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  ref.read(todoProvider.notifier).addTodo(
                        Todo(
                          title: title,
                          dueDate: dueDate,
                          priority: priority,
                        ),
                      );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
