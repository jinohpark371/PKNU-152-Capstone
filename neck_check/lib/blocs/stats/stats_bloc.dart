// stats_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/stats_model.dart';
import '../../services/api_gateway.dart';
part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ApiGateway apiGateway;

  StatsBloc({required this.apiGateway}) : super(StatsInitial()) {
    on<FetchStatsDetail>(_onFetchDetail);
  }

  // 상세 통계 불러오기 로직
  Future<void> _onFetchDetail(FetchStatsDetail event, Emitter<StatsState> emit) async {
    emit(StatsLoading());

    try {
      // ApiGateway 수정본의 fetchDetailStats가 List<TimelineItem>을 반환한다고 가정
      final timeline = await apiGateway.fetchDetailStats(event.date);

      if (timeline != null) {
        emit(StatsDetailLoaded(timeline));
      } else {
        emit(const StatsError('상세 데이터를 불러오지 못했습니다.'));
      }
    } catch (e) {
      emit(StatsError('오류 발생: $e'));
    }
  }
}
