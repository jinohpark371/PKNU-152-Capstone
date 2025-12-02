part of 'settings_bloc.dart';

class SettingsState {
  final Duration goalTime;
  final Duration restTime;

  SettingsState({this.goalTime = Duration.zero, this.restTime = Duration.zero});

  // 상태 복사 및 업데이트를 위한 copyWith 추가
  SettingsState copyWith({Duration? goalTime, Duration? restTime}) {
    return SettingsState(goalTime: goalTime ?? this.goalTime, restTime: restTime ?? this.restTime);
  }
}
