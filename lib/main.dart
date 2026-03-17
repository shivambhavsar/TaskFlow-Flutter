import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'screens/home_screen.dart';

/// Entry point — like `fun main()` in Kotlin
/// runApp() takes a Widget and makes it the root of the widget tree.
void main() {
  runApp(const TaskFlowApp());
}

/// Root widget of our app.
///
/// BLOCPROVIDER — the dependency injection point.
///
/// Android equivalent: this is like Hilt's @HiltAndroidApp + ViewModelProvider.
/// BlocProvider creates the Bloc and makes it available to ALL descendants
/// via BuildContext (remember context chaining from our earlier discussion!).
///
/// Widget tree:
///   BlocProvider<TaskBloc>     ← creates & holds the Bloc instance
///     └── MaterialApp
///           └── HomeScreen    ← can access TaskBloc via context.read<TaskBloc>()
///                 └── TaskTile  ← can also access it! (context chains up)
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // create: is called once — like ViewModelProvider.Factory
      // The Bloc lives as long as this widget is in the tree
      create: (context) => TaskBloc()..add(LoadTasks()),
      //                              ^^
      // Dart cascade operator (..) — calls add() and returns the Bloc.
      // Like Kotlin's apply { add(LoadTasks()) }
      // This fires LoadTasks immediately after creation.

      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.light,
        ),

        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),

        themeMode: ThemeMode.system,

        home: const HomeScreen(),
      ),
    );
  }
}
