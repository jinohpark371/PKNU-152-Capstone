class RingModel {
  const RingModel({
    required this.year,
    required this.month,
    required this.day,
    this.workTime = 0,
    this.goodPose = 0,
    this.isGoal = false,
  });

  final int year;
  final int month;
  final int day;
  final int workTime;
  final int goodPose;
  final bool isGoal;

  DateTime get date => DateTime(year, month, day);

  double get ratio => workTime == 0 ? 0.0 : goodPose / workTime;
}
