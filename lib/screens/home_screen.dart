import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/detail_result.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

/// HomeScreen — now with NAVIGATION!
///
/// NAVIGATION IN FLUTTER vs ANDROID:
/// Android: NavController + NavGraph (declarative destinations)
/// Flutter: Navigator + Route (imperative push/pop stack)
///
/// Navigator works like a Stack:
///   push()  → add screen on top  (like startActivity)
///   pop()   → remove top screen  (like finish() or back press)
///   push() returns a Future, so you can await results from the next screen!
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [
    Task.create(
      title: 'Learn Flutter widgets',
      description: 'Rows, Columns, Stacks',
      priority: TaskPriority.high,
    ),
    Task.create(
      title: 'Build TaskFlow UI',
      description: 'Home screen with task list',
      priority: TaskPriority.medium,
    ),
    Task.create(
      title: 'Add state management',
      description: 'Provider or Riverpod',
      priority: TaskPriority.low,
    ),
  ];

  /// Navigate to AddTaskScreen and wait for the result.
  ///
  /// NAVIGATION PATTERN:
  /// 1. push() a new MaterialPageRoute (creates a new screen)
  /// 2. The new screen calls pop(result) when done
  /// 3. We get the result back here via await
  ///
  /// This is like startActivityForResult() but MUCH cleaner!
  Future<void> _navigateToAddTask() async {
    // push() returns whatever the pushed screen passes to pop()
    final newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    // If user cancelled (pressed back), newTask is null
    if (newTask != null) {
      setState(() => _tasks.insert(0, newTask));
    }
  }

  /// Navigate to TaskDetailScreen to view/edit a task.
  Future<void> _navigateToDetail(int index) async {
    final result = await Navigator.of(context).push<DetailResult>(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: _tasks[index]),
      ),
    );

    // result is null ONLY on back press (cancelled) — do nothing!
    // Sealed class gives us exhaustive checking, just like Kotlin's `when`
    if (result == null) return; // ← back pressed, task stays untouched

    setState(() {
      switch (result) {
        case TaskUpdated(:final task):
          _tasks[index] = task;
        case TaskDeleted():
          _tasks.removeAt(index);
      }
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].toggleComplete();
    });
  }

  void _deleteTask(int index) {
    // Save reference for undo
    final deleted = _tasks[index];
    setState(() => _tasks.removeAt(index));

    // SNACKBAR — like Android's Snackbar with undo action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deleted.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _tasks.insert(index, deleted));
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    final completed = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        actions: [
          // Task count badge
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${pending.length} pending',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'No tasks yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (pending.isNotEmpty) ...[
                  _sectionHeader(context, 'Pending', pending.length, false),
                  ...pending.map((task) {
                    final index = _tasks.indexOf(task);
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTask(index),
                      onDelete: () => _deleteTask(index),
                      onTap: () => _navigateToDetail(index),
                    );
                  }),
                ],
                if (completed.isNotEmpty) ...[
                  _sectionHeader(context, 'Completed', completed.length, true),
                  ...completed.map((task) {
                    final index = _tasks.indexOf(task);
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTask(index),
                      onDelete: () => _deleteTask(index),
                      onTap: () => _navigateToDetail(index),
                    );
                  }),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    int count,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isCompleted
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
