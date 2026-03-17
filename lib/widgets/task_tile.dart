import 'package:flutter/material.dart';
import '../models/task.dart';

/// TaskTile — a reusable widget for displaying a single task.
///
/// KEY CONCEPT: Custom Widgets
/// In Android, this would be a custom View or RecyclerView ViewHolder.
/// In Flutter, you extract reusable UI into separate Widget classes.
///
/// This is StatelessWidget because it doesn't hold its own state.
/// All data comes from the parent via constructor params (like props in React).
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;    // Function type — like () -> Unit in Kotlin
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// Dismissible = Swipe-to-delete (like ItemTouchHelper in RecyclerView)
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      child: ListTile(
        // Checkbox on the left
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
          shape: const CircleBorder(),
        ),

        // Task title — with strikethrough if completed
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),

        // Description subtitle (if exists)
        subtitle: task.description != null
            ? Text(
                task.description!,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey.shade400 : Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,

        // Delete button on the right
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: onDelete,
          color: Colors.grey,
        ),
      ),
    );
  }
}
