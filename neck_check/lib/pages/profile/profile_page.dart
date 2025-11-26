import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neck_check/pages/profile/setting_page.dart';
import 'package:neck_check/widgets/progress_ring.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(60),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('프로필', style: theme.textTheme.displayMedium),
            IconButton.filledTonal(onPressed: () {}, icon: Icon(CupertinoIcons.gift)),
          ],
        ),
        const Divider(height: 60),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: ProfileItem(icon: Icon(CupertinoIcons.moon_fill), title: '13', subtitle: '일'),
            ),
            Expanded(
              child: ProfileItem(
                icon: ProgressRing(value: 0.73, size: 24),
                title: '73%',
                subtitle: '평균 자세',
              ),
            ),
          ],
        ),
        SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: ProfileItem(
                icon: Icon(CupertinoIcons.clock_fill),
                title: '6시간 19분',
                subtitle: '평균 시간',
              ),
            ),
            Expanded(
              child: ProfileItem(
                icon: Icon(CupertinoIcons.cloud_upload_fill),
                title: '확인',
                subtitle: '백업',
              ),
            ),
          ],
        ),
        SizedBox(height: 34),
        ElevatedButton.icon(
          onPressed: () {},
          label: Text('즐겨 찾는 페이지'),
          icon: Icon(CupertinoIcons.heart_fill),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          label: Text('나의 위치 확인하기'),
          icon: Icon(CupertinoIcons.location_solid),
        ),
        const Divider(height: 50),
        const SizedBox(height: 23),

        Text('설정', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const Divider(height: 0),
        IconListTile(
          icon: CupertinoIcons.stopwatch_fill,
          title: '작업 목표',
          trailing: '켜짐',
          onTap: () {},
        ),
        const Divider(height: 0),
        IconListTile(icon: CupertinoIcons.bell_fill, title: '알림', trailing: '켜짐', onTap: () {}),
        const Divider(height: 0),
        IconListTile(icon: CupertinoIcons.hourglass, title: '쉬는 시간', trailing: '10분', onTap: () {}),
        const Divider(height: 0),
        IconListTile(icon: CupertinoIcons.camera_fill, title: '카메라', onTap: () {}),
        const Divider(height: 0),
        IconListTile(icon: CupertinoIcons.doc_fill, title: '주간 보고서', trailing: '켜짐', onTap: () {}),
        const Divider(height: 0),
        IconListTile(
          icon: CupertinoIcons.ellipsis,
          title: '더 보기',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingPage()));
          },
        ),
        const Divider(height: 0),
        SizedBox(height: 45),

        Text('기타', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const Divider(height: 0),
        IconListTile(icon: CupertinoIcons.question_circle_fill, title: '도움말', onTap: () {}),
        const Divider(height: 0),
      ],
    );
  }
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({super.key, required this.icon, required this.title, required this.subtitle});

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            icon,
            Text(title, style: theme.textTheme.headlineMedium),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 30),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class IconListTile extends StatelessWidget {
  const IconListTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget effectiveTrailing = const Icon(CupertinoIcons.right_chevron);

    if (trailing != null) {
      effectiveTrailing = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Text(trailing!, style: Theme.of(context).textTheme.bodyLarge),
          effectiveTrailing,
        ],
      );
    }
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      trailing: effectiveTrailing,
      onTap: onTap,
    );
  }
}
