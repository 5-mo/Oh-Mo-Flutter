// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, color, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      color:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color'],
          )!,
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  final String color;
  final bool isDeleted;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['color'] = Variable<String>(color);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      color: Value(color),
      isDeleted: Value(isDeleted),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String>(json['color']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String>(color),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    String? color,
    bool? isDeleted,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    color: color ?? this.color,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, color, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.isDeleted == this.isDeleted);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> color;
  final Value<bool> isDeleted;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required String color,
    this.isDeleted = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       color = Value(color);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? color,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? color,
    Value<bool>? isDeleted,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $DayLogQuestionsTable extends DayLogQuestions
    with TableInfo<$DayLogQuestionsTable, DayLogQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🙂'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, question, emoji];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_log_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLogQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayLogQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLogQuestion(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      question:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}question'],
          )!,
      emoji:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}emoji'],
          )!,
    );
  }

  @override
  $DayLogQuestionsTable createAlias(String alias) {
    return $DayLogQuestionsTable(attachedDatabase, alias);
  }
}

class DayLogQuestion extends DataClass implements Insertable<DayLogQuestion> {
  final int id;
  final String question;
  final String emoji;
  const DayLogQuestion({
    required this.id,
    required this.question,
    required this.emoji,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question'] = Variable<String>(question);
    map['emoji'] = Variable<String>(emoji);
    return map;
  }

  DayLogQuestionsCompanion toCompanion(bool nullToAbsent) {
    return DayLogQuestionsCompanion(
      id: Value(id),
      question: Value(question),
      emoji: Value(emoji),
    );
  }

  factory DayLogQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLogQuestion(
      id: serializer.fromJson<int>(json['id']),
      question: serializer.fromJson<String>(json['question']),
      emoji: serializer.fromJson<String>(json['emoji']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'question': serializer.toJson<String>(question),
      'emoji': serializer.toJson<String>(emoji),
    };
  }

  DayLogQuestion copyWith({int? id, String? question, String? emoji}) =>
      DayLogQuestion(
        id: id ?? this.id,
        question: question ?? this.question,
        emoji: emoji ?? this.emoji,
      );
  DayLogQuestion copyWithCompanion(DayLogQuestionsCompanion data) {
    return DayLogQuestion(
      id: data.id.present ? data.id.value : this.id,
      question: data.question.present ? data.question.value : this.question,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLogQuestion(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, question, emoji);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLogQuestion &&
          other.id == this.id &&
          other.question == this.question &&
          other.emoji == this.emoji);
}

class DayLogQuestionsCompanion extends UpdateCompanion<DayLogQuestion> {
  final Value<int> id;
  final Value<String> question;
  final Value<String> emoji;
  const DayLogQuestionsCompanion({
    this.id = const Value.absent(),
    this.question = const Value.absent(),
    this.emoji = const Value.absent(),
  });
  DayLogQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required String question,
    this.emoji = const Value.absent(),
  }) : question = Value(question);
  static Insertable<DayLogQuestion> custom({
    Expression<int>? id,
    Expression<String>? question,
    Expression<String>? emoji,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (question != null) 'question': question,
      if (emoji != null) 'emoji': emoji,
    });
  }

  DayLogQuestionsCompanion copyWith({
    Value<int>? id,
    Value<String>? question,
    Value<String>? emoji,
  }) {
    return DayLogQuestionsCompanion(
      id: id ?? this.id,
      question: question ?? this.question,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorTypeMeta = const VerificationMeta(
    'colorType',
  );
  @override
  late final GeneratedColumn<int> colorType = GeneratedColumn<int>(
    'color_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeMinutesMeta = const VerificationMeta(
    'timeMinutes',
  );
  @override
  late final GeneratedColumn<int> timeMinutes = GeneratedColumn<int>(
    'time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekDaysMeta = const VerificationMeta(
    'weekDays',
  );
  @override
  late final GeneratedColumn<String> weekDays = GeneratedColumn<String>(
    'week_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ROUTINE'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alarmMinutesMeta = const VerificationMeta(
    'alarmMinutes',
  );
  @override
  late final GeneratedColumn<int> alarmMinutes = GeneratedColumn<int>(
    'alarm_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    colorType,
    isDone,
    startDate,
    endDate,
    timeMinutes,
    weekDays,
    scheduleType,
    categoryId,
    alarmMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('color_type')) {
      context.handle(
        _colorTypeMeta,
        colorType.isAcceptableOrUnknown(data['color_type']!, _colorTypeMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('time_minutes')) {
      context.handle(
        _timeMinutesMeta,
        timeMinutes.isAcceptableOrUnknown(
          data['time_minutes']!,
          _timeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('week_days')) {
      context.handle(
        _weekDaysMeta,
        weekDays.isAcceptableOrUnknown(data['week_days']!, _weekDaysMeta),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('alarm_minutes')) {
      context.handle(
        _alarmMinutesMeta,
        alarmMinutes.isAcceptableOrUnknown(
          data['alarm_minutes']!,
          _alarmMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      colorType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}color_type'],
          )!,
      isDone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_done'],
          )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      timeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_minutes'],
      ),
      weekDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_days'],
      ),
      scheduleType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}schedule_type'],
          )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      alarmMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_minutes'],
      ),
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final int id;
  final String content;
  final int colorType;
  final bool isDone;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? timeMinutes;
  final String? weekDays;
  final String scheduleType;
  final int? categoryId;
  final int? alarmMinutes;
  const Routine({
    required this.id,
    required this.content,
    required this.colorType,
    required this.isDone,
    this.startDate,
    this.endDate,
    this.timeMinutes,
    this.weekDays,
    required this.scheduleType,
    this.categoryId,
    this.alarmMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['color_type'] = Variable<int>(colorType);
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = Variable<int>(timeMinutes);
    }
    if (!nullToAbsent || weekDays != null) {
      map['week_days'] = Variable<String>(weekDays);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || alarmMinutes != null) {
      map['alarm_minutes'] = Variable<int>(alarmMinutes);
    }
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      content: Value(content),
      colorType: Value(colorType),
      isDone: Value(isDone),
      startDate:
          startDate == null && nullToAbsent
              ? const Value.absent()
              : Value(startDate),
      endDate:
          endDate == null && nullToAbsent
              ? const Value.absent()
              : Value(endDate),
      timeMinutes:
          timeMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(timeMinutes),
      weekDays:
          weekDays == null && nullToAbsent
              ? const Value.absent()
              : Value(weekDays),
      scheduleType: Value(scheduleType),
      categoryId:
          categoryId == null && nullToAbsent
              ? const Value.absent()
              : Value(categoryId),
      alarmMinutes:
          alarmMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(alarmMinutes),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      colorType: serializer.fromJson<int>(json['colorType']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      timeMinutes: serializer.fromJson<int?>(json['timeMinutes']),
      weekDays: serializer.fromJson<String?>(json['weekDays']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      alarmMinutes: serializer.fromJson<int?>(json['alarmMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'colorType': serializer.toJson<int>(colorType),
      'isDone': serializer.toJson<bool>(isDone),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'timeMinutes': serializer.toJson<int?>(timeMinutes),
      'weekDays': serializer.toJson<String?>(weekDays),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'categoryId': serializer.toJson<int?>(categoryId),
      'alarmMinutes': serializer.toJson<int?>(alarmMinutes),
    };
  }

  Routine copyWith({
    int? id,
    String? content,
    int? colorType,
    bool? isDone,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> timeMinutes = const Value.absent(),
    Value<String?> weekDays = const Value.absent(),
    String? scheduleType,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> alarmMinutes = const Value.absent(),
  }) => Routine(
    id: id ?? this.id,
    content: content ?? this.content,
    colorType: colorType ?? this.colorType,
    isDone: isDone ?? this.isDone,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    timeMinutes: timeMinutes.present ? timeMinutes.value : this.timeMinutes,
    weekDays: weekDays.present ? weekDays.value : this.weekDays,
    scheduleType: scheduleType ?? this.scheduleType,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    alarmMinutes: alarmMinutes.present ? alarmMinutes.value : this.alarmMinutes,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      colorType: data.colorType.present ? data.colorType.value : this.colorType,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      timeMinutes:
          data.timeMinutes.present ? data.timeMinutes.value : this.timeMinutes,
      weekDays: data.weekDays.present ? data.weekDays.value : this.weekDays,
      scheduleType:
          data.scheduleType.present
              ? data.scheduleType.value
              : this.scheduleType,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      alarmMinutes:
          data.alarmMinutes.present
              ? data.alarmMinutes.value
              : this.alarmMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('weekDays: $weekDays, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    colorType,
    isDone,
    startDate,
    endDate,
    timeMinutes,
    weekDays,
    scheduleType,
    categoryId,
    alarmMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.content == this.content &&
          other.colorType == this.colorType &&
          other.isDone == this.isDone &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.timeMinutes == this.timeMinutes &&
          other.weekDays == this.weekDays &&
          other.scheduleType == this.scheduleType &&
          other.categoryId == this.categoryId &&
          other.alarmMinutes == this.alarmMinutes);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<int> id;
  final Value<String> content;
  final Value<int> colorType;
  final Value<bool> isDone;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> timeMinutes;
  final Value<String?> weekDays;
  final Value<String> scheduleType;
  final Value<int?> categoryId;
  final Value<int?> alarmMinutes;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.colorType = const Value.absent(),
    this.isDone = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.weekDays = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.alarmMinutes = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.colorType = const Value.absent(),
    this.isDone = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.weekDays = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.alarmMinutes = const Value.absent(),
  }) : content = Value(content);
  static Insertable<Routine> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<int>? colorType,
    Expression<bool>? isDone,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? timeMinutes,
    Expression<String>? weekDays,
    Expression<String>? scheduleType,
    Expression<int>? categoryId,
    Expression<int>? alarmMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (colorType != null) 'color_type': colorType,
      if (isDone != null) 'is_done': isDone,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (weekDays != null) 'week_days': weekDays,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (categoryId != null) 'category_id': categoryId,
      if (alarmMinutes != null) 'alarm_minutes': alarmMinutes,
    });
  }

  RoutinesCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<int>? colorType,
    Value<bool>? isDone,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? timeMinutes,
    Value<String?>? weekDays,
    Value<String>? scheduleType,
    Value<int?>? categoryId,
    Value<int?>? alarmMinutes,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      colorType: colorType ?? this.colorType,
      isDone: isDone ?? this.isDone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      weekDays: weekDays ?? this.weekDays,
      scheduleType: scheduleType ?? this.scheduleType,
      categoryId: categoryId ?? this.categoryId,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (colorType.present) {
      map['color_type'] = Variable<int>(colorType.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = Variable<int>(timeMinutes.value);
    }
    if (weekDays.present) {
      map['week_days'] = Variable<String>(weekDays.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (alarmMinutes.present) {
      map['alarm_minutes'] = Variable<int>(alarmMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('weekDays: $weekDays, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorTypeMeta = const VerificationMeta(
    'colorType',
  );
  @override
  late final GeneratedColumn<int> colorType = GeneratedColumn<int>(
    'color_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timeMinutesMeta = const VerificationMeta(
    'timeMinutes',
  );
  @override
  late final GeneratedColumn<int> timeMinutes = GeneratedColumn<int>(
    'time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TO_DO'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alarmMinutesMeta = const VerificationMeta(
    'alarmMinutes',
  );
  @override
  late final GeneratedColumn<int> alarmMinutes = GeneratedColumn<int>(
    'alarm_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    colorType,
    isDone,
    timeMinutes,
    scheduleType,
    categoryId,
    alarmMinutes,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Todo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('color_type')) {
      context.handle(
        _colorTypeMeta,
        colorType.isAcceptableOrUnknown(data['color_type']!, _colorTypeMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('time_minutes')) {
      context.handle(
        _timeMinutesMeta,
        timeMinutes.isAcceptableOrUnknown(
          data['time_minutes']!,
          _timeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('alarm_minutes')) {
      context.handle(
        _alarmMinutesMeta,
        alarmMinutes.isAcceptableOrUnknown(
          data['alarm_minutes']!,
          _alarmMinutesMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      colorType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}color_type'],
          )!,
      isDone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_done'],
          )!,
      timeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_minutes'],
      ),
      scheduleType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}schedule_type'],
          )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      alarmMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alarm_minutes'],
      ),
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends DataClass implements Insertable<Todo> {
  final int id;
  final String content;
  final int colorType;
  final bool isDone;
  final int? timeMinutes;
  final String scheduleType;
  final int? categoryId;
  final int? alarmMinutes;
  final DateTime date;
  const Todo({
    required this.id,
    required this.content,
    required this.colorType,
    required this.isDone,
    this.timeMinutes,
    required this.scheduleType,
    this.categoryId,
    this.alarmMinutes,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['color_type'] = Variable<int>(colorType);
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = Variable<int>(timeMinutes);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || alarmMinutes != null) {
      map['alarm_minutes'] = Variable<int>(alarmMinutes);
    }
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      content: Value(content),
      colorType: Value(colorType),
      isDone: Value(isDone),
      timeMinutes:
          timeMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(timeMinutes),
      scheduleType: Value(scheduleType),
      categoryId:
          categoryId == null && nullToAbsent
              ? const Value.absent()
              : Value(categoryId),
      alarmMinutes:
          alarmMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(alarmMinutes),
      date: Value(date),
    );
  }

  factory Todo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      colorType: serializer.fromJson<int>(json['colorType']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      timeMinutes: serializer.fromJson<int?>(json['timeMinutes']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      alarmMinutes: serializer.fromJson<int?>(json['alarmMinutes']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'colorType': serializer.toJson<int>(colorType),
      'isDone': serializer.toJson<bool>(isDone),
      'timeMinutes': serializer.toJson<int?>(timeMinutes),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'categoryId': serializer.toJson<int?>(categoryId),
      'alarmMinutes': serializer.toJson<int?>(alarmMinutes),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Todo copyWith({
    int? id,
    String? content,
    int? colorType,
    bool? isDone,
    Value<int?> timeMinutes = const Value.absent(),
    String? scheduleType,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> alarmMinutes = const Value.absent(),
    DateTime? date,
  }) => Todo(
    id: id ?? this.id,
    content: content ?? this.content,
    colorType: colorType ?? this.colorType,
    isDone: isDone ?? this.isDone,
    timeMinutes: timeMinutes.present ? timeMinutes.value : this.timeMinutes,
    scheduleType: scheduleType ?? this.scheduleType,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    alarmMinutes: alarmMinutes.present ? alarmMinutes.value : this.alarmMinutes,
    date: date ?? this.date,
  );
  Todo copyWithCompanion(TodosCompanion data) {
    return Todo(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      colorType: data.colorType.present ? data.colorType.value : this.colorType,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      timeMinutes:
          data.timeMinutes.present ? data.timeMinutes.value : this.timeMinutes,
      scheduleType:
          data.scheduleType.present
              ? data.scheduleType.value
              : this.scheduleType,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      alarmMinutes:
          data.alarmMinutes.present
              ? data.alarmMinutes.value
              : this.alarmMinutes,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    colorType,
    isDone,
    timeMinutes,
    scheduleType,
    categoryId,
    alarmMinutes,
    date,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.content == this.content &&
          other.colorType == this.colorType &&
          other.isDone == this.isDone &&
          other.timeMinutes == this.timeMinutes &&
          other.scheduleType == this.scheduleType &&
          other.categoryId == this.categoryId &&
          other.alarmMinutes == this.alarmMinutes &&
          other.date == this.date);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<int> id;
  final Value<String> content;
  final Value<int> colorType;
  final Value<bool> isDone;
  final Value<int?> timeMinutes;
  final Value<String> scheduleType;
  final Value<int?> categoryId;
  final Value<int?> alarmMinutes;
  final Value<DateTime> date;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.colorType = const Value.absent(),
    this.isDone = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.alarmMinutes = const Value.absent(),
    this.date = const Value.absent(),
  });
  TodosCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.colorType = const Value.absent(),
    this.isDone = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.alarmMinutes = const Value.absent(),
    required DateTime date,
  }) : content = Value(content),
       date = Value(date);
  static Insertable<Todo> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<int>? colorType,
    Expression<bool>? isDone,
    Expression<int>? timeMinutes,
    Expression<String>? scheduleType,
    Expression<int>? categoryId,
    Expression<int>? alarmMinutes,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (colorType != null) 'color_type': colorType,
      if (isDone != null) 'is_done': isDone,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (categoryId != null) 'category_id': categoryId,
      if (alarmMinutes != null) 'alarm_minutes': alarmMinutes,
      if (date != null) 'date': date,
    });
  }

  TodosCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<int>? colorType,
    Value<bool>? isDone,
    Value<int?>? timeMinutes,
    Value<String>? scheduleType,
    Value<int?>? categoryId,
    Value<int?>? alarmMinutes,
    Value<DateTime>? date,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      colorType: colorType ?? this.colorType,
      isDone: isDone ?? this.isDone,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      scheduleType: scheduleType ?? this.scheduleType,
      categoryId: categoryId ?? this.categoryId,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (colorType.present) {
      map['color_type'] = Variable<int>(colorType.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = Variable<int>(timeMinutes.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (alarmMinutes.present) {
      map['alarm_minutes'] = Variable<int>(alarmMinutes.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $CompletedRoutinesTable extends CompletedRoutines
    with TableInfo<$CompletedRoutinesTable, CompletedRoutine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, routineId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletedRoutine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedRoutine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      routineId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}routine_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
    );
  }

  @override
  $CompletedRoutinesTable createAlias(String alias) {
    return $CompletedRoutinesTable(attachedDatabase, alias);
  }
}

class CompletedRoutine extends DataClass
    implements Insertable<CompletedRoutine> {
  final int id;
  final int routineId;
  final DateTime date;
  const CompletedRoutine({
    required this.id,
    required this.routineId,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<int>(routineId);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  CompletedRoutinesCompanion toCompanion(bool nullToAbsent) {
    return CompletedRoutinesCompanion(
      id: Value(id),
      routineId: Value(routineId),
      date: Value(date),
    );
  }

  factory CompletedRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedRoutine(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  CompletedRoutine copyWith({int? id, int? routineId, DateTime? date}) =>
      CompletedRoutine(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        date: date ?? this.date,
      );
  CompletedRoutine copyWithCompanion(CompletedRoutinesCompanion data) {
    return CompletedRoutine(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedRoutine(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedRoutine &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.date == this.date);
}

class CompletedRoutinesCompanion extends UpdateCompanion<CompletedRoutine> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<DateTime> date;
  const CompletedRoutinesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.date = const Value.absent(),
  });
  CompletedRoutinesCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required DateTime date,
  }) : routineId = Value(routineId),
       date = Value(date);
  static Insertable<CompletedRoutine> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (date != null) 'date': date,
    });
  }

  CompletedRoutinesCompanion copyWith({
    Value<int>? id,
    Value<int>? routineId,
    Value<DateTime>? date,
  }) {
    return CompletedRoutinesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $CompletedTodosTable extends CompletedTodos
    with TableInfo<$CompletedTodosTable, CompletedTodo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedTodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<int> todoId = GeneratedColumn<int>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, todoId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedTodo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletedTodo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedTodo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      todoId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}todo_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
    );
  }

  @override
  $CompletedTodosTable createAlias(String alias) {
    return $CompletedTodosTable(attachedDatabase, alias);
  }
}

class CompletedTodo extends DataClass implements Insertable<CompletedTodo> {
  final int id;
  final int todoId;
  final DateTime date;
  const CompletedTodo({
    required this.id,
    required this.todoId,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['todo_id'] = Variable<int>(todoId);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  CompletedTodosCompanion toCompanion(bool nullToAbsent) {
    return CompletedTodosCompanion(
      id: Value(id),
      todoId: Value(todoId),
      date: Value(date),
    );
  }

  factory CompletedTodo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedTodo(
      id: serializer.fromJson<int>(json['id']),
      todoId: serializer.fromJson<int>(json['todoId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'todoId': serializer.toJson<int>(todoId),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  CompletedTodo copyWith({int? id, int? todoId, DateTime? date}) =>
      CompletedTodo(
        id: id ?? this.id,
        todoId: todoId ?? this.todoId,
        date: date ?? this.date,
      );
  CompletedTodo copyWithCompanion(CompletedTodosCompanion data) {
    return CompletedTodo(
      id: data.id.present ? data.id.value : this.id,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTodo(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, todoId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedTodo &&
          other.id == this.id &&
          other.todoId == this.todoId &&
          other.date == this.date);
}

class CompletedTodosCompanion extends UpdateCompanion<CompletedTodo> {
  final Value<int> id;
  final Value<int> todoId;
  final Value<DateTime> date;
  const CompletedTodosCompanion({
    this.id = const Value.absent(),
    this.todoId = const Value.absent(),
    this.date = const Value.absent(),
  });
  CompletedTodosCompanion.insert({
    this.id = const Value.absent(),
    required int todoId,
    required DateTime date,
  }) : todoId = Value(todoId),
       date = Value(date);
  static Insertable<CompletedTodo> custom({
    Expression<int>? id,
    Expression<int>? todoId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (date != null) 'date': date,
    });
  }

  CompletedTodosCompanion copyWith({
    Value<int>? id,
    Value<int>? todoId,
    Value<DateTime>? date,
  }) {
    return CompletedTodosCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<int>(todoId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTodosCompanion(')
          ..write('id: $id, ')
          ..write('todoId: $todoId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $DayLogsTable extends DayLogs with TableInfo<$DayLogsTable, DayLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerMapJsonMeta = const VerificationMeta(
    'answerMapJson',
  );
  @override
  late final GeneratedColumn<String> answerMapJson = GeneratedColumn<String>(
    'answer_map_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaryMeta = const VerificationMeta('diary');
  @override
  late final GeneratedColumn<String> diary = GeneratedColumn<String>(
    'diary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [date, emotion, answerMapJson, diary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    }
    if (data.containsKey('answer_map_json')) {
      context.handle(
        _answerMapJsonMeta,
        answerMapJson.isAcceptableOrUnknown(
          data['answer_map_json']!,
          _answerMapJsonMeta,
        ),
      );
    }
    if (data.containsKey('diary')) {
      context.handle(
        _diaryMeta,
        diary.isAcceptableOrUnknown(data['diary']!, _diaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DayLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLog(
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      ),
      answerMapJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_map_json'],
      ),
      diary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diary'],
      ),
    );
  }

  @override
  $DayLogsTable createAlias(String alias) {
    return $DayLogsTable(attachedDatabase, alias);
  }
}

class DayLog extends DataClass implements Insertable<DayLog> {
  final DateTime date;
  final String? emotion;
  final String? answerMapJson;
  final String? diary;
  const DayLog({
    required this.date,
    this.emotion,
    this.answerMapJson,
    this.diary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    if (!nullToAbsent || answerMapJson != null) {
      map['answer_map_json'] = Variable<String>(answerMapJson);
    }
    if (!nullToAbsent || diary != null) {
      map['diary'] = Variable<String>(diary);
    }
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      date: Value(date),
      emotion:
          emotion == null && nullToAbsent
              ? const Value.absent()
              : Value(emotion),
      answerMapJson:
          answerMapJson == null && nullToAbsent
              ? const Value.absent()
              : Value(answerMapJson),
      diary:
          diary == null && nullToAbsent ? const Value.absent() : Value(diary),
    );
  }

  factory DayLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLog(
      date: serializer.fromJson<DateTime>(json['date']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      answerMapJson: serializer.fromJson<String?>(json['answerMapJson']),
      diary: serializer.fromJson<String?>(json['diary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'emotion': serializer.toJson<String?>(emotion),
      'answerMapJson': serializer.toJson<String?>(answerMapJson),
      'diary': serializer.toJson<String?>(diary),
    };
  }

  DayLog copyWith({
    DateTime? date,
    Value<String?> emotion = const Value.absent(),
    Value<String?> answerMapJson = const Value.absent(),
    Value<String?> diary = const Value.absent(),
  }) => DayLog(
    date: date ?? this.date,
    emotion: emotion.present ? emotion.value : this.emotion,
    answerMapJson:
        answerMapJson.present ? answerMapJson.value : this.answerMapJson,
    diary: diary.present ? diary.value : this.diary,
  );
  DayLog copyWithCompanion(DayLogsCompanion data) {
    return DayLog(
      date: data.date.present ? data.date.value : this.date,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      answerMapJson:
          data.answerMapJson.present
              ? data.answerMapJson.value
              : this.answerMapJson,
      diary: data.diary.present ? data.diary.value : this.diary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLog(')
          ..write('date: $date, ')
          ..write('emotion: $emotion, ')
          ..write('answerMapJson: $answerMapJson, ')
          ..write('diary: $diary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, emotion, answerMapJson, diary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLog &&
          other.date == this.date &&
          other.emotion == this.emotion &&
          other.answerMapJson == this.answerMapJson &&
          other.diary == this.diary);
}

class DayLogsCompanion extends UpdateCompanion<DayLog> {
  final Value<DateTime> date;
  final Value<String?> emotion;
  final Value<String?> answerMapJson;
  final Value<String?> diary;
  final Value<int> rowid;
  const DayLogsCompanion({
    this.date = const Value.absent(),
    this.emotion = const Value.absent(),
    this.answerMapJson = const Value.absent(),
    this.diary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayLogsCompanion.insert({
    required DateTime date,
    this.emotion = const Value.absent(),
    this.answerMapJson = const Value.absent(),
    this.diary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DayLog> custom({
    Expression<DateTime>? date,
    Expression<String>? emotion,
    Expression<String>? answerMapJson,
    Expression<String>? diary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (emotion != null) 'emotion': emotion,
      if (answerMapJson != null) 'answer_map_json': answerMapJson,
      if (diary != null) 'diary': diary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogsCompanion copyWith({
    Value<DateTime>? date,
    Value<String?>? emotion,
    Value<String?>? answerMapJson,
    Value<String?>? diary,
    Value<int>? rowid,
  }) {
    return DayLogsCompanion(
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      answerMapJson: answerMapJson ?? this.answerMapJson,
      diary: diary ?? this.diary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (answerMapJson.present) {
      map['answer_map_json'] = Variable<String>(answerMapJson.value);
    }
    if (diary.present) {
      map['diary'] = Variable<String>(diary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogsCompanion(')
          ..write('date: $date, ')
          ..write('emotion: $emotion, ')
          ..write('answerMapJson: $answerMapJson, ')
          ..write('diary: $diary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $DayLogQuestionsTable dayLogQuestions = $DayLogQuestionsTable(
    this,
  );
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $CompletedRoutinesTable completedRoutines =
      $CompletedRoutinesTable(this);
  late final $CompletedTodosTable completedTodos = $CompletedTodosTable(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    dayLogQuestions,
    routines,
    todos,
    completedRoutines,
    completedTodos,
    dayLogs,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required String color,
      Value<bool> isDeleted,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String> color,
      Value<bool> isDeleted,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            Category,
            BaseReferences<_$LocalDatabase, $CategoriesTable, Category>,
          ),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$LocalDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                color: color,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required String color,
                Value<bool> isDeleted = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                color: color,
                isDeleted: isDeleted,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$LocalDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$DayLogQuestionsTableCreateCompanionBuilder =
    DayLogQuestionsCompanion Function({
      Value<int> id,
      required String question,
      Value<String> emoji,
    });
typedef $$DayLogQuestionsTableUpdateCompanionBuilder =
    DayLogQuestionsCompanion Function({
      Value<int> id,
      Value<String> question,
      Value<String> emoji,
    });

class $$DayLogQuestionsTableFilterComposer
    extends Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogQuestionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogQuestionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);
}

class $$DayLogQuestionsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $DayLogQuestionsTable,
          DayLogQuestion,
          $$DayLogQuestionsTableFilterComposer,
          $$DayLogQuestionsTableOrderingComposer,
          $$DayLogQuestionsTableAnnotationComposer,
          $$DayLogQuestionsTableCreateCompanionBuilder,
          $$DayLogQuestionsTableUpdateCompanionBuilder,
          (
            DayLogQuestion,
            BaseReferences<
              _$LocalDatabase,
              $DayLogQuestionsTable,
              DayLogQuestion
            >,
          ),
          DayLogQuestion,
          PrefetchHooks Function()
        > {
  $$DayLogQuestionsTableTableManager(
    _$LocalDatabase db,
    $DayLogQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$DayLogQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DayLogQuestionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DayLogQuestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> emoji = const Value.absent(),
              }) => DayLogQuestionsCompanion(
                id: id,
                question: question,
                emoji: emoji,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String question,
                Value<String> emoji = const Value.absent(),
              }) => DayLogQuestionsCompanion.insert(
                id: id,
                question: question,
                emoji: emoji,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $DayLogQuestionsTable,
      DayLogQuestion,
      $$DayLogQuestionsTableFilterComposer,
      $$DayLogQuestionsTableOrderingComposer,
      $$DayLogQuestionsTableAnnotationComposer,
      $$DayLogQuestionsTableCreateCompanionBuilder,
      $$DayLogQuestionsTableUpdateCompanionBuilder,
      (
        DayLogQuestion,
        BaseReferences<_$LocalDatabase, $DayLogQuestionsTable, DayLogQuestion>,
      ),
      DayLogQuestion,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      required String content,
      Value<int> colorType,
      Value<bool> isDone,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> timeMinutes,
      Value<String?> weekDays,
      Value<String> scheduleType,
      Value<int?> categoryId,
      Value<int?> alarmMinutes,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<int> colorType,
      Value<bool> isDone,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> timeMinutes,
      Value<String?> weekDays,
      Value<String> scheduleType,
      Value<int?> categoryId,
      Value<int?> alarmMinutes,
    });

class $$RoutinesTableFilterComposer
    extends Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekDays => $composableBuilder(
    column: $table.weekDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekDays => $composableBuilder(
    column: $table.weekDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get colorType =>
      $composableBuilder(column: $table.colorType, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekDays =>
      $composableBuilder(column: $table.weekDays, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => column,
  );
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, BaseReferences<_$LocalDatabase, $RoutinesTable, Routine>),
          Routine,
          PrefetchHooks Function()
        > {
  $$RoutinesTableTableManager(_$LocalDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> colorType = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<String?> weekDays = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> alarmMinutes = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                content: content,
                colorType: colorType,
                isDone: isDone,
                startDate: startDate,
                endDate: endDate,
                timeMinutes: timeMinutes,
                weekDays: weekDays,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<int> colorType = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<String?> weekDays = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> alarmMinutes = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                content: content,
                colorType: colorType,
                isDone: isDone,
                startDate: startDate,
                endDate: endDate,
                timeMinutes: timeMinutes,
                weekDays: weekDays,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, BaseReferences<_$LocalDatabase, $RoutinesTable, Routine>),
      Routine,
      PrefetchHooks Function()
    >;
typedef $$TodosTableCreateCompanionBuilder =
    TodosCompanion Function({
      Value<int> id,
      required String content,
      Value<int> colorType,
      Value<bool> isDone,
      Value<int?> timeMinutes,
      Value<String> scheduleType,
      Value<int?> categoryId,
      Value<int?> alarmMinutes,
      required DateTime date,
    });
typedef $$TodosTableUpdateCompanionBuilder =
    TodosCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<int> colorType,
      Value<bool> isDone,
      Value<int?> timeMinutes,
      Value<String> scheduleType,
      Value<int?> categoryId,
      Value<int?> alarmMinutes,
      Value<DateTime> date,
    });

class $$TodosTableFilterComposer
    extends Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodosTableOrderingComposer
    extends Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodosTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get colorType =>
      $composableBuilder(column: $table.colorType, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $TodosTable,
          Todo,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (Todo, BaseReferences<_$LocalDatabase, $TodosTable, Todo>),
          Todo,
          PrefetchHooks Function()
        > {
  $$TodosTableTableManager(_$LocalDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> colorType = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> alarmMinutes = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                content: content,
                colorType: colorType,
                isDone: isDone,
                timeMinutes: timeMinutes,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<int> colorType = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> alarmMinutes = const Value.absent(),
                required DateTime date,
              }) => TodosCompanion.insert(
                id: id,
                content: content,
                colorType: colorType,
                isDone: isDone,
                timeMinutes: timeMinutes,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
                date: date,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $TodosTable,
      Todo,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (Todo, BaseReferences<_$LocalDatabase, $TodosTable, Todo>),
      Todo,
      PrefetchHooks Function()
    >;
typedef $$CompletedRoutinesTableCreateCompanionBuilder =
    CompletedRoutinesCompanion Function({
      Value<int> id,
      required int routineId,
      required DateTime date,
    });
typedef $$CompletedRoutinesTableUpdateCompanionBuilder =
    CompletedRoutinesCompanion Function({
      Value<int> id,
      Value<int> routineId,
      Value<DateTime> date,
    });

class $$CompletedRoutinesTableFilterComposer
    extends Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedRoutinesTableOrderingComposer
    extends Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedRoutinesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$CompletedRoutinesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CompletedRoutinesTable,
          CompletedRoutine,
          $$CompletedRoutinesTableFilterComposer,
          $$CompletedRoutinesTableOrderingComposer,
          $$CompletedRoutinesTableAnnotationComposer,
          $$CompletedRoutinesTableCreateCompanionBuilder,
          $$CompletedRoutinesTableUpdateCompanionBuilder,
          (
            CompletedRoutine,
            BaseReferences<
              _$LocalDatabase,
              $CompletedRoutinesTable,
              CompletedRoutine
            >,
          ),
          CompletedRoutine,
          PrefetchHooks Function()
        > {
  $$CompletedRoutinesTableTableManager(
    _$LocalDatabase db,
    $CompletedRoutinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CompletedRoutinesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CompletedRoutinesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CompletedRoutinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => CompletedRoutinesCompanion(
                id: id,
                routineId: routineId,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineId,
                required DateTime date,
              }) => CompletedRoutinesCompanion.insert(
                id: id,
                routineId: routineId,
                date: date,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CompletedRoutinesTable,
      CompletedRoutine,
      $$CompletedRoutinesTableFilterComposer,
      $$CompletedRoutinesTableOrderingComposer,
      $$CompletedRoutinesTableAnnotationComposer,
      $$CompletedRoutinesTableCreateCompanionBuilder,
      $$CompletedRoutinesTableUpdateCompanionBuilder,
      (
        CompletedRoutine,
        BaseReferences<
          _$LocalDatabase,
          $CompletedRoutinesTable,
          CompletedRoutine
        >,
      ),
      CompletedRoutine,
      PrefetchHooks Function()
    >;
typedef $$CompletedTodosTableCreateCompanionBuilder =
    CompletedTodosCompanion Function({
      Value<int> id,
      required int todoId,
      required DateTime date,
    });
typedef $$CompletedTodosTableUpdateCompanionBuilder =
    CompletedTodosCompanion Function({
      Value<int> id,
      Value<int> todoId,
      Value<DateTime> date,
    });

class $$CompletedTodosTableFilterComposer
    extends Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedTodosTableOrderingComposer
    extends Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedTodosTableAnnotationComposer
    extends Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$CompletedTodosTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $CompletedTodosTable,
          CompletedTodo,
          $$CompletedTodosTableFilterComposer,
          $$CompletedTodosTableOrderingComposer,
          $$CompletedTodosTableAnnotationComposer,
          $$CompletedTodosTableCreateCompanionBuilder,
          $$CompletedTodosTableUpdateCompanionBuilder,
          (
            CompletedTodo,
            BaseReferences<
              _$LocalDatabase,
              $CompletedTodosTable,
              CompletedTodo
            >,
          ),
          CompletedTodo,
          PrefetchHooks Function()
        > {
  $$CompletedTodosTableTableManager(
    _$LocalDatabase db,
    $CompletedTodosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CompletedTodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CompletedTodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CompletedTodosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> todoId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => CompletedTodosCompanion(id: id, todoId: todoId, date: date),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int todoId,
                required DateTime date,
              }) => CompletedTodosCompanion.insert(
                id: id,
                todoId: todoId,
                date: date,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedTodosTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $CompletedTodosTable,
      CompletedTodo,
      $$CompletedTodosTableFilterComposer,
      $$CompletedTodosTableOrderingComposer,
      $$CompletedTodosTableAnnotationComposer,
      $$CompletedTodosTableCreateCompanionBuilder,
      $$CompletedTodosTableUpdateCompanionBuilder,
      (
        CompletedTodo,
        BaseReferences<_$LocalDatabase, $CompletedTodosTable, CompletedTodo>,
      ),
      CompletedTodo,
      PrefetchHooks Function()
    >;
typedef $$DayLogsTableCreateCompanionBuilder =
    DayLogsCompanion Function({
      required DateTime date,
      Value<String?> emotion,
      Value<String?> answerMapJson,
      Value<String?> diary,
      Value<int> rowid,
    });
typedef $$DayLogsTableUpdateCompanionBuilder =
    DayLogsCompanion Function({
      Value<DateTime> date,
      Value<String?> emotion,
      Value<String?> answerMapJson,
      Value<String?> diary,
      Value<int> rowid,
    });

class $$DayLogsTableFilterComposer
    extends Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diary => $composableBuilder(
    column: $table.diary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diary => $composableBuilder(
    column: $table.diary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diary =>
      $composableBuilder(column: $table.diary, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $DayLogsTable,
          DayLog,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (DayLog, BaseReferences<_$LocalDatabase, $DayLogsTable, DayLog>),
          DayLog,
          PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$LocalDatabase db, $DayLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DayLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DayLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DayLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String?> answerMapJson = const Value.absent(),
                Value<String?> diary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion(
                date: date,
                emotion: emotion,
                answerMapJson: answerMapJson,
                diary: diary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                Value<String?> emotion = const Value.absent(),
                Value<String?> answerMapJson = const Value.absent(),
                Value<String?> diary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion.insert(
                date: date,
                emotion: emotion,
                answerMapJson: answerMapJson,
                diary: diary,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $DayLogsTable,
      DayLog,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLog, BaseReferences<_$LocalDatabase, $DayLogsTable, DayLog>),
      DayLog,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$DayLogQuestionsTableTableManager get dayLogQuestions =>
      $$DayLogQuestionsTableTableManager(_db, _db.dayLogQuestions);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$CompletedRoutinesTableTableManager get completedRoutines =>
      $$CompletedRoutinesTableTableManager(_db, _db.completedRoutines);
  $$CompletedTodosTableTableManager get completedTodos =>
      $$CompletedTodosTableTableManager(_db, _db.completedTodos);
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
}
