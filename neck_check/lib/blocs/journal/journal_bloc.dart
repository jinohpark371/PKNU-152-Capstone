import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:neck_check/models/journal_data.dart';
import 'package:neck_check/models/mock_data.dart';

part 'journal_event.dart';
part 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc() : super(JournalLoading()) {
    on<JournalEvent>((event, emit) async {});

    on<FetchAllJournalData>((event, emit) async {
      // 데이터 가져오기
      final dataList = await Future<List<JournalData>>.delayed(
        Duration(seconds: 5),
        () => mockReport,
      );
      emit(JournalSuccess(dataList: dataList));
    });
  }
}
