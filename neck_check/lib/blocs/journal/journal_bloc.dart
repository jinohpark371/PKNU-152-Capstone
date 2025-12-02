import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:neck_check/blocs/auth/auth_bloc.dart'; // [NEW] AuthBloc import
import 'package:neck_check/models/journal_data.dart';
import 'package:neck_check/services/api_gateway.dart';

part 'journal_event.dart';
part 'journal_state.dart';

// [NEW] BLoC 생성자에 AuthBloc 주입을 위해 변경
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final AuthBloc _authBloc;
  final ApiGateway _apiGateway = ApiGateway();

  // [FIX] AuthBloc을 받도록 생성자 수정
  JournalBloc({required AuthBloc authBloc}) : _authBloc = authBloc, super(JournalLoading()) {
    on<JournalEvent>((event, emit) async {});

    // [FIX] Auth 상태와 연동하여 데이터 로드
    on<FetchAllJournalData>(_onFetchAllJournalData);

    // Auth 상태 변화 시 로드 재요청 (로그인/로그아웃 시)
    _authBloc.stream.listen((state) {
      // 상태 변경은 블록의 이벤트를 통해 처리합니다 (emit을 직접 호출하면 안 됩니다)
      if (state is AuthAuthenticated) {
        add(FetchAllJournalData());
      } else if (state is AuthUnauthenticated) {
        // 로그아웃 시에도 동일하게 데이터를 재로드시키도록 이벤트를 추가합니다.
        add(FetchAllJournalData());
      }
    });
  }

  // [NEW] 자세 통계 API 결과 파싱 및 합산 헬퍼
  // 통계 결과 { "Good": { "time": "01:00:00", "percent": 50.0 }, ... }
  // 에서 총 시간(초)을 계산합니다.
  int _parseTime(String time) {
    final parts = time.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.length == 3) {
      return parts[0] * 3600 + parts[1] * 60 + parts[2];
    }
    return 0;
  }

  // [NEW] 날짜별 통계 데이터 로딩 함수 (MockData 대체)
  Future<void> _onFetchAllJournalData(FetchAllJournalData event, Emitter<JournalState> emit) async {
    final userId = _authBloc.currentUserId;
    if (userId == null) {
      emit(JournalLoading()); // 로그아웃 상태
      return;
    }
    emit(JournalLoading());

    // 🚨 [필요] 백엔드에서 모든 날짜의 데이터를 한 번에 가져오는 API가 없으므로,
    // 현재는 MockData를 활용하거나, StatisticsPage처럼 현재 날짜의 주간/월간 통계만 가져와야 합니다.
    // JournalPage는 달력(CalendarPage)과 주간 탭을 위해 '날짜별' 데이터가 필요합니다.

    // 임시 방안: 실제 날짜별 데이터를 구현하기 어려우므로,
    // 임시로 '오늘'의 통계 데이터를 가져와서 현재 날짜의 JournalData로 변환합니다.
    // => 실제 서비스에서는 날짜별 기록을 조회하는 API가 필요합니다.

    // 테스트 목적으로, '오늘'의 통계 데이터를 가져와 오늘 날짜의 데이터로 사용합니다.
    final todayStats = await _apiGateway.fetchStats('오늘');

    List<JournalData> dataList = [];

    if (todayStats != null && todayStats.isNotEmpty) {
      final now = DateTime.now();

      // Good 자세 시간 합산 (바른 자세)
      final goodStats = todayStats['Good'] ?? {'time': '00:00:00'};
      final goodSeconds = _parseTime(goodStats['time']);

      // 전체 분석 시간 합산 (Total Work)
      int totalSeconds = 0;
      todayStats.forEach((key, value) {
        // calibrating_start는 제외하고 계산 (순수 자세 분석 시간만)
        if (key != 'calibrating_start') {
          totalSeconds += _parseTime(value['time']);
        }
      });

      // 오늘 날짜의 JournalData 생성
      final todayData = JournalData(
        start: now,
        end: now,
        totalWorkSeconds: totalSeconds,
        goodPoseSeconds: goodSeconds,
      );

      // [FIX] 테스트를 위해 단일 데이터만 리스트에 추가합니다.
      dataList.add(todayData);
    }

    // MockData의 주간 링 탭을 살리기 위해, MockData의 구조는 유지하되
    // 인증 상태에 따라 실제 데이터를 덮어쓰거나 Mock을 사용합니다.

    if (dataList.isEmpty) {
      // [임시] Mock data를 사용하여 주간 탭의 UI를 살립니다.
      // 이 부분은 실제 API가 구축될 때 제거되어야 합니다.
      // dataList = mockReport;
    }

    emit(JournalSuccess(dataList: dataList));
  }
}
