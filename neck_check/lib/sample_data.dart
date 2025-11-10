import 'package:neck_check/widgets/posture_ratio_chart.dart';

final graphSamples = [
  // 아침 안정 (~10%) 6개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 0),
    badPosture: Duration(seconds: 45),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 10),
    badPosture: Duration(seconds: 70),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 20),
    badPosture: Duration(seconds: 55),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 30),
    badPosture: Duration(seconds: 80),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 40),
    badPosture: Duration(seconds: 60),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 9, 50),
    badPosture: Duration(seconds: 50),
    total: Duration(minutes: 10),
  ),

  // 점진 하락 (~30%) 3개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 0),
    badPosture: Duration(seconds: 170),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 10),
    badPosture: Duration(seconds: 200),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 20),
    badPosture: Duration(seconds: 185),
    total: Duration(minutes: 10),
  ),

  // 오전 말 슬럼프 (~75%) 9개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 30),
    badPosture: Duration(seconds: 440),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 40),
    badPosture: Duration(seconds: 470),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 10, 50),
    badPosture: Duration(seconds: 455),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 0),
    badPosture: Duration(seconds: 495),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 10),
    badPosture: Duration(seconds: 480),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 20),
    badPosture: Duration(seconds: 430),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 30),
    badPosture: Duration(seconds: 500),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 40),
    badPosture: Duration(seconds: 460),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 11, 50),
    badPosture: Duration(seconds: 445),
    total: Duration(minutes: 10),
  ),

  // 점심 자리비움 3개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 0),
    badPosture: Duration.zero,
    total: Duration.zero,
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 10),
    badPosture: Duration.zero,
    total: Duration.zero,
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 20),
    badPosture: Duration.zero,
    total: Duration.zero,
  ),

  // 회복 (~25%) 6개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 30),
    badPosture: Duration(seconds: 140),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 40),
    badPosture: Duration(seconds: 170),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 12, 50),
    badPosture: Duration(seconds: 155),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 0),
    badPosture: Duration(seconds: 160),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 10),
    badPosture: Duration(seconds: 145),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 20),
    badPosture: Duration(seconds: 165),
    total: Duration(minutes: 10),
  ),

  // 최악 구간 (~85%) 9개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 30),
    badPosture: Duration(seconds: 520),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 40),
    badPosture: Duration(seconds: 500),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 13, 50),
    badPosture: Duration(seconds: 540),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 0),
    badPosture: Duration(seconds: 510),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 10),
    badPosture: Duration(seconds: 495),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 20),
    badPosture: Duration(seconds: 535),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 30),
    badPosture: Duration(seconds: 480),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 40),
    badPosture: Duration(seconds: 525),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 50),
    badPosture: Duration(seconds: 505),
    total: Duration(minutes: 10),
  ),

  // 부분 회복 (~40%) 6개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 0),
    badPosture: Duration(seconds: 230),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 10),
    badPosture: Duration(seconds: 260),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 20),
    badPosture: Duration(seconds: 245),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 30),
    badPosture: Duration(seconds: 270),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 40),
    badPosture: Duration(seconds: 220),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 15, 50),
    badPosture: Duration(seconds: 255),
    total: Duration(minutes: 10),
  ),

  // 피로 재상승 (~70%) 3개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 0),
    badPosture: Duration(seconds: 430),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 10),
    badPosture: Duration(seconds: 450),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 20),
    badPosture: Duration(seconds: 410),
    total: Duration(minutes: 10),
  ),

  // 재개선 (~30%) 5개
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 30),
    badPosture: Duration(seconds: 175),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 40),
    badPosture: Duration(seconds: 195),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 16, 50),
    badPosture: Duration(seconds: 185),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 17, 0),
    badPosture: Duration(seconds: 170),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 17, 10),
    badPosture: Duration(seconds: 200),
    total: Duration(minutes: 10),
  ),
];
