import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  // 초기값 설정 (예: 목표 50분, 휴식 10분)
  SettingsBloc()
    : super(
        SettingsState(goalTime: const Duration(minutes: 50), restTime: const Duration(minutes: 10)),
      ) {
    // 목표 시간 변경 이벤트 핸들러
    on<GoalSetting>((event, emit) {
      emit(state.copyWith(goalTime: event.goal));
    });

    // 쉬는 시간 변경 이벤트 핸들러
    on<RestSetting>((event, emit) {
      emit(state.copyWith(restTime: event.rest));
    });
  }
}
