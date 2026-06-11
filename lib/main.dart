import 'package:flutter/material.dart';
import 'package:wills_generic_app/app/app_shell.dart';

void main() {
  runApp(const GenericApp());
}

class GenericApp extends StatelessWidget {
  const GenericApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generic App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
