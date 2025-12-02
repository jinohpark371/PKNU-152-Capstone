import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
// 🚨 [FIX] 경로를 lib/services/api_gateway.dart로 변경합니다.
import 'package:neck_check/services/api_gateway.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ... (나머지 코드는 이전 내용과 동일)
  final ApiGateway _apiGateway = ApiGateway();

  AuthBloc() : super(AuthUnauthenticated()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final userInfo = await _apiGateway.login(event.userId);

    if (userInfo != null) {
      emit(AuthAuthenticated(userInfo: userInfo));
    } else {
      emit(AuthError(message: '로그인 실패: 사용자 ID를 확인하세요.'));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final userInfo = await _apiGateway.register(event.name);

    if (userInfo != null) {
      // 회원가입 성공 시, Main Server의 RemoteHandler에도 ID를 설정해야 하지만,
      // 현재는 Main Server가 로그인 API 호출을 중계할 때 자동으로 처리합니다.
      emit(AuthAuthenticated(userInfo: userInfo));
    } else {
      emit(AuthError(message: '회원가입 실패: 서버 연결 상태를 확인하세요.'));
    }
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }

  // Helper: 현재 사용자 ID를 안전하게 가져오는 getter
  int? get currentUserId {
    final state = this.state;
    return state is AuthAuthenticated ? state.userInfo.userId : null;
  }
}