import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ohmo/db/tables.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import '../const/colors.dart';
import '../services/category_service.dart';
import '../services/day_log_service.dart';
import '../services/routine_service.dart';
import '../services/todo_service.dart';
import 'drift_database.dart' as db;

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

  Future<Category?> getCategoryById(int id) {
    return (select(categories)
      ..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteCategoryById(int id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateChildrenOnCategoryDelete(int categoryId) {
    return transaction(() async {
      await (update(routines)
        ..where((tbl) => tbl.categoryId.equals(categoryId))).write(
        RoutinesCompanion(
          colorType: Value(ColorType.uncategorizedBlack.index),
          categoryId: const Value(null),
        ),
      );

      await (update(todos)
        ..where((tbl) => tbl.categoryId.equals(categoryId))).write(
        TodosCompanion(
          colorType: Value(ColorType.uncategorizedBlack.index),
          categoryId: const Value(null),
        ),
      );
    });
  }

  Future<List<Category>> getAllCategories(String type) {
    return (select(categories)..where((c) => c.type.equals(type))).get();
  }

  Future<int> insertCategory({
    required String name,
    required String type,
    required String color,
    int? serverCategoryId,
    bool isSynced = false,
  }) {
    return into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        type: type,
        color: color,
        categoryId: Value(serverCategoryId),
        serverId: drift.Value(serverCategoryId),
        isSynced: drift.Value(isSynced),
      ),
    );
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

  Future<void> deleteCategoryWithChildren(int categoryId) {
    return transaction(() async {
      await (delete(routines)
        ..where((tbl) => tbl.categoryId.equals(categoryId))).go();

      await (delete(todos)
        ..where((tbl) => tbl.categoryId.equals(categoryId))).go();

      await (delete(categories)..where((t) => t.id.equals(categoryId))).go();
    });
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

  Future<int> updateCategoryServerId(int id, int serverId) {
    return (update(categories)..where(
      (t) => t.id.equals(id),
    )).write(CategoriesCompanion(categoryId: Value(serverId)));
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
    return (select(routines)..where(
      (tbl) =>
          tbl.groupId.equals(groupId) &
          tbl.isDeleted.equals(false) &
          tbl.startDate.isSmallerOrEqualValue(dateOnly) &
          tbl.endDate.isBiggerOrEqualValue(dateOnly) &
          tbl.weekDays.like('%$weekDayString%'),
    )).watch();
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
    return (select(routines)..where(
      (tbl) => tbl.groupId.isNull() & tbl.isDeleted.equals(false),
    )).get();
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
    return (select(routines)..where(
      (t) => t.scheduleType.equals(scheduleType) & t.isDeleted.equals(false),
    )).get();
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

  Future<void> softDeleteRoutine(int id, bool isGuest) async {
    if (isGuest) {
      await (update(routines)..where((t) => t.id.equals(id))).write(
        const RoutinesCompanion(isDeleted: Value(true), isSynced: Value(false)),
      );
    } else {
      await (delete(routines)..where((t) => t.id.equals(id))).go();
    }
  }

  // ------------------Todo------------------

  Future<List<Todo>> getPersonalTodosByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(todos)..where(
      (tbl) =>
          tbl.date.isBetweenValues(startOfDay, endOfDay) &
          tbl.groupId.isNull() &
          tbl.isDeleted.equals(false),
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
    if (query.isEmpty) return [];
    final normalizedQuery = '%${query.toLowerCase()}%';
    final foundTodos =
        await (select(todos)
          ..where((t) => t.content.lower().like(normalizedQuery))).get();
    final foundRoutines =
        await (select(routines)
          ..where((r) => r.content.lower().like(normalizedQuery))).get();
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
            if (asInt != null) return asInt;
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

  Future<void> updateLocalColor(int groupId, ColorType color, String groupName) async {
    await into(groups).insertOnConflictUpdate(
      GroupsCompanion.insert(
        id: drift.Value(groupId),
        name: groupName,
        localColor: color.name,
      ),
    );
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

  Stream<List<db.Notification>> watchAllNotifications() {
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

  // ------------------ Sync Logic ------------------

  Future<void> syncCategoriesToServer() async {
    final categoryService = CategoryService();
    try {
      final routineServerCats = await categoryService.getCategories('ROUTINE');
      final todoServerCats = await categoryService.getCategories('TO_DO');
      final allServerCats = [...routineServerCats, ...todoServerCats];
      var allLocalCategories = await select(categories).get();
      if (allLocalCategories.isEmpty) {
        await insertCategory(
          name: 'default',
          type: 'ROUTINE',
          color: '#000000',
        );
        await insertCategory(name: 'default', type: 'TO_DO', color: '#000000');
        allLocalCategories = await select(categories).get();
      }
      for (var localCat in allLocalCategories) {
        if (localCat.name.length > 10 && localCat.name != 'default') continue;
        final serverMatch = allServerCats.firstWhere(
          (s) =>
              (s['categoryName'] ?? s['name']).toString().toLowerCase() ==
                  localCat.name.toLowerCase() &&
              s['scheduleType'] == localCat.type,
          orElse: () => null,
        );
        if (serverMatch != null) {
          final int sId =
              (serverMatch['categoryId'] ?? serverMatch['id']) as int;
          await (update(categories)
            ..where((tbl) => tbl.id.equals(localCat.id))).write(
            CategoriesCompanion(
              serverId: Value(sId),
              categoryId: Value(sId),
              isSynced: const Value(true),
            ),
          );
        } else if (!localCat.isSynced) {
          final int? assignedServerId = await categoryService.createCategory(
            categoryName: localCat.name,
            color: localCat.color,
            scheduleType: localCat.type,
          );
          if (assignedServerId != null) {
            await (update(categories)
              ..where((tbl) => tbl.id.equals(localCat.id))).write(
              CategoriesCompanion(
                serverId: Value(assignedServerId),
                categoryId: Value(assignedServerId),
                isSynced: const Value(true),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('카테고리 동기화 에러: $e');
    }
  }

  Future<void> syncTodosToServer() async {
    final todoService = TodoService();
    final deletedTodos =
        await (select(todos)..where((tbl) => tbl.isDeleted.equals(true))).get();
    for (var t in deletedTodos) {
      if (t.todoServerId != null && t.todoServerId != 0)
        await todoService.deleteTodo(t.todoServerId!);
      await (delete(todos)..where((tbl) => tbl.id.equals(t.id))).go();
    }
    final unsyncedTodos =
        await (select(todos)..where(
          (tbl) => tbl.isSynced.equals(false) & tbl.isDeleted.equals(false),
        )).get();
    for (var todo in unsyncedTodos) {
      try {
        var category =
            await (select(categories)..where(
              (tbl) => tbl.id.equals(todo.categoryId ?? -1),
            )).getSingleOrNull();
        if (category == null || category.serverId == null)
          category =
              await (select(categories)..where(
                (tbl) => tbl.name.equals('default') & tbl.type.equals('TO_DO'),
              )).getSingleOrNull();
        if (category == null || category.serverId == null) continue;
        if (todo.todoServerId == null || todo.todoServerId == 0) {
          final int? sId = await todoService.registerTodo(
            categoryId: category.serverId!,
            content: todo.content,
            date: DateFormat('yyyy-MM-dd').format(todo.date),
            time: _formatTime(todo.timeMinutes),
            alarm: todo.alarmMinutes != null,
          );
          if (sId != null) {
            await (update(todos)..where((tbl) => tbl.id.equals(todo.id))).write(
              TodosCompanion(
                scheduleId: Value(sId),
                todoServerId: Value(sId),
                categoryId: Value(category.id),
              ),
            );
          }
        } else {
          await todoService.updateTodo(
            scheduleId: todo.scheduleId!,
            categoryId: category.serverId!,
            content: todo.content,
            date: DateFormat('yyyy-MM-dd').format(todo.date),
            time: _formatTime(todo.timeMinutes),
            alarmTime:
                todo.alarmMinutes != null
                    ? _formatTime(todo.timeMinutes)
                    : null,
          );
        }
        if (todo.todoServerId != null)
          await todoService.toggleTodoStatus(todo.todoServerId!);
        await (update(todos)..where(
          (tbl) => tbl.id.equals(todo.id),
        )).write(const TodosCompanion(isSynced: Value(true)));
      } catch (e) {
        print('투두 동기화 실패: $e');
      }
    }
  }

  Future<void> syncRoutinesToServer() async {
    final routineService = RoutineService();
    final unsyncedRoutines =
        await (select(routines)..where(
          (tbl) => tbl.isSynced.equals(false) & tbl.isDeleted.equals(false),
        )).get();
    for (var routine in unsyncedRoutines) {
      try {
        int? currentServerId = routine.routineId;
        if (currentServerId == null || currentServerId == 0) {
          final sIds = await routineService.registerRoutine(
            categoryId: routine.categoryId ?? 1,
            content: routine.content,
            time: _formatTime(routine.timeMinutes) ?? "00:00",
            routineWeek: _convertWeekDaysToEng(routine.weekDays),
            color: "FF69B4",
            date: DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.now().add(Duration(days: 365))),
            alarmTime: "",
          );
          if (sIds != null) {
            currentServerId = sIds['routineId'];
            await (update(routines)
              ..where((tbl) => tbl.id.equals(routine.id))).write(
              RoutinesCompanion(
                id: Value(routine.id),
                routineId: Value(currentServerId),
                scheduleId: Value(sIds['scheduleId']),
                isSynced: const Value(true),
              ),
            );
          } else {
            continue;
          }
        }
        final records =
            await (select(completedRoutines)
              ..where((tbl) => tbl.routineId.equals(routine.id))).get();
        if (currentServerId != null && records.isNotEmpty) {
          final isToggleSuccess = await routineService.toggleRoutineStatus(
            currentServerId,
          );
        }
        await (update(routines)..where(
          (tbl) => tbl.id.equals(routine.id),
        )).write(const RoutinesCompanion(isSynced: Value(true)));
      } catch (e) {}
    }
  }

  Future<void> syncDayLogsToServer() async {
    final dayLogService = DayLogService();
    final localQuestions = await select(dayLogQuestions).get();
    final serverQuestionsResponse = await dayLogService.getQuestions();
    Set<String> serverContents = {};
    if (serverQuestionsResponse != null) {
      for (var sq in serverQuestionsResponse) {
        serverContents.add((sq['questionContent'] ?? '').trim());
      }
    }
    for (var lq in localQuestions) {
      if (!serverContents.contains(lq.question.trim())) {
        await dayLogService.registerQuestion(
          questionContent: lq.question,
          emoji: lq.emoji,
        );
      }
    }
    final allLogs = await select(dayLogs).get();
    final finalServerQuestions = await dayLogService.getQuestions();
    for (var log in allLogs) {
      final dateStr = DateFormat('yyyy-MM-dd').format(log.date);
      try {
        if (log.emotion != null)
          await dayLogService.registerEmoji(date: dateStr, emoji: log.emotion!);
        if (log.diary != null && log.diary!.isNotEmpty)
          await dayLogService.registerDiary(date: dateStr, content: log.diary!);
        if (log.answerMapJson != null && finalServerQuestions != null) {
          final Map<String, dynamic> answers = jsonDecode(log.answerMapJson!);
          for (var entry in answers.entries) {
            try {
              final target = finalServerQuestions.firstWhere((sq) {
                final String qContent = sq['questionContent'] ?? '';
                final String qEmoji = sq['emoji'] ?? '';
                final String combined =
                    qEmoji.isNotEmpty ? '$qEmoji $qContent' : qContent;
                return combined.trim() == entry.key.trim();
              });
              await dayLogService.registerAnswer(
                questionId: target['id'],
                answer: entry.value.toString(),
                date: dateStr,
              );
            } catch (e) {
              print('질문 매칭 실패: ${entry.key}');
            }
          }
        }
      } catch (e) {
        print('$dateStr 데이로그 동기화 에러: $e');
      }
    }
  }
}

String? _formatTime(int? minutes) {
  if (minutes == null) return null;
  final int hours = minutes ~/ 60;
  final int mins = minutes % 60;
  return "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}";
}

List<String> _convertWeekDaysToEng(String? weekDaysStr) {
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
      .map((d) => map[d.trim()] ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

class LocalDatabaseSingleton {
  static final LocalDatabase _instance = LocalDatabase();

  static LocalDatabase get instance => _instance;
}
