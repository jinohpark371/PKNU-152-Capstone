class JournalData {
  const JournalData({
    this.isGoal = false,
    required this.start,
    required this.end,
    this.workTime = Duration.zero,
    this.goodPose = Duration.zero,
    this.focusTime = Duration.zero,
    this.badPose = Duration.zero,
    this.breakTime = Duration.zero,
  });

  const JournalData.empty({required this.start})
    : isGoal = false,
      end = start,
      workTime = Duration.zero,
      goodPose = Duration.zero,
      focusTime = Duration.zero,
      badPose = Duration.zero,
      breakTime = Duration.zero;

  final bool isGoal;
  final DateTime start;
  final DateTime end;
  final Duration workTime;
  final Duration goodPose;
  final Duration focusTime;
  final Duration badPose;
  final Duration breakTime;

  double get goodRatio => workTime.inMinutes == 0 ? 0.0 : goodPose.inSeconds / workTime.inSeconds;
}
