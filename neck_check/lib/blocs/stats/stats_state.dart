part of 'stats_bloc.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class StatsInitial extends StatsState {}

// 로딩 중 (스피너 표시용)
class StatsLoading extends StatsState {}

// 요약 통계 로드 성공
class StatsSummaryLoaded extends StatsState {
  final StatsSummary summary;

  const StatsSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

// 상세 통계(타임라인) 로드 성공
class StatsDetailLoaded extends StatsState {
  final List<TimelineItem> timeline;

  const StatsDetailLoaded(this.timeline);

  @override
  List<Object?> get props => [timeline];
}

// 에러 발생
class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
