import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/journal/journal_bloc.dart';
import 'package:neck_check/pages/main_page.dart';
import 'package:neck_check/pages/journal/journal_page.dart';
import 'package:neck_check/pages/measure/measure_page.dart';
import 'package:neck_check/pages/profile/profile_page.dart';
import 'package:neck_check/pages/statistics/statistics_page.dart';
import 'package:window_manager/window_manager.dart';

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

    /// AdaptiveApp을 쓰지 않는 이유 => IOS system overlay에 다크모드 적용이 안됨(검은 글자가 나옴)
    /// MaterialApp을 쓰지 않는 이유 => IOS18에서 스크롤할 때 AdaptiveAppBar의 테마가 라이트모드로 고정됨
    /// CupertinoApp 사용 시 모든 문제가 해결됨
    return MultiBlocProvider(
      providers: [
        BlocProvider<JournalBloc>(
          create: (BuildContext context) => JournalBloc()..add(FetchAllJournalData()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: MainPage(body: const [MeasurePage(), JournalPage(), StatisticsPage(), ProfilePage()]),
      ),
    );
  }
}
