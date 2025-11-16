import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neck_check/blocs/journal/journal_bloc.dart';
import 'package:neck_check/pages/main_page.dart';
import 'package:neck_check/pages/journal/journal_page.dart';
import 'package:neck_check/pages/measure/measure_page.dart';
import 'package:neck_check/pages/profile/profile_page.dart';
import 'package:neck_check/pages/statistics/statistics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // iOS는 무시, Android 투명
      statusBarIconBrightness: Brightness.dark, // Android 흰색 아이콘
      statusBarBrightness: Brightness.dark, // iOS 흰색 아이콘 (LightContent)
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    );

    /// AdaptiveApp을 쓰지 않는 이유 => IOS system overlay에 다크모드 적용이 안됨(검은 글자가 나옴)
    /// MaterialApp을 쓰지 않는 이유 => IOS18에서 스크롤할 때 AdaptiveAppBar의 테마가 라이트모드로 고정됨
    /// CupertinoApp 사용 시 모든 문제가 해결됨
    return MultiBlocProvider(
      providers: [
        BlocProvider<JournalBloc>(
          create: (BuildContext context) => JournalBloc()..add(FetchAllJournalData()),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('ko', '')],
        theme: CupertinoThemeData(
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
      ),
    );
  }
}
