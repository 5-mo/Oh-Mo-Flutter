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
  tables: [Categories, DayLogQuestions, Routines, Todos, CompletedRoutines, CompletedTodos],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(routines, routines.scheduleType);
      }
      if (from < 5) {
        await m.createTable(completedTodos);
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

    final existing = await (select(completedRoutines)
      ..where((c) => c.routineId.equals(routineId) & c.date.equals(dateOnly)))
        .getSingleOrNull();

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
    final list = await (select(completedRoutines)
      ..where((c) => c.date.equals(dateOnly)))
        .get();
    return list.map((c) => c.routineId).toList();
  }


  // ------------------ Todo ------------------
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

    final existing = await (select(completedTodos)
      ..where((c) => c.todoId.equals(todoId) & c.date.equals(dateOnly)))
        .getSingleOrNull();

    if (existing != null) {
      await (delete(completedTodos)..where((c) => c.id.equals(existing.id))).go();
    } else {
      await into(completedTodos).insert(
        CompletedTodosCompanion(
          todoId: Value(todoId),
          date: Value(dateOnly),
        ),
      );
    }
  }

  // 특정 날짜에 완료된 투두 ID 목록을 가져오는 함수
  Future<List<int>> getCompletedTodoIds(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final list =
    await (select(completedTodos)..where((c) => c.date.equals(dateOnly))).get();
    return list.map((c) => c.todoId).toList();
  }
}

// ------------------ Singleton ------------------
class LocalDatabaseSingleton {
  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;
}
