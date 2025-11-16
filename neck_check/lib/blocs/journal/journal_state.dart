part of 'journal_bloc.dart';

@immutable
sealed class JournalState {}

final class JournalLoading extends JournalState {}

final class JournalSuccess extends JournalState {
  JournalSuccess({required this.dataList});

  final List<JournalData> dataList;

  JournalData dataByDate(DateTime date) => dataList.firstWhere((element) {
    final d = element.start;
    return d.day == date.day && d.month == date.month && d.year == date.year;
  }, orElse: () => JournalData.empty(start: date));
}
