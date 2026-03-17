/// Priority enum — like Kotlin enum class
/// Dart 3 enums can have fields and methods, just like Kotlin!
enum TaskPriority {
  low('Low', 0),
  medium('Medium', 1),
  high('High', 2);

  final String label;
  final int value;

  const TaskPriority(this.label, this.value);
}

/// Task model — the core data class for TaskFlow.
class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
  });

  factory Task.create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
  }) {
    final now = DateTime.now();
    return Task(
      // microseconds gives us much finer granularity than milliseconds,
      // plus hashCode of the title adds extra uniqueness
      id: '${now.microsecondsSinceEpoch}_${title.hashCode.abs()}',
      title: title,
      description: description,
      priority: priority,
      createdAt: now,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Task toggleComplete() => copyWith(isCompleted: !isCompleted);

  @override
  String toString() => 'Task(id: $id, title: $title, done: $isCompleted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == id &&
          other.title == title &&
          other.description == description &&
          other.isCompleted == isCompleted &&
          other.priority == priority &&
          other.createdAt == createdAt);

  @override
  int get hashCode => Object.hash(id, title, description, isCompleted, priority, createdAt);
}