import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neck_check/pages/main_page.dart';
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

    return AdaptiveApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('ko', '')],
      themeMode: ThemeMode.dark,
      materialDarkTheme: theme,
      cupertinoDarkTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: theme.colorScheme.primary,
        primaryContrastingColor: theme.colorScheme.onPrimary,
        scaffoldBackgroundColor: theme.colorScheme.surface,
        barBackgroundColor: theme.colorScheme.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: theme.colorScheme.onSurface,
          textStyle: TextStyle(color: theme.colorScheme.onSurface),
          navTitleTextStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: MainPage(body: [MeasurePage(), JournalPage(), StatisticsPage(), ProfilePage()]),
    );
  }
}
