import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/auth/auth_bloc.dart';
import 'package:neck_check/pages/main_page.dart';
import 'package:neck_check/pages/journal/journal_page.dart';
import 'package:neck_check/pages/measure/measure_page.dart';
import 'package:neck_check/pages/profile/profile_page.dart';
import 'package:neck_check/pages/statistics/statistics_page.dart';
import 'package:neck_check/services/api_gateway.dart';
import 'package:window_manager/window_manager.dart';

import 'blocs/settings/settings_bloc.dart';
import 'blocs/stats/stats_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [추가] 윈도우 매니저 초기화 및 설정
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800), // 앱 실행 시 초기 크기 (원하는 대로 조절 가능)
    minimumSize: Size(800, 600), // [핵심] 사용자가 이보다 작게 줄일 수 없음
    center: true, // 실행 시 화면 중앙 배치
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal, // 기본 타이틀 바 유지 (커스텀 원하면 hidden으로 변경)
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    );

    return MultiBlocProvider(
      providers: [
        // Provide AuthBloc first so other blocs can read it from context
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),

        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(create: (context) => StatsBloc(apiGateway: ApiGateway())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MainPage(body: const [MeasurePage(), JournalPage(), StatisticsPage(), ProfilePage()]),
      ),
    );
  }
}
