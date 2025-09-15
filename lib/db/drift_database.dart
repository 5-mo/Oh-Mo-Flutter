import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ohmo/db/tables.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_database.g.dart';

// ------------------ DB 연결 ------------------
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ohmo.sqlite'));
    return NativeDatabase(file);
  });
}

// ------------------ Drift Database ------------------
@DriftDatabase(
  tables: [
    Categories,
    DayLogQuestions,
    Routines,
    Todos,
    CompletedRoutines,
    CompletedTodos,
    DayLogs,
  ],
)

enum Emotion { happy, soso, bad, none }

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 5) {
        await m.createTable(completedTodos);
      }
      if (from < 6) {
        await m.addColumn(dayLogs, dayLogs.answerMapJson);
      }
    },
  );

  // ------------------ Category ------------------
  Future<List<Category>> getAllCategories(String type) {
    return (select(categories)..where((c) => c.type.equals(type))).get();
  }

  Future<int> insertCategory(String name, String type, String color) {
    return into(
      categories,
    ).insert(CategoriesCompanion.insert(name: name, type: type, color: color));
  }

  Future<int> updateCategoryName(int id, String newName) {
    return (update(categories)..where(
      (c) => c.id.equals(id),
    )).write(CategoriesCompanion(name: Value(newName)));
  }

  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  Future<int> softDeleteCategory(int id) {
    return (update(categories)..where(
      (c) => c.id.equals(id),
    )).write(CategoriesCompanion(isDeleted: Value(true)));
  }

  // ------------------ DayLog ------------------

  Future<List<DayLogQuestion>> getAllDayLogQuestions() {
    return select(dayLogQuestions).get();
  }

  Future<int> insertDayLogQuestion(String question, String emoji) {
    return into(dayLogQuestions).insert(
      DayLogQuestionsCompanion(question: Value(question), emoji: Value(emoji)),
    );
  }

  Future<int> updateDayLogQuestion(int id, String question, String emoji) {
    return (update(dayLogQuestions)..where((d) => d.id.equals(id))).write(
      DayLogQuestionsCompanion(question: Value(question), emoji: Value(emoji)),
    );
  }

  Future<int> deleteDayLogQuestion(int id) {
    return (delete(dayLogQuestions)..where((d) => d.id.equals(id))).go();
  }

  // ------------------ Routine ------------------
  Future<int> insertRoutine(RoutinesCompanion entry) =>
      into(routines).insert(entry);

  Future<int> updateRoutine(RoutinesCompanion entry) async {
    if (entry.id == const Value.absent()) {
      throw ArgumentError('id is required for updateRoutine');
    }
    final id = entry.id!.value;
    return (update(routines)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> toggleRoutineStatus(int id) async {
    final existing =
        await (select(routines)..where((t) => t.id.equals(id))).getSingle();
    await (update(routines)..where(
      (t) => t.id.equals(id),
    )).write(RoutinesCompanion(isDone: Value(!existing.isDone)));
  }

  Future<List<Routine>> getAllRoutines({String scheduleType = 'ROUTINE'}) {
    return (select(routines)
      ..where((t) => t.scheduleType.equals(scheduleType))).get();
  }

  Future<Routine?> getRoutineById(int id) async {
    final list = await (select(routines)..where((t) => t.id.equals(id))).get();
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> deleteRoutine(int id) =>
      (delete(routines)..where((t) => t.id.equals(id))).go();

  Future<int> insertCompletedRoutine(CompletedRoutinesCompanion entry) =>
      into(completedRoutines).insert(entry);

  Future<int> deleteCompletedRoutineByRoutineAndDate(
    int routineId,
    DateTime date,
  ) {
    final d = DateTime(date.year, date.month, date.day);
    return (delete(completedRoutines)
      ..where((c) => c.routineId.equals(routineId) & c.date.equals(d))).go();
  }

  Future<List<CompletedRoutine>> getCompletedRoutinesBetween(
    DateTime start,
    DateTime end,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return (select(completedRoutines)
      ..where((c) => c.date.isBetweenValues(s, e))).get();
  }

  Future<void> toggleRoutineCompletion(int routineId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final existing =
        await (select(completedRoutines)..where(
          (c) => c.routineId.equals(routineId) & c.date.equals(dateOnly),
        )).getSingleOrNull();

    if (existing != null) {
      await deleteCompletedRoutineByRoutineAndDate(routineId, date);
    } else {
      await insertCompletedRoutine(
        CompletedRoutinesCompanion(
          routineId: Value(routineId),
          date: Value(dateOnly),
        ),
      );
    }
  }

  Future<List<int>> getCompletedRoutineIds(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final list =
        await (select(completedRoutines)
          ..where((c) => c.date.equals(dateOnly))).get();
    return list.map((c) => c.routineId).toList();
  }

  // ------------------Todo ------------------
  Future<int> insertTodo(TodosCompanion entry) => into(todos).insert(entry);

  Future<int> updateTodo(TodosCompanion entry) async {
    if (entry.id == const Value.absent()) {
      throw ArgumentError('id is required for updateTodo');
    }
    final id = entry.id!.value;
    return (update(todos)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<List<Todo>> getAllTodos({String scheduleType = 'TO_DO'}) {
    return (select(todos)
      ..where((t) => t.scheduleType.equals(scheduleType))).get();
  }

  Future<Todo?> getTodoById(int id) async {
    final list = await (select(todos)..where((t) => t.id.equals(id))).get();
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> deleteTodo(int id) =>
      (delete(todos)..where((t) => t.id.equals(id))).go();

  Future<List<Todo>> getTodosByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return (select(todos)
      ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay))).get();
  }

  Future<void> toggleTodoStatus(int id) async {
    final existing =
        await (select(todos)..where((t) => t.id.equals(id))).getSingle();
    await (update(todos)..where(
      (t) => t.id.equals(id),
    )).write(TodosCompanion(isDone: Value(!existing.isDone)));
  }

  Future<void> toggleTodoCompletion(int todoId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final existing =
        await (select(completedTodos)..where(
          (c) => c.todoId.equals(todoId) & c.date.equals(dateOnly),
        )).getSingleOrNull();

    if (existing != null) {
      await (delete(completedTodos)
        ..where((c) => c.id.equals(existing.id))).go();
    } else {
      await into(completedTodos).insert(
        CompletedTodosCompanion(todoId: Value(todoId), date: Value(dateOnly)),
      );
    }
  }

  Future<List<int>> getCompletedTodoIds(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final list =
        await (select(completedTodos)
          ..where((c) => c.date.equals(dateOnly))).get();
    return list.map((c) => c.todoId).toList();
  }

  // ------------------ DayLog Entry------------------

  Future<void> upsertDayLog(DayLogsCompanion entry) {
    return into(dayLogs).insertOnConflictUpdate(entry);
  }

  Future<DayLog?> getDayLog(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (select(dayLogs)..where((tbl) => tbl.date.equals(dateOnly)))
        .getSingleOrNull();
  }

  // ------------------ Search------------------

  Future<List<Map<String, dynamic>>> searchSchedules(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final normalizedQuery = '%${query.toLowerCase()}%';

    final todosQuery = select(todos)
      ..where((t) => t.content.lower().like(normalizedQuery));
    final foundTodos = await todosQuery.get();

    final routinesQuery = select(routines)
      ..where((r) => r.content.lower().like(normalizedQuery));
    final foundRoutines = await routinesQuery.get();

    final List<Map<String, dynamic>> results = [];

    for (var todo in foundTodos) {
      results.add({
        'content': todo.content,
        'date': todo.date,
        'type': 'todo',
      });
    }

    for (var routine in foundRoutines) {
      if (routine.startDate != null && routine.endDate != null && routine.weekDays != null) {
        final activeWeekDays = _parseWeekDays(routine.weekDays);
        if (activeWeekDays.isEmpty) continue;

        for (var day = routine.startDate!; day.isBefore(routine.endDate!.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
          if (activeWeekDays.contains(day.weekday)) {
            results.add({
              'content': routine.content,
              'date': day,
              'type': 'routine',
            });
          }
        }
      }
    }

    results.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return results;
  }

  List<int> _parseWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null || weekDaysStr.isEmpty) return [];

    const dayMap = {
      'MONDAY': 1, 'TUESDAY': 2, 'WEDNESDAY': 3, 'THURSDAY': 4,
      'FRIDAY': 5, 'SATURDAY': 6, 'SUNDAY': 7,
    };

    try {
      return weekDaysStr
          .split(',')
          .map((e) {
        final trimmed = e.trim();
        final asInt = int.tryParse(trimmed);
        if (asInt != null) {
          return asInt;
        }
        return dayMap[trimmed.toUpperCase()] ?? 0;
      })
          .where((e) => e != 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

}

// ------------------ Singleton ------------------
class LocalDatabaseSingleton {
  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;
}
