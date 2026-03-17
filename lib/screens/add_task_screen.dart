import 'package:flutter/material.dart';
import '../models/task.dart';

/// AddTaskScreen — a dedicated screen for creating a new task.
///
/// NAVIGATION CONCEPT:
/// In Android: startActivityForResult() or Navigation Component with result
/// In Flutter: Navigator.push() returns a Future, so the previous screen
///             can `await` the result.
///
/// FORM CONCEPT:
/// Flutter uses Form + GlobalKey<FormState> for validation,
/// similar to Android's TextInputLayout validation.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // GlobalKey gives us access to FormState for validation
  // Like Android's form.validate() pattern
  final _formKey = GlobalKey<FormState>();

  // Controllers — manage text field state
  // IMPORTANT: Always dispose controllers to avoid memory leaks!
  // Same concept as closing Closeable resources in Kotlin
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Track selected priority
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    // LIFECYCLE: dispose() is called when the widget is removed from the tree
    // Like onDestroy() in Android Activity
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // validate() calls each TextFormField's validator function
    if (_formKey.currentState!.validate()) {
      final newTask = Task.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
      );

      // Pop this screen and return the new task to the previous screen
      // Like setResult(RESULT_OK, intent) + finish() in Android
      Navigator.of(context).pop(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          // Save button in the app bar
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
      ),

      /// LAYOUT CONCEPTS:
      /// - Padding: adds space around a widget (like android:padding)
      /// - Column: vertical layout (like LinearLayout vertical)
      /// - SizedBox: fixed-size spacer (like Space in Compose)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task_alt),
                ),
                // Validator — returns error string or null if valid
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null; // null = valid
                },
                // Submit on Enter
                onFieldSubmitted: (_) => _submitForm(),
              ),

              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add some details...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              // Priority selector
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              /// SegmentedButton — Material 3 toggle group
              /// Like Android's MaterialButtonToggleGroup
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
                  setState(() => _priority = selected.first);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
