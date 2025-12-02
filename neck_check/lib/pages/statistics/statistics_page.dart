import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/blocs/auth/auth_bloc.dart';
import 'package:neck_check/services/api_gateway.dart'; // [NEW] ApiGateway 사용
import 'package:neck_check/widgets/progress_ring.dart'; // ProgressRing 사용 가정

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _classifications = ['오늘', '이번 주', '이번 달'];
  final ApiGateway _apiGateway = ApiGateway(); // 통신 게이트웨이 인스턴스

  // 상태 변수
  Map<String, dynamic>? _currentStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _classifications.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // AuthBloc 상태 변경 시 통계 로드 요청
    context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthAuthenticated) {
        _fetchStats(_classifications[_tabController.index]); // 로그인 성공 시 로드
      } else if (state is AuthUnauthenticated) {
        setState(() => _currentStats = null); // 로그아웃 시 데이터 리셋
      }
    });

    // 초기 로드 (로그인 상태라면 바로 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthBloc>().state is AuthAuthenticated) {
        _fetchStats(_classifications[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _fetchStats(_classifications[_tabController.index]);
    }
  }

  Future<void> _fetchStats(String classification) async {
    final userId = context.read<AuthBloc>().currentUserId;
    if (userId == null) {
      setState(() => _currentStats = null);
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStats = null;
    });

    final stats = await _apiGateway.fetchStats(classification);

    if (mounted) {
      setState(() {
        _currentStats = stats;
        _isLoading = false;
      });

      if (stats == null) {
        _showSnackbar('통계 데이터 로드 실패. 서버 상태를 확인하세요.', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('자세 통계'),
        bottom: isAuthenticated
            ? TabBar(
                controller: _tabController,
                tabs: _classifications.map((c) => Tab(text: c)).toList(),
              )
            : null,
      ),
      body: !isAuthenticated
          ? const Center(child: Text('로그인 후 이용 가능합니다.'))
          : TabBarView(
              controller: _tabController,
              children: _classifications.map((c) => _buildStatView(c)).toList(),
            ),
    );
  }

  Widget _buildStatView(String classification) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentStats == null || _currentStats!.isEmpty) {
      return Center(child: Text('$classification 기간에 기록된 데이터가 없습니다.'));
    }

    // 통계 데이터 처리 (핵심 로직)
    final totalDuration = _calculateTotalDuration(_currentStats!);
    // Good이 없을 경우를 대비하여 기본값 설정
    final goodStats = _currentStats!['Good'] ?? {'time': '00:00:00', 'percent': 0.0};

    // Ambiguous나 Calibrating은 제외하고 'Bad' 자세 타입만 필터링
    final badPostureTypes = _currentStats!.keys
        .where((k) => k != 'Good' && !k.contains('Ambiguous') && !k.contains('calibrating'))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. 핵심 비율 링 (Good Ratio)
        Center(
          child: ProgressRing(
            value: (goodStats['percent'] as double) / 100.0,
            size: 150,
            thickness: 15,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(goodStats['percent'] as double).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text('바른 자세 비율', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // 2. 총 시간 요약
        _buildSummaryCard(
          title: '총 분석 시간',
          time: _formatTotalDuration(totalDuration),
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 20),

        // 3. 자세별 상세 시간
        Text('자세별 지속 시간', style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        _buildPostureDetail('정자세 (Good)', goodStats['time'], goodStats['percent'], Colors.green),
        ...badPostureTypes.map((type) {
          final stats = _currentStats![type];
          return _buildPostureDetail(
            type,
            stats['time'],
            stats['percent'] as double,
            type == 'Turtle' ? Colors.redAccent : Colors.orange,
          );
        }).toList(),
      ],
    );
  }

  // --- 헬퍼 함수 ---

  int _parseTime(String time) {
    // HH:MM:SS -> seconds
    final parts = time.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.length == 3) {
      return parts[0] * 3600 + parts[1] * 60 + parts[2];
    }
    return 0;
  }

  int _calculateTotalDuration(Map<String, dynamic> stats) {
    int total = 0;
    stats.forEach((key, value) {
      total += _parseTime(value['time']);
    });
    return total;
  }

  String _formatTotalDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}시간 ${m}분';
  }

  Widget _buildSummaryCard({required String title, required String time, required Color color}) {
    return Card(
      color: color.withOpacity(0.15),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostureDetail(String type, String time, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text('${percent.toStringAsFixed(1)}%', style: TextStyle(color: color)),
          const SizedBox(width: 15),
          SizedBox(width: 100, child: Text(time, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
