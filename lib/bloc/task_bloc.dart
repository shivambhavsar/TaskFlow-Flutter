import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

/// TaskBloc — the core business logic handler.
///
/// ANDROID EQUIVALENT: This is your ViewModel.
///
/// In Android MVVM:
///   class TaskViewModel : ViewModel() {
///     private val _uiState = MutableStateFlow(TaskUiState())
///     val uiState: StateFlow<TaskUiState> = _uiState
///
///     fun addTask(task: Task) {
///       _uiState.update { it.copy(tasks = it.tasks + task) }
///     }
///   }
///
/// In BLoC, instead of methods, you register EVENT HANDLERS:
///   on<AddTask>((event, emit) {
///     emit(state.copyWith(tasks: [...state.tasks, event.task]));
///   });
///
/// KEY DIFFERENCES FROM VIEWMODEL:
/// 1. Events are processed SEQUENTIALLY (no concurrency bugs)
/// 2. Every state change goes through emit() (single source of truth)
/// 3. Bloc automatically disposes when removed from widget tree
///    (no need for onCleared() or viewModelScope)

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  // super() sets the initial state — like initial value of MutableStateFlow
  TaskBloc() : super(const TaskState(isLoading: true)) {
    // Register handlers for each event type
    // This is like a big `when(event)` block in Kotlin
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
    on<UndoDelete>(_onUndoDelete);
    on<ChangeFilter>(_onChangeFilter);
  }

  /// Load initial tasks.
  /// In a real app, this would call a repository to fetch from DB/API.
  /// For now, we use dummy data.
  ///
  /// `emit()` = pushes a new state to all listeners (like StateFlow.emit())
  /// `state`  = the current state (like _uiState.value)
  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    // Simulate loading with dummy data
    final dummyTasks = [
      Task.create(
        title: 'Learn BLoC pattern',
        description: 'Events, States, and Bloc',
        priority: TaskPriority.high,
      ),
      Task.create(
        title: 'Build TaskFlow with BLoC',
        description: 'Refactor from setState to Bloc',
        priority: TaskPriority.medium,
      ),
      Task.create(
        title: 'Add local storage',
        description: 'Persist tasks with SQLite or Hive',
        priority: TaskPriority.low,
      ),
    ];

    emit(state.copyWith(tasks: dummyTasks, isLoading: false));
  }

  /// Add a new task at the beginning of the list.
  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    final updatedTasks = [event.task, ...state.tasks];
    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Update an existing task (from detail screen edits).
  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.map((t) {
      return t.id == event.task.id ? event.task : t;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Toggle completion by task ID.
  /// We find by ID instead of index — more robust if list order changes.
  void _onToggleTask(ToggleTask event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.map((t) {
      return t.id == event.taskId ? t.toggleComplete() : t;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Delete a task by ID.
  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Undo delete — re-insert at original position.
  void _onUndoDelete(UndoDelete event, Emitter<TaskState> emit) {
    final updatedTasks = List<Task>.from(state.tasks);
    final safeIndex = event.index.clamp(0, updatedTasks.length);
    updatedTasks.insert(safeIndex, event.task);
    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Change the active filter.
  void _onChangeFilter(ChangeFilter event, Emitter<TaskState> emit) {
    emit(state.copyWith(filter: event.filter));
  }
}
