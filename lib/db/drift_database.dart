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
@DriftDatabase(tables: [Categories, DayLogQuestions, Routines, Todos])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        await m.addColumn(routines, routines.scheduleType);
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

  // ------------------ Todo ------------------
  Future<int> insertTodo(TodosCompanion entry) => into(todos).insert(entry);

  Future<int> updateTodo(TodosCompanion entry) async {
    if (entry.id == const Value.absent()) {
      throw ArgumentError('id is required for updateTodo');
    }
    final id = entry.id!.value;
    return (update(todos)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> toggleTodoStatus(int id) async {
    final existing =
        await (select(todos)..where((t) => t.id.equals(id))).getSingle();
    await (update(todos)..where(
      (t) => t.id.equals(id),
    )).write(TodosCompanion(isDone: Value(!existing.isDone)));
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
}

// ------------------ Singleton ------------------
class LocalDatabaseSingleton {
  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;
}
