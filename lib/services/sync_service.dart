import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/services/todo_service.dart';
import '../db/drift_database.dart';
import 'routine_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();

  factory SyncService() => _instance;

  SyncService._internal();

  final _db = LocalDatabaseSingleton.instance;
  final _routineService = RoutineService();
  final _todoService = TodoService();
  final Connectivity _connectivity = Connectivity();

  void monitorNetwork() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        syncUnsyncedRoutines();
        syncUnsyncedTodos();
      }
    });
  }

  Future<void> syncUnsyncedTodos() async {
    final unSyncedTodos =
        await (_db.select(_db.todos)
          ..where((t) => t.isSynced.equals(false))).get();

    if (unSyncedTodos.isEmpty) return;

    final localCategories = await _db.select(_db.categories).get();

    for (var todo in unSyncedTodos) {
      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(todo.date);

        String? timeStr;
        if (todo.timeMinutes != null) {
          final h = (todo.timeMinutes! ~/ 60).toString().padLeft(2, '0');
          final m = (todo.timeMinutes! % 60).toString().padLeft(2, '0');
          timeStr = "$h:$m";
        }
        final categoryRow = localCategories.firstWhere(
          (c) => c.id == todo.categoryId,
          orElse:
              () => localCategories.firstWhere(
                (c) => c.name.toLowerCase().trim() == 'default',
                orElse: () => localCategories.first,
              ),
        );
        final int targetServerCategoryId = categoryRow.categoryId ?? 1;

        final int? serverScheduleId = await _todoService.registerTodo(
          categoryId: targetServerCategoryId,
          content: todo.content,
          date: dateStr,
          alarm: todo.timeMinutes != null,
          time: timeStr,
        );
        if (serverScheduleId != null) {
          print('투두 동기화 성공 : ${todo.content} (서버ID : $serverScheduleId)');

          await (_db.update(_db.todos)..where((t) => t.id.equals(todo.id))).write(
            TodosCompanion(
              id: Value(serverScheduleId),
              scheduleId: Value(serverScheduleId),
              todoServerId: Value(serverScheduleId),
              isSynced: const Value(true),
            ),
          );
        }
      } catch (e) {
        print("투두 동기화 실패 ${todo.content}");
      }
    }
  }

  Future<void> syncUnsyncedRoutines() async {
    final unsyncedRoutines =
        await (_db.select(_db.routines)
          ..where((t) => t.isSynced.equals(false))).get();

    if (unsyncedRoutines.isEmpty) return;

    final localCategories = await _db.select(_db.categories).get();

    for (var routine in unsyncedRoutines) {
      try {
        final weekList = _convertWeekDays(routine.weekDays);
        final dateStr = routine.startDate!.toIso8601String().split('T').first;

        String timeStr = "00:00:00";
        if (routine.timeMinutes != null) {
          final h = (routine.timeMinutes! ~/ 60).toString().padLeft(2, '0');
          final m = (routine.timeMinutes! % 60).toString().padLeft(2, '0');
          timeStr = "$h:$m:00";
        }

        int targetServerCategoryId = 0;
        String colorToSend = 'uncategorizedBlack';
        final categoryRow = localCategories.firstWhere(
          (c) => c.categoryId == routine.categoryId,
          orElse:
              () => localCategories.firstWhere(
                (c) => c.name.toLowerCase().trim() == 'default',
                orElse: () => localCategories.first,
              ),
        );

        targetServerCategoryId = categoryRow.categoryId ?? 0;

        if (categoryRow.name == 'default') {
          colorToSend = 'uncategorizedBlack';
        } else {
          colorToSend = categoryRow.color;
        }

        final Map<String, int?>? serverIds = await _routineService
            .registerRoutine(
              categoryId: targetServerCategoryId,
              time: timeStr,
              alarmTime: routine.alarmMinutes != null ? timeStr : null,
              content: routine.content,
              date: dateStr,
              routineWeek: weekList,
              color: colorToSend,
            );

        if (serverIds != null) {
          final int? realRoutineId = serverIds['routineId'];
          final int? realScheduleId = serverIds['scheduleId'];

          print(
            '[Sync] 동기화 성공: ${routine.content} (RoutineID: $realRoutineId, ScheduleID: $realScheduleId)',
          );
          await (_db.update(_db.routines)
            ..where((t) => t.id.equals(routine.id))).write(
            RoutinesCompanion(
              isSynced: const Value(true),
              routineId: Value(realRoutineId),
              scheduleId: Value(realScheduleId),
            ),
          );
        }
      } catch (e) {
        print("동기화 실패 (다음에 재시도): ${routine.content} / 에러: $e");
      }
    }
  }

  List<String> _convertWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null) return [];
    const map = {
      '1': 'MONDAY',
      '2': 'TUESDAY',
      '3': 'WEDNESDAY',
      '4': 'THURSDAY',
      '5': 'FRIDAY',
      '6': 'SATURDAY',
      '7': 'SUNDAY',
    };
    return weekDaysStr
        .split(',')
        .map((e) => map[e.trim()] ?? 'MONDAY')
        .toList();
  }
}
