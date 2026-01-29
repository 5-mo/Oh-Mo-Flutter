import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text()();
}

class Groups extends Table{
  IntColumn get id=>integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get colorType=>integer().withDefault(const Constant(0))();
  IntColumn get maxMembers=>integer().nullable()();
  TextColumn get password=>text().nullable()();
}

class GroupMembers extends Table {
  IntColumn get groupId => integer().references(Groups, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get role => text().withDefault(const Constant('MEMBER'))();

  @override
  Set<Column> get primaryKey => {groupId, userId};
}

class Notices extends Table{
  IntColumn get groupId => integer().references(Groups, #id).nullable()();
  IntColumn get id=>integer().autoIncrement()();
  TextColumn get content=>text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get authorName=>text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get noticeDate=>dateTime()();
}

class Categories extends Table{
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId=>integer().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get color => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get serverId=>integer().nullable()();
  BoolColumn get isSynced=>boolean().withDefault(const Constant(false))();
}

class DayLogQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get question => text()();
  TextColumn get emoji => text().withDefault(const Constant('🙂'))();
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleId=>integer().nullable()();
  IntColumn get routineId => integer().nullable()();
  IntColumn get groupId => integer().references(Groups, #id).nullable()();
  TextColumn get content => text()();
  IntColumn get colorType => integer().withDefault(const Constant(0))();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();
  DateTimeColumn get endDate => dateTime().named('end_date').nullable()();
  IntColumn get timeMinutes => integer().nullable()();
  TextColumn get weekDays => text().nullable()();
  TextColumn get scheduleType => text().withDefault(const Constant('ROUTINE'))();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get alarmMinutes => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced=>boolean().withDefault(const Constant(true))();
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleId=>integer().nullable()();
  IntColumn get groupId => integer().references(Groups, #id).nullable()();
  TextColumn get content => text()();
  IntColumn get colorType => integer().withDefault(const Constant(0))();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get timeMinutes => integer().nullable()();
  TextColumn get scheduleType => text().withDefault(const Constant('TO_DO'))();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get alarmMinutes => integer().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get todoServerId=>integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced=>boolean().withDefault(const Constant(true))();
}

class CompletedRoutines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer()();
  DateTimeColumn get date => dateTime()();
}

class CompletedTodos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get todoId => integer()();
  DateTimeColumn get date => dateTime()();
}

class DayLogs extends Table {
  DateTimeColumn get date => dateTime()();
  TextColumn get emotion => text().nullable()();
  TextColumn get answerMapJson => text().nullable()();
  TextColumn get diary => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

class Notifications extends Table{
  IntColumn get id=>integer().autoIncrement()();
  TextColumn get type=>text()();

  TextColumn get content=>text()();
  DateTimeColumn get timestamp=>dateTime()();
  IntColumn get relatedId=>integer().nullable()();

  BoolColumn get isRead=>boolean().withDefault(const Constant(false))();
}