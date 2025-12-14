import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../db/drift_database.dart';
import 'routine_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();

  factory SyncService() => _instance;

  SyncService._internal();

  final _db = LocalDatabaseSingleton.instance;
  final _routineService = RoutineService();
  final Connectivity _connectivity = Connectivity();

  void monitorNetwork() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        syncUnsyncedRoutines();
      }
    });
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

        int targetCategoryId = routine.categoryId ?? 0;

        final serverId = await _routineService.registerRoutine(
          categoryId: targetCategoryId,
          time: timeStr,
          alarmTime: routine.alarmMinutes != null ? timeStr : null,
          content: routine.content,
          date: dateStr,
          routineWeek: weekList,
        );

        if (serverId != null) {
          await (_db.update(_db.routines)
            ..where((t) => t.id.equals(routine.id))).write(
            RoutinesCompanion(
              isSynced: Value(true),
              routineId: Value(serverId),
            ),
          );
        } else {
          await (_db.update(_db.routines)..where(
            (t) => t.id.equals(routine.id),
          )).write(RoutinesCompanion(isSynced: Value(true)));
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
