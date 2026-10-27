import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'viewmodels/home_view_model.dart';
import 'views/home/home_view.dart';

class EduGuardApp extends StatelessWidget {
  const EduGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: HomeView(viewModel: HomeViewModel()),
    );
  }
}
