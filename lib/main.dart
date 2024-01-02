import 'package:flutter/material.dart';

import 'view/screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AqwaMarq',
      themeMode: ThemeMode.system,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF448AFF))),
      home: HomeScreen(),
    );
  }
}
