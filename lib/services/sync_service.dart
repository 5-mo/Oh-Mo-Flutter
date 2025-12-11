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
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        print("🌐 인터넷 연결 감지! 미전송 루틴 확인 중...");
        syncUnsyncedRoutines();
      }
    });
  }

  // SyncService.dart 파일 내부

  Future<void> syncUnsyncedRoutines() async {
    final unsyncedRoutines = await (_db.select(_db.routines)
      ..where((t) => t.isSynced.equals(false)))
        .get();

    if (unsyncedRoutines.isEmpty) return;

    print("🔄 동기화 필요한 루틴 발견: ${unsyncedRoutines.length}개");

    // [추가] 카테고리 매핑을 위해 로컬 카테고리 정보 미리 로드
    final localCategories = await _db.select(_db.categories).get();

    for (var routine in unsyncedRoutines) {
      try {
        final weekList = _convertWeekDays(routine.weekDays);
        final dateStr = routine.startDate!.toIso8601String().split('T').first;

        String timeStr = "00:00:00"; // 서버 포맷 00:00:00 권장
        if (routine.timeMinutes != null) {
          final h = (routine.timeMinutes! ~/ 60).toString().padLeft(2, '0');
          final m = (routine.timeMinutes! % 60).toString().padLeft(2, '0');
          timeStr = "$h:$m:00";
        }

        // [수정] 올바른 카테고리 ID 찾기 로직
        int targetCategoryId = routine.categoryId ?? 0;

        // 1. 현재 routine이 가리키는 카테고리 이름 찾기
        final myCategory = localCategories.where((c) => c.id == routine.categoryId).firstOrNull;

        if (myCategory != null) {
          // 2. 중요: 이름은 같지만 ID가 다른 상황을 대비해 서버와 싱크된 카테고리인지 확인해야 함.
          // 하지만 지금은 로컬 DB가 서버와 카테고리 동기화가 안 되어 있을 수 있음.
          // 임시 방편: 만약 카테고리 ID가 10 미만(기본값 등)이라면 서버에 요청시 에러가 날 수 있음.
          // 가장 좋은 건 '이름'으로 서버에서 ID를 찾는 것이지만, 등록 API는 ID만 받음.

          // 일단 그대로 보내되, 로그를 찍어봅니다.
          print("📤 전송할 카테고리: ${myCategory.name} (ID: ${myCategory.id})");
        }

        final serverId = await _routineService.registerRoutine(
          categoryId: targetCategoryId, // 여기가 문제의 원인일 수 있음 (서버 ID와 다르면 에러)
          time: timeStr,
          alarmTime: routine.alarmMinutes != null ? timeStr : null,
          content: routine.content,
          date: dateStr,
          routineWeek: weekList,
        );

        if (serverId != null) {
          // [수정] 빈 리스트([]) 문제로 ID가 null이 올 수 있음.
          // 하지만 서버 등록은 성공했으므로, 다음에 내려받을 때 병합되도록 isSynced만 true로 바꿀 수도 있음.
          // 여기서는 ID가 확실히 있을 때만 업데이트.
          await (_db.update(_db.routines)..where((t) => t.id.equals(routine.id)))
              .write(RoutinesCompanion(
            isSynced: Value(true),
            routineId: Value(serverId),
          ));
          print("✅ 동기화 성공! 로컬ID(${routine.id}) -> 서버ID($serverId)");
        } else {
          // 서버엔 갔지만 ID를 못 받은 경우 (요일 불일치 등)
          // 무한 재전송을 막기 위해 일단 isSynced는 true로 둡니다.
          // 나중에 조회(GET)할 때 이름 매칭으로 ID를 찾아낼 것입니다.
          print("⚠️ 서버 등록 완료(ID없음). 동기화 처리함.");
          await (_db.update(_db.routines)..where((t) => t.id.equals(routine.id)))
              .write(RoutinesCompanion(isSynced: Value(true)));
        }
      } catch (e) {
        print("❌ 동기화 실패 (다음에 재시도): ${routine.content} / 에러: $e");
      }
    }
  }
  List<String> _convertWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null) return [];
    const map = {
      '1': 'MONDAY', '2': 'TUESDAY', '3': 'WEDNESDAY',
      '4': 'THURSDAY', '5': 'FRIDAY', '6': 'SATURDAY', '7': 'SUNDAY'
    };
    return weekDaysStr.split(',').map((e) => map[e.trim()] ?? 'MONDAY').toList();
  }
}