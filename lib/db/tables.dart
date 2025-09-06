import 'package:drift/drift.dart';

class Categories extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get color => text()();
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))();
}

class DayLogQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get question => text()();
  TextColumn get emoji => text().withDefault(const Constant('🙂'))();
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get colorType => integer().withDefault(Constant(0))();
  BoolColumn get isDone => boolean().withDefault(Constant(false))();
  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();
  DateTimeColumn get endDate => dateTime().named('end_date').nullable()();
  IntColumn get timeMinutes => integer().nullable()();
  TextColumn get weekDays => text().nullable()();
  TextColumn get scheduleType => text().withDefault(Constant('ROUTINE'))();
  IntColumn get categoryId => integer().nullable()();
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  IntColumn get colorType => integer().withDefault(Constant(0))();
  BoolColumn get isDone => boolean().withDefault(Constant(false))();
  IntColumn get timeMinutes => integer().nullable()();
  TextColumn get scheduleType => text().withDefault(Constant('TO_DO'))();
  IntColumn get categoryId => integer().nullable()();

  DateTimeColumn get date => dateTime()();
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