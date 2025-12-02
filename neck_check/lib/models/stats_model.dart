class StatsSummary {
  final double totalDuration; // 초 단위
  final double average; // Good 자세 점수 (0~100)
  final double goodPercent;
  final double turtlePercent;

  StatsSummary({
    required this.totalDuration,
    required this.average,
    required this.goodPercent,
    required this.turtlePercent,
  });

  factory StatsSummary.fromServerJson(Map<String, dynamic> json) {
    // json['stats'] 내부 데이터 접근
    final statsMap = json['stats'] ?? {};

    // 안전한 파싱을 위한 헬퍼 함수
    double getPercent(String key) {
      if (statsMap[key] != null) {
        return (statsMap[key]['percent'] ?? 0).toDouble();
      }
      return 0.0;
    }

    final double good = getPercent('Good');
    final double turtle = getPercent('Turtle');
    final double totalSec = (json['total_seconds'] ?? 0).toDouble();

    return StatsSummary(
      totalDuration: totalSec,
      // 예시: Good 자세 비율을 점수로 사용
      average: good,
      goodPercent: good,
      turtlePercent: turtle,
    );
  }

  static StatsSummary? fromServerJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return StatsSummary.fromServerJson(json);
  }
}

class TimelineItem {
  final String time;
  final dynamic value; // 수치(int/double) 또는 상태(String)일 수 있어 dynamic 처리

  TimelineItem({required this.time, required this.value});

  // Map Entry에서 변환
  factory TimelineItem.fromEntry(MapEntry<String, dynamic> entry) {
    return TimelineItem(time: entry.key, value: entry.value);
  }
}

class DetailStats {
  final String date;
  final List<TimelineItem> timeline;

  DetailStats({required this.date, required this.timeline});

  factory DetailStats.fromJson(Map<String, dynamic> json) {
    final timelineMap = json['timeline'] as Map<String, dynamic>? ?? {};

    // Map을 List<TimelineItem>으로 변환 (시간순 정렬 가능)
    final timelineList = timelineMap.entries.map((e) => TimelineItem.fromEntry(e)).toList();

    // 필요하다면 시간순 정렬 (키가 시간 문자열인 경우)
    timelineList.sort((a, b) => a.time.compareTo(b.time));

    return DetailStats(date: json['date'] as String? ?? '', timeline: timelineList);
  }
}
