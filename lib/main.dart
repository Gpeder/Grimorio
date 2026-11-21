import 'package:flutter/material.dart';
import 'package:grimorio/home/home.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(const GrimorioApp());
}

class GrimorioApp extends StatelessWidget {
  const GrimorioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grimório RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const Home(),
    );
  }
}
