import 'package:flutter/material.dart';
import 'package:neck_check/adaptive_navigation_scaffold.dart';
import 'package:neck_check/pages/journal_page.dart';
import 'package:neck_check/pages/measure_page.dart';
import 'package:neck_check/pages/profile_page.dart';
import 'package:neck_check/pages/statistics_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: theme,
      home: AdaptiveNavigationScaffold(
        body: [MeasurePage(), JournalPage(), StatisticsPage(), ProfilePage()],
      ),
    );
  }
}
