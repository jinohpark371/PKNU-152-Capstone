// stats_event.dart

part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

// 상세 타임라인 요청 (예: '2024-12-03' 날짜 전달)
class FetchStatsDetail extends StatsEvent {
  final String date;

  const FetchStatsDetail(this.date);

  @override
  List<Object> get props => [date];
}
