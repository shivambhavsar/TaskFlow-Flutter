import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/detail_result.dart';

/// TaskDetailScreen — view and edit a single task.
///
/// PASSING DATA BETWEEN SCREENS:
/// In Android: intent.putExtra("task", task) or SafeArgs
/// In Flutter: pass data via constructor params! Much simpler.
///
/// This screen receives a Task and returns an updated Task (or null if deleted).
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late bool _isCompleted;

  // Track if user made changes (for save confirmation)
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // initState() = like onCreate() in Android
    // `late` keyword means "I promise to initialize before first use"
    // `widget.task` accesses the Task passed from the parent widget
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        isCompleted: _isCompleted,
      );
      // Return TaskUpdated — clearly distinguishes from delete/cancel
      Navigator.of(context).pop(TaskUpdated(updated));
    }
  }

  void _deleteTask() {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();       // close dialog
              Navigator.of(context).pop(TaskDeleted()); // explicit delete signal
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// WillPopScope alternative in newer Flutter — handles back button
  /// Like onBackPressed() in Android
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true; // no changes, allow back

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // PopScope replaces WillPopScope (deprecated)
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTask,
              color: colorScheme.error,
            ),
            TextButton(
              onPressed: _saveAndPop,
              child: const Text('Save'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            // onChanged fires whenever any field in the form changes
            onChanged: () => setState(() => _hasChanges = true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion toggle — prominent at the top
                Card(
                  child: SwitchListTile(
                    title: Text(
                      _isCompleted ? 'Completed' : 'In Progress',
                      style: TextStyle(
                        color: _isCompleted ? Colors.green : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    secondary: Icon(
                      _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: _isCompleted ? Colors.green : colorScheme.primary,
                    ),
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Priority
                Text('Priority', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: Text('Low'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text('Medium'),
                      icon: Icon(Icons.remove),
                    ),
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: Text('High'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _priority = selected.first;
                      _hasChanges = true;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Created date — read-only info
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Created'),
                    subtitle: Text(
                      _formatDate(widget.task.createdAt),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
