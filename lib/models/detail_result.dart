import '../models/task.dart';

/// Navigation result from TaskDetailScreen.
///
/// SEALED CLASS — just like Kotlin's sealed class!
/// Dart 3 added this. It enables exhaustive switch/when checking.
///
/// The problem we're solving:
///   Before:  pop(Task) = updated, pop(null) = deleted OR cancelled (ambiguous!)
///   After:   pop(TaskUpdated) vs pop(TaskDeleted) vs back press (no result)
///
/// In Kotlin, you'd write:
///   sealed class DetailResult {
///     data class Updated(val task: Task) : DetailResult()
///     object Deleted : DetailResult()
///   }
sealed class DetailResult {}

class TaskUpdated extends DetailResult {
  final Task task;
  TaskUpdated(this.task);
}

class TaskDeleted extends DetailResult {}
