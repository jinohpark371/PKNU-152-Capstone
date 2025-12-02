import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/auth/auth_bloc.dart';
import 'package:neck_check/blocs/settings/settings_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.redAccent : Colors.green),
    );
  }

  // 🚨 [NEW] 시간을 문자열로 변환하는 함수
  String _formatDuration(Duration duration) {
    if (duration.inMinutes == 0) return '설정 안됨';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) return '$hours시간 $minutes분';
    if (hours > 0) return '$hours시간';
    return '$minutes분';
  }

  // 🚨 [NEW] 시간 선택 바텀시트
  void _showDurationPicker(
    BuildContext context,
    String title,
    Duration initialTimer,
    Function(Duration) onSaved,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('완료'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm, // 시:분 선택 모드
                  initialTimerDuration: initialTimer,
                  onTimerDurationChanged: (Duration changedTimer) {
                    onSaved(changedTimer);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showSnackBar(context, state.message, isError: true);
        } else if (state is AuthAuthenticated) {
          _showSnackBar(context, '로그인 성공! ${state.userInfo.name}님 환영합니다.');
        } else if (state is AuthUnauthenticated) {
          _showSnackBar(context, '로그아웃되었습니다.');
        }
      },
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;
        final userInfo = isAuthenticated ? authState.userInfo : null;
        final currentUserName = userInfo?.name ?? '손님';
        final currentUserId = userInfo?.userId;
        final isLoading = authState is AuthLoading;

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

            isAuthenticated
                ? _buildUserInfoCard(context, theme, currentUserName, currentUserId)
                : _buildLoginRegisterCard(context, theme, isLoading),

            SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: ProfileItem(
                    icon: Icon(CupertinoIcons.clock_fill),
                    title: '6시간 19분',
                    subtitle: '총 측정 시간',
                  ),
                ),
              ],
            ),

            const Divider(height: 20),
            const SizedBox(height: 43),

            Text('설정', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            const Divider(height: 0),

            // 🚨 [FIX] SettingsBlocBuilder 추가: 설정 상태 구독
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                return Column(
                  children: [
                    IconListTile(
                      icon: CupertinoIcons.stopwatch_fill,
                      title: '작업 목표',
                      trailing: isAuthenticated
                          ? _formatDuration(settingsState.goalTime)
                          : '로그인 필요',
                      onTap: !isAuthenticated
                          ? null
                          : () {
                              _showDurationPicker(
                                context,
                                '작업 목표 설정',
                                settingsState.goalTime,
                                (val) => context.read<SettingsBloc>().add(GoalSetting(goal: val)),
                              );
                            },
                    ),
                    const Divider(height: 0),
                    IconListTile(
                      icon: CupertinoIcons.hourglass,
                      title: '쉬는 시간',
                      trailing: isAuthenticated
                          ? _formatDuration(settingsState.restTime)
                          : '로그인 필요',
                      onTap: !isAuthenticated
                          ? null
                          : () {
                              _showDurationPicker(
                                context,
                                '쉬는 시간 설정',
                                settingsState.restTime,
                                (val) => context.read<SettingsBloc>().add(RestSetting(rest: val)),
                              );
                            },
                    ),
                  ],
                );
              },
            ),

            const Divider(height: 0),
            SizedBox(height: 45),

            Text('기타', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            const Divider(height: 0),
            IconListTile(
              icon: CupertinoIcons.question_circle_fill,
              title: '오픈소스 라이센스',
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: "Neck Check",
                  applicationVersion: "v1.0.0",
                );
              },
            ),
            const Divider(height: 0),
          ],
        );
      },
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ThemeData theme, String userName, int? userId) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('환영합니다, $userName님!', style: theme.textTheme.headlineSmall),
                IconButton.filledTonal(
                  onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                  icon: const Icon(CupertinoIcons.square_arrow_right),
                  tooltip: '로그아웃',
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('사용자 ID: ${userId ?? '-'}', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRegisterCard(BuildContext context, ThemeData theme, bool isLoading) {
    return Card(
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인이 필요합니다', style: theme.textTheme.headlineSmall),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _showAuthDialog(context),
                    child: isLoading
                        ? const CupertinoActivityIndicator()
                        : const Text('로그인 / 회원가입'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final TextEditingController idController = TextEditingController(text: '1');
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('사용자 인증 (테스트용)'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text(
                '1. 등록된 ID로 로그인 (기본 ID: 1)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: '사용자 ID (숫자)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('2. 새 사용자 등록', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '사용자 이름'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (nameController.text.isNotEmpty) {
                authBloc.add(AuthRegisterRequested(nameController.text));
              } else if (idController.text.isNotEmpty) {
                final userId = int.tryParse(idController.text);
                if (userId != null) {
                  authBloc.add(AuthLoginRequested(userId));
                } else {
                  _showSnackBar(context, '유효하지 않은 ID 형식입니다.', isError: true);
                }
              }
            },
            child: const Text('인증 요청'),
          ),
        ],
      ),
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
  final VoidCallback? onTap;

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
