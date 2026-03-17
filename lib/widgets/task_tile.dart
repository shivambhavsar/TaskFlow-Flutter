import 'package:flutter/material.dart';
import '../models/task.dart';

/// TaskTile — updated with priority indicator and tap-to-navigate.
///
/// NEW CONCEPTS:
/// - Container decoration for priority color strip
/// - GestureDetector / InkWell for tap handling
/// - Composed widgets (building complex UI from simple pieces)
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;     // NEW: navigate to detail

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  /// Get color based on priority
  Color _priorityColor(BuildContext context) {
    return switch (task.priority) {
      // Dart 3 switch expression — cleaner than Kotlin's when!
      TaskPriority.high => Colors.red.shade400,
      TaskPriority.medium => Colors.orange.shade400,
      TaskPriority.low => Colors.green.shade400,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),

      /// IntrinsicHeight + Row pattern:
      /// We use this to make the priority color strip match the tile height.
      ///
      /// Row = horizontal layout (like LinearLayout horizontal)
      /// IntrinsicHeight forces children to match the tallest child's height
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Priority color strip on the left edge
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // The actual list tile — Expanded fills remaining width
            // Like layout_weight="1" in Android
            Expanded(
              child: ListTile(
                onTap: onTap,  // Navigate to detail screen
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle(),
                  shape: const CircleBorder(),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted ? Colors.grey : null,
                    fontWeight: task.priority == TaskPriority.high
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: task.description != null
                    ? Text(
                        task.description!,
                        style: TextStyle(
                          color: task.isCompleted
                              ? Colors.grey.shade400
                              : Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
