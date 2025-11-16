import 'package:neck_check/models/journal_data.dart';
import 'package:neck_check/widgets/posture_ratio_chart.dart';

final mockReport = [
  // 1주차
  JournalData(
    start: DateTime(2025, 11, 1, 9, 24),
    end: DateTime(2025, 11, 1, 18, 58),
    isGoal: false,
    workTime: Duration(minutes: 334),
    goodPose: Duration(minutes: 197),
    focusTime: Duration(minutes: 160),
    breakTime: Duration(minutes: 24),
    badPose: Duration(minutes: 100),
  ),
  JournalData(
    start: DateTime(2025, 11, 2, 9, 10),
    end: DateTime(2025, 11, 2, 18, 40),
    isGoal: true,
    workTime: Duration(minutes: 320),
    goodPose: Duration(minutes: 120),
    focusTime: Duration(minutes: 190),
    breakTime: Duration(minutes: 30),
    badPose: Duration(minutes: 85),
  ),
  JournalData(
    start: DateTime(2025, 11, 3, 8, 55),
    end: DateTime(2025, 11, 3, 17, 45),
    isGoal: false,
    workTime: Duration(minutes: 290),
    goodPose: Duration(minutes: 130),
    focusTime: Duration(minutes: 140),
    breakTime: Duration(minutes: 35),
    badPose: Duration(minutes: 120),
  ),
  JournalData(
    start: DateTime(2025, 11, 4, 10, 5),
    end: DateTime(2025, 11, 4, 19, 25),
    isGoal: true,
    workTime: Duration(minutes: 405),
    goodPose: Duration(minutes: 315),
    focusTime: Duration(minutes: 225),
    breakTime: Duration(minutes: 22),
    badPose: Duration(minutes: 90),
  ),
  JournalData(
    start: DateTime(2025, 11, 5, 9, 32),
    end: DateTime(2025, 11, 5, 18, 20),
    isGoal: false,
    workTime: Duration(minutes: 310),
    goodPose: Duration(minutes: 180),
    focusTime: Duration(minutes: 155),
    breakTime: Duration(minutes: 28),
    badPose: Duration(minutes: 105),
  ),
  JournalData(
    start: DateTime(2025, 11, 6, 9, 5),
    end: DateTime(2025, 11, 6, 18, 20),
    isGoal: true,
    workTime: Duration(minutes: 355),
    goodPose: Duration(minutes: 210),
    focusTime: Duration(minutes: 185),
    breakTime: Duration(minutes: 26),
    badPose: Duration(minutes: 95),
  ),
  JournalData(
    start: DateTime(2025, 11, 7, 9, 18),
    end: DateTime(2025, 11, 7, 18, 2),
    isGoal: false,
    workTime: Duration(minutes: 275),
    goodPose: Duration(minutes: 95),
    focusTime: Duration(minutes: 120),
    breakTime: Duration(minutes: 33),
    badPose: Duration(minutes: 130),
  ),

  // 2주차 (주말 약함)
  JournalData(
    start: DateTime(2025, 11, 8, 9, 12),
    end: DateTime(2025, 11, 8, 18, 42),
    isGoal: true,
    workTime: Duration(minutes: 345),
    goodPose: Duration(minutes: 195),
    focusTime: Duration(minutes: 170),
    breakTime: Duration(minutes: 27),
    badPose: Duration(minutes: 105),
  ),

  JournalData(
    start: DateTime(2025, 11, 10, 9, 35),
    end: DateTime(2025, 11, 10, 19, 5),
    isGoal: true,
    workTime: Duration(minutes: 370),
    goodPose: Duration(minutes: 320),
    focusTime: Duration(minutes: 200),
    breakTime: Duration(minutes: 29),
    badPose: Duration(minutes: 95),
  ),
  JournalData(
    start: DateTime(2025, 11, 11, 9, 18),
    end: DateTime(2025, 11, 11, 18, 50),
    isGoal: false,
    workTime: Duration(minutes: 338),
    goodPose: Duration(minutes: 205),
    focusTime: Duration(minutes: 165),
    breakTime: Duration(minutes: 33),
    badPose: Duration(minutes: 115),
  ),

  JournalData(
    start: DateTime(2025, 11, 13, 8, 48),
    end: DateTime(2025, 11, 13, 17, 12),
    isGoal: false,
    workTime: Duration(minutes: 260),
    goodPose: Duration(minutes: 75),
    focusTime: Duration(minutes: 125),
    breakTime: Duration(minutes: 30),
    badPose: Duration(minutes: 120),
  ),
  JournalData(
    start: DateTime(2025, 11, 14, 9, 45),
    end: DateTime(2025, 11, 14, 19, 10),
    isGoal: true,
    workTime: Duration(minutes: 390),
    goodPose: Duration(minutes: 340),
    focusTime: Duration(minutes: 220),
    breakTime: Duration(minutes: 26),
    badPose: Duration(minutes: 90),
  ),

  // 3주차
  JournalData(
    start: DateTime(2025, 11, 15, 9, 5),
    end: DateTime(2025, 11, 15, 18, 35),
    isGoal: false,
    workTime: Duration(minutes: 330),
    goodPose: Duration(minutes: 275),
    focusTime: Duration(minutes: 155),
    breakTime: Duration(minutes: 36),
    badPose: Duration(minutes: 125),
  ),
  JournalData(
    start: DateTime(2025, 11, 16, 10, 20),
    end: DateTime(2025, 11, 16, 15, 5),
    isGoal: true,
    workTime: Duration(minutes: 210),
    goodPose: Duration(minutes: 150),
    focusTime: Duration(minutes: 120),
    breakTime: Duration(minutes: 18),
    badPose: Duration(minutes: 45),
  ),
  JournalData(
    start: DateTime(2025, 11, 17, 9, 22),
    end: DateTime(2025, 11, 17, 18, 58),
    isGoal: false,
    workTime: Duration(minutes: 342),
    goodPose: Duration(minutes: 285),
    focusTime: Duration(minutes: 170),
    breakTime: Duration(minutes: 32),
    badPose: Duration(minutes: 118),
  ),
  JournalData(
    start: DateTime(2025, 11, 19, 9, 30),
    end: DateTime(2025, 11, 19, 19, 0),
    isGoal: false,
    workTime: Duration(minutes: 345),
    goodPose: Duration(minutes: 215),
    focusTime: Duration(minutes: 160),
    breakTime: Duration(minutes: 35),
    badPose: Duration(minutes: 128),
  ),
  JournalData(
    start: DateTime(2025, 11, 20, 8, 52),
    end: DateTime(2025, 11, 20, 17, 14),
    isGoal: true,
    workTime: Duration(minutes: 300),
    goodPose: Duration(minutes: 240),
    focusTime: Duration(minutes: 165),
    breakTime: Duration(minutes: 25),
    badPose: Duration(minutes: 60),
  ),
  JournalData(
    start: DateTime(2025, 11, 21, 9, 12),
    end: DateTime(2025, 11, 21, 18, 22),
    isGoal: false,
    workTime: Duration(minutes: 312),
    goodPose: Duration(minutes: 190),
    focusTime: Duration(minutes: 145),
    breakTime: Duration(minutes: 38),
    badPose: Duration(minutes: 132),
  ),

  // 4주차
  JournalData(
    start: DateTime(2025, 11, 22, 9, 28),
    end: DateTime(2025, 11, 22, 18, 56),
    isGoal: true,
    workTime: Duration(minutes: 368),
    goodPose: Duration(minutes: 318),
    focusTime: Duration(minutes: 205),
    breakTime: Duration(minutes: 25),
    badPose: Duration(minutes: 92),
  ),
  JournalData(
    start: DateTime(2025, 11, 23, 11, 5),
    end: DateTime(2025, 11, 23, 16, 0),
    isGoal: false,
    workTime: Duration(minutes: 160),
    goodPose: Duration(minutes: 40),
    focusTime: Duration(minutes: 70),
    breakTime: Duration(minutes: 15),
    badPose: Duration(minutes: 60),
  ),
  JournalData(
    start: DateTime(2025, 11, 24, 9, 20),
    end: DateTime(2025, 11, 24, 18, 50),
    isGoal: true,
    workTime: Duration(minutes: 360),
    goodPose: Duration(minutes: 310),
    focusTime: Duration(minutes: 200),
    breakTime: Duration(minutes: 29),
    badPose: Duration(minutes: 99),
  ),
  JournalData(
    start: DateTime(2025, 11, 25, 9, 14),
    end: DateTime(2025, 11, 25, 18, 44),
    isGoal: false,
    workTime: Duration(minutes: 334),
    goodPose: Duration(minutes: 176),
    focusTime: Duration(minutes: 162),
    breakTime: Duration(minutes: 31),
    badPose: Duration(minutes: 116),
  ),
  JournalData(
    start: DateTime(2025, 11, 26, 9, 32),
    end: DateTime(2025, 11, 26, 19, 2),
    isGoal: true,
    workTime: Duration(minutes: 380),
    goodPose: Duration(minutes: 330),
    focusTime: Duration(minutes: 210),
    breakTime: Duration(minutes: 28),
    badPose: Duration(minutes: 102),
  ),
  JournalData(
    start: DateTime(2025, 11, 27, 9, 0),
    end: DateTime(2025, 11, 27, 18, 30),
    isGoal: false,
    workTime: Duration(minutes: 315),
    goodPose: Duration(minutes: 160),
    focusTime: Duration(minutes: 150),
    breakTime: Duration(minutes: 37),
    badPose: Duration(minutes: 130),
  ),
  JournalData(
    start: DateTime(2025, 11, 28, 9, 40),
    end: DateTime(2025, 11, 28, 19, 5),
    isGoal: true,
    workTime: Duration(minutes: 388),
    goodPose: Duration(minutes: 338),
    focusTime: Duration(minutes: 218),
    breakTime: Duration(minutes: 26),
    badPose: Duration(minutes: 94),
  ),

  JournalData(
    start: DateTime(2025, 11, 30, 9, 24),
    end: DateTime(2025, 11, 30, 18, 54),
    isGoal: true,
    workTime: Duration(minutes: 372),
    goodPose: Duration(minutes: 322),
    focusTime: Duration(minutes: 208),
    breakTime: Duration(minutes: 27),
    badPose: Duration(minutes: 97),
  ),
];

final mockGraphData = [
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
    badPosture: Duration(seconds: 580),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 0),
    badPosture: Duration(seconds: 600),
    total: Duration(minutes: 10),
  ),
  PostureSample(
    measuredAt: DateTime(2025, 11, 1, 14, 10),
    badPosture: Duration(seconds: 590),
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
