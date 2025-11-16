part of 'journal_bloc.dart';

@immutable
sealed class JournalEvent {
  const JournalEvent();
}

final class FetchAllJournalData extends JournalEvent {}

final class GetData extends JournalEvent {
  const GetData(int year, int month, int day);
  GetData.fromDateTime(DateTime date) : this(date.year, date.month, date.day);
  GetData.fromOffset(DateTime base, int offset)
    : this.fromDateTime(DateTime(base.year, base.month, base.day).add(Duration(days: offset)));
}

final class DateSelected extends JournalEvent {
  final DateTime? date;

  const DateSelected({this.date});
}
