import 'models/stats_model.dart';

class DurationHelper {
  /// 타임라인 리스트에서 특정 자세(targetPosture)의 총 지속 시간(초)을 계산합니다.
  /// targetPosture가 null이면 모든 자세의 시간을 합산합니다(총 사용 시간).
  static int calculateTotalSeconds(List<TimelineItem> timeline, {String? targetPosture}) {
    int totalSeconds = 0;

    for (var item in timeline) {
      // item.value가 Map 형태인지 확인 (백엔드 구조: {"Turtle": 45, "Good": 15})
      if (item.value is Map) {
        final valueMap = item.value as Map;

        if (targetPosture != null) {
          // 1. 특정 자세(예: 'Turtle')의 시간만 구하고 싶은 경우
          if (valueMap.containsKey(targetPosture)) {
            // dynamic -> num -> int 안전하게 변환
            totalSeconds += (valueMap[targetPosture] as num).toInt();
          }
        } else {
          // 2. 해당 분(minute)의 모든 기록된 시간을 더하고 싶은 경우 (총 사용 시간)
          for (var duration in valueMap.values) {
            totalSeconds += (duration as num).toInt();
          }
        }
      }
    }

    return totalSeconds;
  }

  /// 초(int)를 "MM분 SS초" 또는 "HH시간 MM분" 문자열로 변환
  static String formatSeconds(int seconds) {
    if (seconds < 60) {
      return '${seconds}초';
    } else if (seconds < 3600) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '${m}분 ${s}초';
    } else {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      return '${h}시간 ${m}분';
    }
  }
}

String weekday(int index) => const ['일', '월', '화', '수', '목', '금', '토'][index];

String weekdayByDate(DateTime date) => weekday(date.weekday % 7);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return '$h시간 $m분';
}
