import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BarberSyncApp());
}

class BarberSyncApp extends StatelessWidget {
  const BarberSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
