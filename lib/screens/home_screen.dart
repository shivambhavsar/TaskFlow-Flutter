import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

/// HomeScreen — our main screen showing the task list.
///
/// This is a StatefulWidget because it holds mutable state (the task list).
///
/// ANATOMY OF A STATEFULWIDGET:
/// 1. The Widget class itself (immutable config — like XML layout in Android)
/// 2. The State class (mutable state + build logic — like Activity/Fragment)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Our task list — starts with some dummy data
  final List<Task> _tasks = [
    Task.create(title: 'Learn Flutter widgets', description: 'Rows, Columns, Stacks'),
    Task.create(title: 'Build TaskFlow UI', description: 'Home screen with task list'),
    Task.create(title: 'Add state management', description: 'Provider or Riverpod'),
  ];

  /// Add a new task
  void _addTask(String title) {
    setState(() {
      // setState() tells Flutter: "state changed, rebuild UI"
      // Similar to LiveData.postValue() or MutableState in Compose
      _tasks.insert(0, Task.create(title: title));
    });
  }

  /// Toggle task completion
  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].toggleComplete();
    });
  }

  /// Delete a task
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  /// Show dialog to add a new task
  void _showAddTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What needs to be done?',
            border: OutlineInputBorder(),
          ),
          // Submit on Enter key
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTask(value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addTask(controller.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Separate completed and pending tasks
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    final completed = _tasks.where((t) => t.isCompleted).toList();

    /// WIDGET TREE CONCEPT:
    /// Scaffold → AppBar + Body + FAB
    ///   └── Body: ListView
    ///         └── TaskTile (repeated)
    ///
    /// Think of it like nested XML layouts, but in code.
    return Scaffold(
      // AppBar — like Toolbar in Android
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
      ),

      // Body — the main content area
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Pending tasks
                if (pending.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Pending (${pending.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  ...pending.map((task) {
                    final index = _tasks.indexOf(task);
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTask(index),
                      onDelete: () => _deleteTask(index),
                    );
                  }),
                ],

                // Completed tasks
                if (completed.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Completed (${completed.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  ...completed.map((task) {
                    final index = _tasks.indexOf(task);
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTask(index),
                      onDelete: () => _deleteTask(index),
                    );
                  }),
                ],
              ],
            ),

      // FAB — Floating Action Button, same concept as Android
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
