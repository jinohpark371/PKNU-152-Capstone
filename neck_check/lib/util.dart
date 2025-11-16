String weekday(int index) => const ['일', '월', '화', '수', '목', '금', '토'][index];

String weekdayByDate(DateTime date) => weekday(date.weekday % 7);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return '$h시간 $m분';
}
