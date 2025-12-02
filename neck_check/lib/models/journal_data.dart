class JournalData {
  const JournalData({
    required this.start,
    required this.end,
    // [FIX] 백엔드 API에서 제공하는 통계값으로 대체합니다.
    this.totalWorkSeconds = 0,
    this.goodPoseSeconds = 0,
    // 이 값들은 백엔드 통계 API에서 직접 얻기 어려우므로 임시로 제외하거나,
    // 별도의 API를 통해 가져와야 합니다. 현재는 통계 API에 맞춰 단순화합니다.
    this.sleep = Duration.zero,
    this.turtle = Duration.zero,
    this.breakTime = Duration.zero,
    this.tilted = Duration.zero,
  });

  const JournalData.empty({required this.start})
    : end = start,
      totalWorkSeconds = 0,
      goodPoseSeconds = 0,
      sleep = Duration.zero,
      turtle = Duration.zero,
      breakTime = Duration.zero,
      tilted = Duration.zero;

  final DateTime start;
  final DateTime end;

  // [FIX] 초 단위의 합산값으로 변경
  final int totalWorkSeconds;
  final int goodPoseSeconds;

  final Duration breakTime;

  final Duration turtle;
  final Duration sleep;
  final Duration tilted;

  // [FIX] 비율 계산도 초 단위 합산값으로 변경
  double get goodRatio => totalWorkSeconds == 0 ? 0.0 : goodPoseSeconds / totalWorkSeconds;

  // 헬퍼: Duration으로 변환
  Duration get workTimeDuration => Duration(seconds: totalWorkSeconds);
  Duration get goodPoseDuration => Duration(seconds: goodPoseSeconds);
}
