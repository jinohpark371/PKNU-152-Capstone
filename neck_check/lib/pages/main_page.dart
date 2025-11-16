import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.body});

  final List<Widget> body;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final currentIndex = ValueNotifier<int>(1);

  @override
  void dispose() {
    currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        items: [
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher() ? "timer" : CupertinoIcons.timer,
            selectedIcon: CupertinoIcons.timer_fill,
            label: '측정',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher() ? "book.fill" : CupertinoIcons.book,
            selectedIcon: CupertinoIcons.book_fill,
            label: '일지',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "chart.bar.fill"
                : CupertinoIcons.chart_bar_alt_fill,
            selectedIcon: CupertinoIcons.chart_bar_alt_fill,
            label: '통계',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "person.circle.fill"
                : CupertinoIcons.person_circle,
            selectedIcon: CupertinoIcons.person_circle_fill,
            label: '프로필',
          ),
        ],
      ),
      body: Center(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder(
              valueListenable: currentIndex,
              builder: (context, value, child) {
                return widget.body[value];
              },
            ),
          ),
        ),
      ),
    );
  }
}
