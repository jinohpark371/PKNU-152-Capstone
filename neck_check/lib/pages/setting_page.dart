import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'profile_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeArea = MediaQuery.of(context).padding;
    final topPadding = PlatformInfo.isIOS26OrHigher() ? 100 : 0;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: '더 보기'),
      body: Material(
        child: ListView(
          padding: EdgeInsets.only(top: safeArea.top + topPadding, bottom: 50, right: 20, left: 20),
          children: [
            Text(
              '개인용',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            const Divider(height: 0),
            IconListTile(icon: CupertinoIcons.person_fill, title: '계정', onTap: () {}),
            const Divider(height: 0),
            IconListTile(
              icon: CupertinoIcons.info_circle_fill,
              title: '회원님에 대해 알고 싶습니다',
              onTap: () {},
            ),
            const Divider(height: 0),
            IconListTile(
              icon: CupertinoIcons.shield_lefthalf_fill,
              title: '동의 및 개인정보',
              onTap: () {},
            ),
            const Divider(height: 0),
            IconListTile(
              icon: CupertinoIcons.doc_fill,
              title: '데이터 보존 기간',
              trailing: '20일',
              onTap: () {},
            ),
            const Divider(height: 0),
            SizedBox(height: 45),

            Text('알람', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            const Divider(height: 0),
            IconListTile(icon: CupertinoIcons.person_fill, title: '데모', onTap: () {}),
            const Divider(height: 0),
            IconListTile(icon: CupertinoIcons.person_fill, title: '데모', onTap: () {}),
            const Divider(height: 0),
            IconListTile(icon: CupertinoIcons.person_fill, title: '데모', onTap: () {}),
            const Divider(height: 0),
            IconListTile(icon: CupertinoIcons.person_fill, title: '데모', onTap: () {}),
            const Divider(height: 0),
            SizedBox(height: 45),

            Text('통계', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            const Divider(height: 0),
            IconListTile(
              icon: CupertinoIcons.doc_chart,
              title: '원본 데이터 보기',
              trailing: '켜짐',
              onTap: () {},
            ),
            const Divider(height: 0),
            SizedBox(height: 45),

            Align(alignment: AlignmentGeometry.center, child: Text('Neck Check v0.1.0')),
          ],
        ),
      ),
    );
  }
}
