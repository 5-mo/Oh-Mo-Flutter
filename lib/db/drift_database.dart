import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ohmo/db/tables.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../const/colors.dart';

part 'drift_database.g.dart';

class MemberInfo {
  final int userId;
  final String nickname;
  final String role;

  MemberInfo({
    required this.userId,
    required this.nickname,
    required this.role,
  });
}

// ------------------ DB 연결 ------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(p.join(dbFolder.path, 'ohmo.sqlite'));

    return NativeDatabase(file);
  });
}

enum Emotion { happy, soso, bad, none }

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
    Notices,
    Groups,
    GroupMembers,
    Notifications,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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

  Future<void> updateCategoryAndChildrenColor({
    required int categoryId,
    required ColorType newColor,
  }) {
    return transaction(() async {
      final newColorName = newColor.name;
      final newColorIndex = newColor.index;

      await (update(categories)..where(
        (c) => c.id.equals(categoryId),
      )).write(CategoriesCompanion(color: Value(newColorName)));

      await (update(routines)..where(
        (r) => r.categoryId.equals(categoryId),
      )).write(RoutinesCompanion(colorType: Value(newColorIndex)));

      await (update(todos)..where(
        (t) => t.categoryId.equals(categoryId),
      )).write(TodosCompanion(colorType: Value(newColorIndex)));
    });
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

  Stream<List<Routine>> watchRoutinesByGroupId(
    int groupId,
    DateTime selectedDate,
  ) {
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final weekDayString = selectedDate.weekday.toString();

    return (select(routines)
          ..where((tbl) => tbl.groupId.equals(groupId))
          ..where(
            (tbl) =>
                (tbl.startDate.isSmallerOrEqualValue(dateOnly)) &
                (tbl.endDate.isBiggerOrEqualValue(dateOnly)),
          )
          ..where((tbl) => tbl.weekDays.like('$weekDayString')))
        .watch();
  }

  Future<int?> getMemberCountInGroup(int groupId) async {
    final countExp = countAll();
    final query =
        selectOnly(groupMembers)
          ..addColumns([countExp])
          ..where(groupMembers.groupId.equals(groupId));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result;
  }

  Future<int?> getCompletionCount(int routineId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final countExp = countAll();
    final query =
        selectOnly(completedRoutines)
          ..addColumns([countExp])
          ..where(
            completedRoutines.routineId.equals(routineId) &
                completedRoutines.date.equals(dateOnly),
          );
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result;
  }

  Future<List<Routine>> getRoutinesByGroupId(int groupId) {
    return (select(routines)
      ..where((tbl) => tbl.groupId.equals(groupId))).get();
  }

  Future<List<Routine>> getPersonalRoutines() {
    return (select(routines)..where((tbl) => tbl.groupId.isNull())).get();
  }

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

  Future<void> deactivateRoutine(int routineId, DateTime selectedDate) async {
    final dayBefore = selectedDate.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dayBefore.year, dayBefore.month, dayBefore.day);

    await (update(routines)..where(
      (tbl) => tbl.id.equals(routineId),
    )).write(RoutinesCompanion(endDate: Value(dateOnly)));
  }

  // ------------------Todo------------------

  Future<List<Todo>> getPersonalTodosByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(todos)..where(
      (tbl) =>
          tbl.date.isBetweenValues(startOfDay, endOfDay) & tbl.groupId.isNull(),
    )).get();
  }

  Future<int> insertTodo(TodosCompanion entry) => into(todos).insert(entry);

  Future<int> updateTodo(TodosCompanion entry) async {
    if (entry.id == const Value.absent()) {
      throw ArgumentError('id is required for updateTodo');
    }

    final id = entry.id!.value;

    return (update(todos)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> updateTodoDate(int id, DateTime newDate) {
    return (update(todos)..where(
      (tbl) => tbl.id.equals(id),
    )).write(TodosCompanion(date: Value(newDate)));
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

  Future<List<Todo>> getTodosBetween(DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return (select(todos)
          ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay))
          ..where((t) => t.groupId.isNull()))
        .get();
  }

  Future<void> updateTodoCompletion(int id, bool isDone) {
    return (update(todos)..where(
      (tbl) => tbl.id.equals(id),
    )).write(TodosCompanion(isDone: Value(isDone)));
  }

  Future<int?> getTodoCompletionCount(int todoId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final countExp = countAll();
    final query =
        selectOnly(completedTodos)
          ..addColumns([countExp])
          ..where(
            completedTodos.todoId.equals(todoId) &
                completedTodos.date.equals(dateOnly),
          );
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result;
  }

  Future<List<Todo>> getTodosByGroupIdAndDate(int groupId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(todos)
          ..where((tbl) => tbl.groupId.equals(groupId))
          ..where((tbl) => tbl.date.isBetweenValues(startOfDay, endOfDay)))
        .get();
  }

  Future<List<Todo>> getTodosByGroupId(int groupId) {
    return (select(todos)..where((tbl) => tbl.groupId.equals(groupId))).get();
  }

  // ------------------ DayLog Entry------------------

  Future<void> upsertDayLog(DayLogsCompanion entry) {
    return into(dayLogs).insertOnConflictUpdate(entry);
  }

  Future<DayLog?> getDayLog(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return (select(dayLogs)
      ..where((tbl) => tbl.date.equals(dateOnly))).getSingleOrNull();
  }

  // ------------------ Notice ------------------

  Future<int> insertNotice(NoticesCompanion entry) {
    return into(notices).insert(entry);
  }

  Future<List<Notice>> getAllNotices() {
    return (select(notices)
          ..where((n) => n.isDeleted.equals(false))
          ..orderBy([
            (n) =>
                OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Notice?> getNoticeById(int id) {
    return (select(notices)..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  Future<int> updateNoticeContent(int id, String newContent) {
    return (update(notices)..where(
      (n) => n.id.equals(id),
    )).write(NoticesCompanion(content: Value(newContent)));
  }

  Future<int> deleteNotice(int id) {
    return (delete(notices)..where((n) => n.id.equals(id))).go();
  }

  Future<List<Notice>> getNoticesForGroup(int groupId) {
    return (select(notices)
          ..where((n) => n.groupId.equals(groupId) & n.isDeleted.equals(false))
          ..orderBy([
            (n) =>
                OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
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
      results.add({'content': todo.content, 'date': todo.date, 'type': 'todo'});
    }

    for (var routine in foundRoutines) {
      if (routine.startDate != null &&
          routine.endDate != null &&
          routine.weekDays != null) {
        final activeWeekDays = _parseWeekDays(routine.weekDays);

        if (activeWeekDays.isEmpty) continue;

        for (
          var day = routine.startDate!;
          day.isBefore(routine.endDate!.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))
        ) {
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

    results.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return results;
  }

  List<int> _parseWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null || weekDaysStr.isEmpty) return [];

    const dayMap = {
      'MONDAY': 1,
      'TUESDAY': 2,
      'WEDNESDAY': 3,
      'THURSDAY': 4,

      'FRIDAY': 5,
      'SATURDAY': 6,
      'SUNDAY': 7,
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

  // ------------------ Group------------------
  Future<Group?> getGroupById(int id) {
    return (select(groups)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  Future<int> updateGroupColor(int groupId, ColorType color) {
    return (update(groups)..where(
      (g) => g.id.equals(groupId),
    )).write(GroupsCompanion(colorType: Value(color.index)));
  }

  Future<List<Group>> getAllGroups() {
    return select(groups).get();
  }

  Future<List<Group>> getGroupsForUser(int userId) {
    final query = select(groupMembers)
      ..where((tbl) => tbl.userId.equals(userId));

    final joinQuery = query.join([
      innerJoin(groups, groups.id.equalsExp(groupMembers.groupId)),
    ]);
    return joinQuery.map((row) => row.readTable(groups)).get();
  }

  Future<String?> getMemberRole(int groupId, int userId) async {
    final member =
        await (select(groupMembers)..where(
          (tbl) => tbl.groupId.equals(groupId) & tbl.userId.equals(userId),
        )).getSingleOrNull();
    return member?.role;
  }

  Future<int> createNewGroupAndAssignOwner(
    GroupsCompanion groupData,
    int ownerId,
  ) async {
    return await transaction(() async {
      final newGroup = await into(groups).insertReturning(groupData);
      final newGroupId = newGroup.id;

      await into(groupMembers).insert(
        GroupMembersCompanion.insert(
          groupId: newGroupId,
          userId: ownerId,
          role: Value('OWNER'),
        ),
      );
      return newGroupId;
    });
  }

  Future<List<MemberInfo>> getMembersForGroup(int groupId) async {
    final query = select(groupMembers)
      ..where((gm) => gm.groupId.equals(groupId));

    final joinQuery = query.join([
      innerJoin(users, users.id.equalsExp(groupMembers.userId)),
    ]);
    final result = await joinQuery.get();

    return result.map((row) {
      final user = row.readTable(users);
      final member = row.readTable(groupMembers);
      return MemberInfo(
        userId: user.id,
        nickname: user.nickname,
        role: member.role,
      );
    }).toList();
  }

  Future<int> removeMemberFromGroup(int groupId, int userId) {
    return (delete(groupMembers)..where(
      (gm) => gm.groupId.equals(groupId) & gm.userId.equals(userId),
    )).go();
  }

  Future<void> leaveGroup(int groupId, int userId) {
    return (delete(groupMembers)..where(
      (tbl) => tbl.groupId.equals(groupId) & tbl.userId.equals(userId),
    )).go();
  }

  Future<void> deleteGroup(int groupId) {
    return transaction(() async {
      await (delete(groupMembers)
        ..where((tbl) => tbl.groupId.equals(groupId))).go();
      await (delete(routines)
        ..where((tbl) => tbl.groupId.equals(groupId))).go();

      await (delete(todos)..where((tbl) => tbl.groupId.equals(groupId))).go();

      await (delete(notices)..where((tbl) => tbl.groupId.equals(groupId))).go();
      await (delete(groups)..where((tbl) => tbl.id.equals(groupId))).go();
    });
  }

  Future<void> delegateOwnership(int groupId, int newOwnerId, int oldOwnerId) {
    return transaction(() async {
      await (update(groupMembers)..where(
        (tbl) => tbl.groupId.equals(groupId) & tbl.userId.equals(oldOwnerId),
      )).write(const GroupMembersCompanion(role: Value('MEMBER')));

      await (update(groupMembers)..where(
        (tbl) => tbl.groupId.equals(groupId) & tbl.userId.equals(newOwnerId),
      )).write(const GroupMembersCompanion(role: Value('OWNER')));
    });
  }

  Future<void> updateGroupPassword(int groupId, String newPassword) {
    return (update(groups)..where(
      (g) => g.id.equals(groupId),
    )).write(GroupsCompanion(password: Value(newPassword)));
  }

  // ------------------ Notification ------------------

  Future<int> insertNotification(NotificationsCompanion entry) {
    return into(notifications).insert(entry);
  }

  Stream<List<Notification>> watchAllNotifications() {
    return (select(notifications)..orderBy([
      (n) => OrderingTerm(expression: n.timestamp, mode: OrderingMode.desc),
    ])).watch();
  }

  Future<int> markAllNotificationsAsRead() {
    return (update(notifications)..where(
      (n) => n.isRead.equals(false),
    )).write(const NotificationsCompanion(isRead: Value(true)));
  }

  Stream<int> watchUnreadNotificationCount() {
    final unreadCount = countAll(filter: notifications.isRead.equals(false));
    final query = selectOnly(notifications)..addColumns([unreadCount]);

    return query.map((row) => row.read(unreadCount)!).watchSingle();
  }
}

// ------------------ Singleton ------------------

class LocalDatabaseSingleton {
  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;
}
