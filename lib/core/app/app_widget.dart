// File: lib/core/app/app_widget.dart

import 'package:flutter/material.dart';
import 'root_widget.dart';

class NeuralBreakApp extends StatelessWidget {
  const NeuralBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Break',

      // Use dark theme with custom primary color
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.blue),
      ),

      // Load the RootWidget when the app starts
      home: const NeuralBreakRoot(),

      // Hide the debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}
