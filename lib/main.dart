import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Entry point — like `fun main()` in Kotlin
/// runApp() takes a Widget and makes it the root of the widget tree.
void main() {
  runApp(const TaskFlowApp());
}

/// Root widget of our app.
///
/// KEY CONCEPT: Everything in Flutter is a Widget.
/// - StatelessWidget = doesn't hold mutable state (like a Compose function with no remember{})
/// - StatefulWidget  = holds mutable state (like a Compose function with remember{})
///
/// MaterialApp is Flutter's equivalent of Android's Theme + Navigation host.
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,

      // Theme — like Material Theme in Android
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,   // primary color family
        useMaterial3: true,               // Material 3 / Material You
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      // Follows system dark mode setting
      themeMode: ThemeMode.system,

      home: const HomeScreen(),
    );
  }
}
