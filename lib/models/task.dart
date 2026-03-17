/// Task model — the core data class for TaskFlow.
///
/// In Kotlin, this would be a `data class`.
/// Dart doesn't auto-generate equals/hashCode/copy,
/// so we do it manually (or use the `equatable` package later).
class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;

  // Dart shorthand constructor — `this.` auto-assigns fields
  // In Kotlin: class Task(val id: String, val title: String, ...)
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Named constructor — factory for quick creation
  // No Kotlin equivalent; closest is companion object factory
  factory Task.create({required String title, String? description}) {
    return Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  // copyWith — Kotlin data classes get this for free
  // In Dart, we write it manually
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Toggle convenience method
  Task toggleComplete() => copyWith(isCompleted: !isCompleted);

  @override
  String toString() => 'Task(id: $id, title: $title, done: $isCompleted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
