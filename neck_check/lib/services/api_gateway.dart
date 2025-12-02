import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/stats_model.dart';

// Main Server IP 및 포트 설정
const String _SERVER_IP = '127.0.0.1'; // 데스크톱/웹 환경 기준
const String _SERVER_PORT = '5001';
const String _BASE_URL = 'http://$_SERVER_IP:$_SERVER_PORT';

class UserInfo {
  final int userId;
  final String name;
  final String token;

  UserInfo({required this.userId, required this.name, required this.token});
}

class ApiGateway {
  static String get baseUrl => _BASE_URL;

  // -------------------------
  // 1. 사용자 인증 API
  // -------------------------

  // 테스트용: user_id를 기반으로 로그인 요청
  Future<UserInfo?> login(int userId) async {
    final url = '$_BASE_URL/auth/login';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserInfo(
          userId: data['user_id'] as int,
          name: data['name'] as String,
          token: data['token'] as String,
        );
      }
      return null;
    } catch (e) {
      // debug print kept commented to reduce noise
      // print('❌ Login Failed: $e');
      return null;
    }
  }

  // 테스트용: 이름을 기반으로 회원가입 요청
  Future<UserInfo?> register(String name) async {
    final url = '$_BASE_URL/auth/register';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserInfo(
          userId: data['user_id'] as int,
          name: data['name'] as String,
          token: 'dummy_jwt_for_${data['user_id']}',
        );
      }
      return null;
    } catch (e) {
      // print('❌ Register Failed: $e');
      return null;
    }
  }

  // ... (기존 login, register 함수 유지)

  // -------------------------
  // 2. 실시간 데이터 API
  // -------------------------

  // 🚨 [FIX] http.Response 대신 파싱된 Map<String, dynamic>?을 반환하도록 변경
  Future<Map<String, dynamic>?> fetchFaceData() async {
    final url = '$_BASE_URL/face_data';
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(milliseconds: 1000));

      if (response.statusCode == 200) {
        // 성공 시 JSON 파싱하여 반환
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // HTTP 상태 코드가 200이 아닐 경우 (예: 404, 500)
        return null;
      }
    } catch (e) {
      // 통신 자체 오류 (타임아웃, 연결 끊김)
      // print('ApiGateway: Connection/Timeout Error: $e'); // 디버깅을 위해 주석 해제 가능
      return null;
    }
  }

  // -------------------------
  // 3. 세션 및 제어 API
  // -------------------------

  Future<bool> toggleSession(bool start) async {
    final endpoint = start ? '/session_start' : '/session_stop';
    final url = '$_BASE_URL$endpoint';
    try {
      final response = await http.post(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      // print('❌ Session Control Failed: $e');
      return false;
    }
  }

  Future<bool> resetCalibration() async {
    final url = '$_BASE_URL/calibrate_reset';
    try {
      final response = await http.post(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // -------------------------
  // 4. 통계 API
  // -------------------------

  Future<Map<String, dynamic>?> fetchStats(String classification) async {
    final url = '$_BASE_URL/stats/summary';
    try {
      final response = await http
          .get(Uri.parse(url).replace(queryParameters: {'classification': classification}))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // 한글 디코딩을 위해 utf8.decode 사용 권장
        return jsonDecode(utf8.decode(response.bodyBytes))['stats'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // print('❌ Stats Fetch Failed: $e');
      return null;
    }
  }

  // Map 대신 List<TimelineItem> 반환 (DetailStats 모델 사용도 가능)
  Future<List<TimelineItem>?> fetchDetailStats(String date) async {
    final url = '$_BASE_URL/stats/detail';
    try {
      final uri = Uri.parse(url).replace(queryParameters: {'date': date});
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // 1. 디버깅을 위해 원본 응답 출력 (확인 후 주석 처리)
        print("🔥 Server Response: ${utf8.decode(response.bodyBytes)}");

        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        if (data['timeline'] != null) {
          // [수정] Map<String, String>이 아니라 Map<String, dynamic>으로 받아야 합니다.
          // 값(value) 부분이 {"Good": 60} 같은 Map 객체이기 때문입니다.
          final timelineMap = data['timeline'] as Map<String, dynamic>;

          return timelineMap.entries.map((e) {
            // e.key = "12:00"
            // e.value = {"Good": 60, "Turtle": 10} (Dynamic/Map)
            return TimelineItem.fromEntry(e);
          }).toList();
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
      }
      return null;
    } catch (e) {
      print("❌ Dart Parsing Error: $e"); // 여기서 에러 내용을 확인하세요
      return null;
    }
  }
}
