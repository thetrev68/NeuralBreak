// file: lib/main.dart

// Flutter package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports
import 'core/app/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NeuralBreakApp());
}
