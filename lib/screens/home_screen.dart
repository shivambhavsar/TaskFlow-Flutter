import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/task.dart';
import '../models/detail_result.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

/// HomeScreen — refactored from StatefulWidget to use BLoC.
///
/// BEFORE (Phase 2):
///   - StatefulWidget with setState()
///   - All business logic lived HERE (add, delete, toggle)
///   - State was local to this widget
///
/// AFTER (Phase 3):
///   - StatelessWidget! (no local state needed)
///   - Business logic moved to TaskBloc
///   - UI just reads state and sends events
///
/// ANDROID COMPARISON:
///   Before: Activity doing everything (God Activity anti-pattern)
///   After:  Activity observes ViewModel, calls ViewModel methods
///
/// KEY BLOC WIDGETS:
///   BlocBuilder  = rebuilds UI when state changes  (like collectAsState in Compose)
///   BlocListener = side effects (snackbar, navigate) WITHOUT rebuilding
///   BlocConsumer = both builder + listener in one widget
///
/// READING THE BLOC:
///   context.read<TaskBloc>()   = get Bloc instance, NO rebuild on change
///                                (use in callbacks: onPressed, onTap)
///   context.watch<TaskBloc>()  = get Bloc AND rebuild when state changes
///                                (use in build methods)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        actions: [
          // BlocBuilder rebuilds ONLY this widget when state changes
          // Like observing a specific LiveData field
          BlocBuilder<TaskBloc, TaskState>(
            // buildWhen — optimization! Only rebuild when pendingCount changes.
            // Like Kotlin Flow's distinctUntilChanged()
            buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
            builder: (context, state) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${state.pendingCount} pending',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      /// BlocConsumer = BlocBuilder + BlocListener combined.
      ///
      /// - builder: rebuilds UI when state changes (like BlocBuilder)
      /// - listener: runs side effects that should NOT cause rebuilds
      ///            (snackbars, navigation, showing dialogs)
      ///
      /// Android equivalent: observing LiveData where the observer
      /// both updates UI AND triggers one-shot events.
      body: BlocConsumer<TaskBloc, TaskState>(
        // listener handles one-shot side effects
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          // Loading state
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (state.tasks.isEmpty) {
            return Center(
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
            );
          }

          // Task list with filter chips
          return Column(
            children: [
              // Filter chips row
              _FilterChips(currentFilter: state.filter),

              // Task list
              Expanded(
                child: _TaskList(state: state),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  /// Navigation still lives in the screen — it's a UI concern.
  /// But the DATA changes go through the Bloc.
  Future<void> _navigateToAddTask(BuildContext context) async {
    final newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    if (newTask != null && context.mounted) {
      // Send event to Bloc instead of setState
      // context.read<TaskBloc>() = get the Bloc without subscribing
      context.read<TaskBloc>().add(AddTask(newTask));
    }
  }
}

/// Filter chips — extracted as a separate widget for clarity.
///
/// WIDGET EXTRACTION: In Flutter, it's idiomatic to break the UI
/// into small, focused widgets. Each widget has a single responsibility.
/// This is like extracting a custom View or @Composable function.
class _FilterChips extends StatelessWidget {
  final TaskFilter currentFilter;

  const _FilterChips({required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.name[0].toUpperCase() + filter.name.substring(1)),
              selected: isSelected,
              onSelected: (_) {
                // Send filter change event to Bloc
                context.read<TaskBloc>().add(ChangeFilter(filter));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Task list widget — displays filtered tasks with section headers.
class _TaskList extends StatelessWidget {
  final TaskState state;

  const _TaskList({required this.state});

  @override
  Widget build(BuildContext context) {
    final tasks = state.filteredTasks;
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (pending.isNotEmpty) ...[
          _sectionHeader(context, 'Pending', pending.length, false),
          ...pending.map((task) => _buildTaskTile(context, task)),
        ],
        if (completed.isNotEmpty) ...[
          _sectionHeader(context, 'Completed', completed.length, true),
          ...completed.map((task) => _buildTaskTile(context, task)),
        ],
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task) {
    return TaskTile(
      task: task,
      // Send events to Bloc — no setState anywhere!
      onToggle: () => context.read<TaskBloc>().add(ToggleTask(task.id)),
      onDelete: () => _deleteWithUndo(context, task),
      onTap: () => _navigateToDetail(context, task),
    );
  }

  void _deleteWithUndo(BuildContext context, Task task) {
    final index = state.tasks.indexOf(task);
    context.read<TaskBloc>().add(DeleteTask(task.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // UndoDelete event restores the task at its original position
            context.read<TaskBloc>().add(UndoDelete(task, index));
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _navigateToDetail(BuildContext context, Task task) async {
    final result = await Navigator.of(context).push<DetailResult>(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );

    if (result == null || !context.mounted) return;

    switch (result) {
      case TaskUpdated(:final task):
        context.read<TaskBloc>().add(UpdateTask(task));
      case TaskDeleted():
        context.read<TaskBloc>().add(DeleteTask(task.id));
    }
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
