import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/role_select_screen.dart';

void main() {
  runApp(const StacktApp());
}

class StacktApp extends StatelessWidget {
  const StacktApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stackt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bone,
        primaryColor: AppColors.forestGreen,
        useMaterial3: true,
      ),
      home: const RoleSelectScreen(),
    );
  }
}
