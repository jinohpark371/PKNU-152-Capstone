import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.body});

  final List<Widget> body;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final currentIndex = ValueNotifier<int>(0); // 초기값은 '측정' 탭이라고 가정
  final isExtended = ValueNotifier<bool>(false);

  @override
  void dispose() {
    currentIndex.dispose();
    isExtended.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 너비가 800 이상이면 확장(Expanded) 모드로 설정
          isExtended.value = constraints.maxWidth > 800;

          return Row(
            children: [
              // 1. NavigationRail
              ValueListenableBuilder(
                valueListenable: isExtended,
                builder: (_, isEx, _) => ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (_, currentIn, _) => NavigationRail(
                    selectedIndex: currentIn,
                    onDestinationSelected: (index) => currentIndex.value = index,
                    extended: isEx,
                    labelType: isEx ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                    minExtendedWidth: 150,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(CupertinoIcons.timer),
                        selectedIcon: Icon(CupertinoIcons.timer_fill),
                        label: Text('측정'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(CupertinoIcons.book),
                        selectedIcon: Icon(CupertinoIcons.book_fill),
                        label: Text('일지'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(CupertinoIcons.chart_bar_alt_fill),
                        selectedIcon: Icon(CupertinoIcons.chart_bar_alt_fill),
                        label: Text('통계'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(CupertinoIcons.person_circle),
                        selectedIcon: Icon(CupertinoIcons.person_circle_fill),
                        label: Text('프로필'),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. 구분선
              const VerticalDivider(thickness: 1, width: 1),

              // 3. 메인 콘텐츠
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: currentIndex,
                  builder: (context, value, child) {
                    return IndexedStack(index: value, children: widget.body);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
