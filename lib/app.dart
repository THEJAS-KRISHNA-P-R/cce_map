import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'ui/screens/map_screen.dart';

/// Main application widget
class CceMapApp extends StatelessWidget {
  const CceMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MapScreen(),
    );
  }
}
