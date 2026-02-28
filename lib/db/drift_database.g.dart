// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with drift.TableInfo<$CategoriesTable, Category> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _categoryIdMeta =
      const drift.VerificationMeta('categoryId');
  @override
  late final drift.GeneratedColumn<int> categoryId = drift.GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _nameMeta = const drift.VerificationMeta(
    'name',
  );
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _typeMeta = const drift.VerificationMeta(
    'type',
  );
  @override
  late final drift.GeneratedColumn<String> type = drift.GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _colorMeta = const drift.VerificationMeta(
    'color',
  );
  @override
  late final drift.GeneratedColumn<String> color =
      drift.GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _isDeletedMeta =
      const drift.VerificationMeta('isDeleted');
  @override
  late final drift.GeneratedColumn<bool> isDeleted =
      drift.GeneratedColumn<bool>(
        'is_deleted',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_deleted" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _serverIdMeta =
      const drift.VerificationMeta('serverId');
  @override
  late final drift.GeneratedColumn<int> serverId = drift.GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _isSyncedMeta =
      const drift.VerificationMeta('isSynced');
  @override
  late final drift.GeneratedColumn<bool> isSynced = drift.GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    type,
    color,
    isDeleted,
    serverId,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
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
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
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
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends drift.DataClass implements drift.Insertable<Category> {
  final int id;
  final int? categoryId;
  final String name;
  final String type;
  final String color;
  final bool isDeleted;
  final int? serverId;
  final bool isSynced;
  const Category({
    required this.id,
    this.categoryId,
    required this.name,
    required this.type,
    required this.color,
    required this.isDeleted,
    this.serverId,
    required this.isSynced,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = drift.Variable<int>(categoryId);
    }
    map['name'] = drift.Variable<String>(name);
    map['type'] = drift.Variable<String>(type);
    map['color'] = drift.Variable<String>(color);
    map['is_deleted'] = drift.Variable<bool>(isDeleted);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = drift.Variable<int>(serverId);
    }
    map['is_synced'] = drift.Variable<bool>(isSynced);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: drift.Value(id),
      categoryId:
          categoryId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(categoryId),
      name: drift.Value(name),
      type: drift.Value(type),
      color: drift.Value(color),
      isDeleted: drift.Value(isDeleted),
      serverId:
          serverId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(serverId),
      isSynced: drift.Value(isSynced),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String>(json['color']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int?>(categoryId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String>(color),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Category copyWith({
    int? id,
    drift.Value<int?> categoryId = const drift.Value.absent(),
    String? name,
    String? type,
    String? color,
    bool? isDeleted,
    drift.Value<int?> serverId = const drift.Value.absent(),
    bool? isSynced,
  }) => Category(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    name: name ?? this.name,
    type: type ?? this.type,
    color: color ?? this.color,
    isDeleted: isDeleted ?? this.isDeleted,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    type,
    color,
    isDeleted,
    serverId,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.isDeleted == this.isDeleted &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced);
}

class CategoriesCompanion extends drift.UpdateCompanion<Category> {
  final drift.Value<int> id;
  final drift.Value<int?> categoryId;
  final drift.Value<String> name;
  final drift.Value<String> type;
  final drift.Value<String> color;
  final drift.Value<bool> isDeleted;
  final drift.Value<int?> serverId;
  final drift.Value<bool> isSynced;
  const CategoriesCompanion({
    this.id = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.type = const drift.Value.absent(),
    this.color = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    required String name,
    required String type,
    required String color,
    this.isDeleted = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  }) : name = drift.Value(name),
       type = drift.Value(type),
       color = drift.Value(color);
  static drift.Insertable<Category> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? categoryId,
    drift.Expression<String>? name,
    drift.Expression<String>? type,
    drift.Expression<String>? color,
    drift.Expression<bool>? isDeleted,
    drift.Expression<int>? serverId,
    drift.Expression<bool>? isSynced,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  CategoriesCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int?>? categoryId,
    drift.Value<String>? name,
    drift.Value<String>? type,
    drift.Value<String>? color,
    drift.Value<bool>? isDeleted,
    drift.Value<int?>? serverId,
    drift.Value<bool>? isSynced,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      isDeleted: isDeleted ?? this.isDeleted,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = drift.Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = drift.Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = drift.Variable<String>(color.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = drift.Variable<bool>(isDeleted.value);
    }
    if (serverId.present) {
      map['server_id'] = drift.Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = drift.Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $DayLogQuestionsTable extends DayLogQuestions
    with drift.TableInfo<$DayLogQuestionsTable, DayLogQuestion> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogQuestionsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _serverIdMeta =
      const drift.VerificationMeta('serverId');
  @override
  late final drift.GeneratedColumn<int> serverId = drift.GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _questionMeta =
      const drift.VerificationMeta('question');
  @override
  late final drift.GeneratedColumn<String> question =
      drift.GeneratedColumn<String>(
        'question',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _emojiMeta = const drift.VerificationMeta(
    'emoji',
  );
  @override
  late final drift.GeneratedColumn<String> emoji =
      drift.GeneratedColumn<String>(
        'emoji',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('🙂'),
      );
  @override
  List<drift.GeneratedColumn> get $columns => [id, serverId, question, emoji];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_log_questions';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<DayLogQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  DayLogQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLogQuestion(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
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

class DayLogQuestion extends drift.DataClass
    implements drift.Insertable<DayLogQuestion> {
  final int id;
  final int? serverId;
  final String question;
  final String emoji;
  const DayLogQuestion({
    required this.id,
    this.serverId,
    required this.question,
    required this.emoji,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = drift.Variable<int>(serverId);
    }
    map['question'] = drift.Variable<String>(question);
    map['emoji'] = drift.Variable<String>(emoji);
    return map;
  }

  DayLogQuestionsCompanion toCompanion(bool nullToAbsent) {
    return DayLogQuestionsCompanion(
      id: drift.Value(id),
      serverId:
          serverId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(serverId),
      question: drift.Value(question),
      emoji: drift.Value(emoji),
    );
  }

  factory DayLogQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return DayLogQuestion(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      question: serializer.fromJson<String>(json['question']),
      emoji: serializer.fromJson<String>(json['emoji']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'question': serializer.toJson<String>(question),
      'emoji': serializer.toJson<String>(emoji),
    };
  }

  DayLogQuestion copyWith({
    int? id,
    drift.Value<int?> serverId = const drift.Value.absent(),
    String? question,
    String? emoji,
  }) => DayLogQuestion(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    question: question ?? this.question,
    emoji: emoji ?? this.emoji,
  );
  DayLogQuestion copyWithCompanion(DayLogQuestionsCompanion data) {
    return DayLogQuestion(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      question: data.question.present ? data.question.value : this.question,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLogQuestion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('question: $question, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, question, emoji);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLogQuestion &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.question == this.question &&
          other.emoji == this.emoji);
}

class DayLogQuestionsCompanion extends drift.UpdateCompanion<DayLogQuestion> {
  final drift.Value<int> id;
  final drift.Value<int?> serverId;
  final drift.Value<String> question;
  final drift.Value<String> emoji;
  const DayLogQuestionsCompanion({
    this.id = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.question = const drift.Value.absent(),
    this.emoji = const drift.Value.absent(),
  });
  DayLogQuestionsCompanion.insert({
    this.id = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    required String question,
    this.emoji = const drift.Value.absent(),
  }) : question = drift.Value(question);
  static drift.Insertable<DayLogQuestion> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? serverId,
    drift.Expression<String>? question,
    drift.Expression<String>? emoji,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (question != null) 'question': question,
      if (emoji != null) 'emoji': emoji,
    });
  }

  DayLogQuestionsCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int?>? serverId,
    drift.Value<String>? question,
    drift.Value<String>? emoji,
  }) {
    return DayLogQuestionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      question: question ?? this.question,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = drift.Variable<int>(serverId.value);
    }
    if (question.present) {
      map['question'] = drift.Variable<String>(question.value);
    }
    if (emoji.present) {
      map['emoji'] = drift.Variable<String>(emoji.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('question: $question, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with drift.TableInfo<$GroupsTable, Group> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _nameMeta = const drift.VerificationMeta(
    'name',
  );
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _descriptionMeta =
      const drift.VerificationMeta('description');
  @override
  late final drift.GeneratedColumn<String> description =
      drift.GeneratedColumn<String>(
        'description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _colorTypeMeta =
      const drift.VerificationMeta('colorType');
  @override
  late final drift.GeneratedColumn<int> colorType = drift.GeneratedColumn<int>(
    'color_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _maxMembersMeta =
      const drift.VerificationMeta('maxMembers');
  @override
  late final drift.GeneratedColumn<int> maxMembers = drift.GeneratedColumn<int>(
    'max_members',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _passwordMeta =
      const drift.VerificationMeta('password');
  @override
  late final drift.GeneratedColumn<String> password =
      drift.GeneratedColumn<String>(
        'password',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    name,
    description,
    colorType,
    maxMembers,
    password,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color_type')) {
      context.handle(
        _colorTypeMeta,
        colorType.isAcceptableOrUnknown(data['color_type']!, _colorTypeMeta),
      );
    }
    if (data.containsKey('max_members')) {
      context.handle(
        _maxMembersMeta,
        maxMembers.isAcceptableOrUnknown(data['max_members']!, _maxMembersMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
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
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      colorType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}color_type'],
          )!,
      maxMembers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_members'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends drift.DataClass implements drift.Insertable<Group> {
  final int id;
  final String name;
  final String? description;
  final int colorType;
  final int? maxMembers;
  final String? password;
  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.colorType,
    this.maxMembers,
    this.password,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['name'] = drift.Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = drift.Variable<String>(description);
    }
    map['color_type'] = drift.Variable<int>(colorType);
    if (!nullToAbsent || maxMembers != null) {
      map['max_members'] = drift.Variable<int>(maxMembers);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = drift.Variable<String>(password);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      description:
          description == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(description),
      colorType: drift.Value(colorType),
      maxMembers:
          maxMembers == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(maxMembers),
      password:
          password == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(password),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      colorType: serializer.fromJson<int>(json['colorType']),
      maxMembers: serializer.fromJson<int?>(json['maxMembers']),
      password: serializer.fromJson<String?>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'colorType': serializer.toJson<int>(colorType),
      'maxMembers': serializer.toJson<int?>(maxMembers),
      'password': serializer.toJson<String?>(password),
    };
  }

  Group copyWith({
    int? id,
    String? name,
    drift.Value<String?> description = const drift.Value.absent(),
    int? colorType,
    drift.Value<int?> maxMembers = const drift.Value.absent(),
    drift.Value<String?> password = const drift.Value.absent(),
  }) => Group(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    colorType: colorType ?? this.colorType,
    maxMembers: maxMembers.present ? maxMembers.value : this.maxMembers,
    password: password.present ? password.value : this.password,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      colorType: data.colorType.present ? data.colorType.value : this.colorType,
      maxMembers:
          data.maxMembers.present ? data.maxMembers.value : this.maxMembers,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorType: $colorType, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, colorType, maxMembers, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.colorType == this.colorType &&
          other.maxMembers == this.maxMembers &&
          other.password == this.password);
}

class GroupsCompanion extends drift.UpdateCompanion<Group> {
  final drift.Value<int> id;
  final drift.Value<String> name;
  final drift.Value<String?> description;
  final drift.Value<int> colorType;
  final drift.Value<int?> maxMembers;
  final drift.Value<String?> password;
  const GroupsCompanion({
    this.id = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.description = const drift.Value.absent(),
    this.colorType = const drift.Value.absent(),
    this.maxMembers = const drift.Value.absent(),
    this.password = const drift.Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const drift.Value.absent(),
    required String name,
    this.description = const drift.Value.absent(),
    this.colorType = const drift.Value.absent(),
    this.maxMembers = const drift.Value.absent(),
    this.password = const drift.Value.absent(),
  }) : name = drift.Value(name);
  static drift.Insertable<Group> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? name,
    drift.Expression<String>? description,
    drift.Expression<int>? colorType,
    drift.Expression<int>? maxMembers,
    drift.Expression<String>? password,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (colorType != null) 'color_type': colorType,
      if (maxMembers != null) 'max_members': maxMembers,
      if (password != null) 'password': password,
    });
  }

  GroupsCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<String>? name,
    drift.Value<String?>? description,
    drift.Value<int>? colorType,
    drift.Value<int?>? maxMembers,
    drift.Value<String?>? password,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorType: colorType ?? this.colorType,
      maxMembers: maxMembers ?? this.maxMembers,
      password: password ?? this.password,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = drift.Variable<String>(description.value);
    }
    if (colorType.present) {
      map['color_type'] = drift.Variable<int>(colorType.value);
    }
    if (maxMembers.present) {
      map['max_members'] = drift.Variable<int>(maxMembers.value);
    }
    if (password.present) {
      map['password'] = drift.Variable<String>(password.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorType: $colorType, ')
          ..write('maxMembers: $maxMembers, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with drift.TableInfo<$RoutinesTable, Routine> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _scheduleIdMeta =
      const drift.VerificationMeta('scheduleId');
  @override
  late final drift.GeneratedColumn<int> scheduleId = drift.GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _routineIdMeta =
      const drift.VerificationMeta('routineId');
  @override
  late final drift.GeneratedColumn<int> routineId = drift.GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _groupIdMeta =
      const drift.VerificationMeta('groupId');
  @override
  late final drift.GeneratedColumn<int> groupId = drift.GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const drift.VerificationMeta _contentMeta =
      const drift.VerificationMeta('content');
  @override
  late final drift.GeneratedColumn<String> content =
      drift.GeneratedColumn<String>(
        'content',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _colorTypeMeta =
      const drift.VerificationMeta('colorType');
  @override
  late final drift.GeneratedColumn<int> colorType = drift.GeneratedColumn<int>(
    'color_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _isDoneMeta =
      const drift.VerificationMeta('isDone');
  @override
  late final drift.GeneratedColumn<bool> isDone = drift.GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  static const drift.VerificationMeta _startDateMeta =
      const drift.VerificationMeta('startDate');
  @override
  late final drift.GeneratedColumn<DateTime> startDate =
      drift.GeneratedColumn<DateTime>(
        'start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _endDateMeta =
      const drift.VerificationMeta('endDate');
  @override
  late final drift.GeneratedColumn<DateTime> endDate =
      drift.GeneratedColumn<DateTime>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _timeMinutesMeta =
      const drift.VerificationMeta('timeMinutes');
  @override
  late final drift.GeneratedColumn<int> timeMinutes =
      drift.GeneratedColumn<int>(
        'time_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _weekDaysMeta =
      const drift.VerificationMeta('weekDays');
  @override
  late final drift.GeneratedColumn<String> weekDays =
      drift.GeneratedColumn<String>(
        'week_days',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _scheduleTypeMeta =
      const drift.VerificationMeta('scheduleType');
  @override
  late final drift.GeneratedColumn<String> scheduleType =
      drift.GeneratedColumn<String>(
        'schedule_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('ROUTINE'),
      );
  static const drift.VerificationMeta _categoryIdMeta =
      const drift.VerificationMeta('categoryId');
  @override
  late final drift.GeneratedColumn<int> categoryId = drift.GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _alarmMinutesMeta =
      const drift.VerificationMeta('alarmMinutes');
  @override
  late final drift.GeneratedColumn<int> alarmMinutes =
      drift.GeneratedColumn<int>(
        'alarm_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _isDeletedMeta =
      const drift.VerificationMeta('isDeleted');
  @override
  late final drift.GeneratedColumn<bool> isDeleted =
      drift.GeneratedColumn<bool>(
        'is_deleted',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_deleted" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _isSyncedMeta =
      const drift.VerificationMeta('isSynced');
  @override
  late final drift.GeneratedColumn<bool> isSynced = drift.GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(true),
  );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    scheduleId,
    routineId,
    groupId,
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
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
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
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends drift.DataClass implements drift.Insertable<Routine> {
  final int id;
  final int? scheduleId;
  final int? routineId;
  final int? groupId;
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
  final bool isDeleted;
  final bool isSynced;
  const Routine({
    required this.id,
    this.scheduleId,
    this.routineId,
    this.groupId,
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
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = drift.Variable<int>(scheduleId);
    }
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = drift.Variable<int>(routineId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = drift.Variable<int>(groupId);
    }
    map['content'] = drift.Variable<String>(content);
    map['color_type'] = drift.Variable<int>(colorType);
    map['is_done'] = drift.Variable<bool>(isDone);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = drift.Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = drift.Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = drift.Variable<int>(timeMinutes);
    }
    if (!nullToAbsent || weekDays != null) {
      map['week_days'] = drift.Variable<String>(weekDays);
    }
    map['schedule_type'] = drift.Variable<String>(scheduleType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = drift.Variable<int>(categoryId);
    }
    if (!nullToAbsent || alarmMinutes != null) {
      map['alarm_minutes'] = drift.Variable<int>(alarmMinutes);
    }
    map['is_deleted'] = drift.Variable<bool>(isDeleted);
    map['is_synced'] = drift.Variable<bool>(isSynced);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: drift.Value(id),
      scheduleId:
          scheduleId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(scheduleId),
      routineId:
          routineId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(routineId),
      groupId:
          groupId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(groupId),
      content: drift.Value(content),
      colorType: drift.Value(colorType),
      isDone: drift.Value(isDone),
      startDate:
          startDate == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(startDate),
      endDate:
          endDate == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(endDate),
      timeMinutes:
          timeMinutes == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(timeMinutes),
      weekDays:
          weekDays == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(weekDays),
      scheduleType: drift.Value(scheduleType),
      categoryId:
          categoryId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(categoryId),
      alarmMinutes:
          alarmMinutes == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(alarmMinutes),
      isDeleted: drift.Value(isDeleted),
      isSynced: drift.Value(isSynced),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      routineId: serializer.fromJson<int?>(json['routineId']),
      groupId: serializer.fromJson<int?>(json['groupId']),
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
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'routineId': serializer.toJson<int?>(routineId),
      'groupId': serializer.toJson<int?>(groupId),
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
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Routine copyWith({
    int? id,
    drift.Value<int?> scheduleId = const drift.Value.absent(),
    drift.Value<int?> routineId = const drift.Value.absent(),
    drift.Value<int?> groupId = const drift.Value.absent(),
    String? content,
    int? colorType,
    bool? isDone,
    drift.Value<DateTime?> startDate = const drift.Value.absent(),
    drift.Value<DateTime?> endDate = const drift.Value.absent(),
    drift.Value<int?> timeMinutes = const drift.Value.absent(),
    drift.Value<String?> weekDays = const drift.Value.absent(),
    String? scheduleType,
    drift.Value<int?> categoryId = const drift.Value.absent(),
    drift.Value<int?> alarmMinutes = const drift.Value.absent(),
    bool? isDeleted,
    bool? isSynced,
  }) => Routine(
    id: id ?? this.id,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    routineId: routineId.present ? routineId.value : this.routineId,
    groupId: groupId.present ? groupId.value : this.groupId,
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
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
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
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('routineId: $routineId, ')
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('weekDays: $weekDays, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    routineId,
    groupId,
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
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.routineId == this.routineId &&
          other.groupId == this.groupId &&
          other.content == this.content &&
          other.colorType == this.colorType &&
          other.isDone == this.isDone &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.timeMinutes == this.timeMinutes &&
          other.weekDays == this.weekDays &&
          other.scheduleType == this.scheduleType &&
          other.categoryId == this.categoryId &&
          other.alarmMinutes == this.alarmMinutes &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class RoutinesCompanion extends drift.UpdateCompanion<Routine> {
  final drift.Value<int> id;
  final drift.Value<int?> scheduleId;
  final drift.Value<int?> routineId;
  final drift.Value<int?> groupId;
  final drift.Value<String> content;
  final drift.Value<int> colorType;
  final drift.Value<bool> isDone;
  final drift.Value<DateTime?> startDate;
  final drift.Value<DateTime?> endDate;
  final drift.Value<int?> timeMinutes;
  final drift.Value<String?> weekDays;
  final drift.Value<String> scheduleType;
  final drift.Value<int?> categoryId;
  final drift.Value<int?> alarmMinutes;
  final drift.Value<bool> isDeleted;
  final drift.Value<bool> isSynced;
  const RoutinesCompanion({
    this.id = const drift.Value.absent(),
    this.scheduleId = const drift.Value.absent(),
    this.routineId = const drift.Value.absent(),
    this.groupId = const drift.Value.absent(),
    this.content = const drift.Value.absent(),
    this.colorType = const drift.Value.absent(),
    this.isDone = const drift.Value.absent(),
    this.startDate = const drift.Value.absent(),
    this.endDate = const drift.Value.absent(),
    this.timeMinutes = const drift.Value.absent(),
    this.weekDays = const drift.Value.absent(),
    this.scheduleType = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.alarmMinutes = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const drift.Value.absent(),
    this.scheduleId = const drift.Value.absent(),
    this.routineId = const drift.Value.absent(),
    this.groupId = const drift.Value.absent(),
    required String content,
    this.colorType = const drift.Value.absent(),
    this.isDone = const drift.Value.absent(),
    this.startDate = const drift.Value.absent(),
    this.endDate = const drift.Value.absent(),
    this.timeMinutes = const drift.Value.absent(),
    this.weekDays = const drift.Value.absent(),
    this.scheduleType = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.alarmMinutes = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  }) : content = drift.Value(content);
  static drift.Insertable<Routine> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? scheduleId,
    drift.Expression<int>? routineId,
    drift.Expression<int>? groupId,
    drift.Expression<String>? content,
    drift.Expression<int>? colorType,
    drift.Expression<bool>? isDone,
    drift.Expression<DateTime>? startDate,
    drift.Expression<DateTime>? endDate,
    drift.Expression<int>? timeMinutes,
    drift.Expression<String>? weekDays,
    drift.Expression<String>? scheduleType,
    drift.Expression<int>? categoryId,
    drift.Expression<int>? alarmMinutes,
    drift.Expression<bool>? isDeleted,
    drift.Expression<bool>? isSynced,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (routineId != null) 'routine_id': routineId,
      if (groupId != null) 'group_id': groupId,
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
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  RoutinesCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int?>? scheduleId,
    drift.Value<int?>? routineId,
    drift.Value<int?>? groupId,
    drift.Value<String>? content,
    drift.Value<int>? colorType,
    drift.Value<bool>? isDone,
    drift.Value<DateTime?>? startDate,
    drift.Value<DateTime?>? endDate,
    drift.Value<int?>? timeMinutes,
    drift.Value<String?>? weekDays,
    drift.Value<String>? scheduleType,
    drift.Value<int?>? categoryId,
    drift.Value<int?>? alarmMinutes,
    drift.Value<bool>? isDeleted,
    drift.Value<bool>? isSynced,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      routineId: routineId ?? this.routineId,
      groupId: groupId ?? this.groupId,
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
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = drift.Variable<int>(scheduleId.value);
    }
    if (routineId.present) {
      map['routine_id'] = drift.Variable<int>(routineId.value);
    }
    if (groupId.present) {
      map['group_id'] = drift.Variable<int>(groupId.value);
    }
    if (content.present) {
      map['content'] = drift.Variable<String>(content.value);
    }
    if (colorType.present) {
      map['color_type'] = drift.Variable<int>(colorType.value);
    }
    if (isDone.present) {
      map['is_done'] = drift.Variable<bool>(isDone.value);
    }
    if (startDate.present) {
      map['start_date'] = drift.Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = drift.Variable<DateTime>(endDate.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = drift.Variable<int>(timeMinutes.value);
    }
    if (weekDays.present) {
      map['week_days'] = drift.Variable<String>(weekDays.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = drift.Variable<String>(scheduleType.value);
    }
    if (categoryId.present) {
      map['category_id'] = drift.Variable<int>(categoryId.value);
    }
    if (alarmMinutes.present) {
      map['alarm_minutes'] = drift.Variable<int>(alarmMinutes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = drift.Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = drift.Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('routineId: $routineId, ')
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('weekDays: $weekDays, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with drift.TableInfo<$TodosTable, Todo> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _scheduleIdMeta =
      const drift.VerificationMeta('scheduleId');
  @override
  late final drift.GeneratedColumn<int> scheduleId = drift.GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _groupIdMeta =
      const drift.VerificationMeta('groupId');
  @override
  late final drift.GeneratedColumn<int> groupId = drift.GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const drift.VerificationMeta _contentMeta =
      const drift.VerificationMeta('content');
  @override
  late final drift.GeneratedColumn<String> content =
      drift.GeneratedColumn<String>(
        'content',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _colorTypeMeta =
      const drift.VerificationMeta('colorType');
  @override
  late final drift.GeneratedColumn<int> colorType = drift.GeneratedColumn<int>(
    'color_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _isDoneMeta =
      const drift.VerificationMeta('isDone');
  @override
  late final drift.GeneratedColumn<bool> isDone = drift.GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  static const drift.VerificationMeta _timeMinutesMeta =
      const drift.VerificationMeta('timeMinutes');
  @override
  late final drift.GeneratedColumn<int> timeMinutes =
      drift.GeneratedColumn<int>(
        'time_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _scheduleTypeMeta =
      const drift.VerificationMeta('scheduleType');
  @override
  late final drift.GeneratedColumn<String> scheduleType =
      drift.GeneratedColumn<String>(
        'schedule_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('TO_DO'),
      );
  static const drift.VerificationMeta _categoryIdMeta =
      const drift.VerificationMeta('categoryId');
  @override
  late final drift.GeneratedColumn<int> categoryId = drift.GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _alarmMinutesMeta =
      const drift.VerificationMeta('alarmMinutes');
  @override
  late final drift.GeneratedColumn<int> alarmMinutes =
      drift.GeneratedColumn<int>(
        'alarm_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _dateMeta = const drift.VerificationMeta(
    'date',
  );
  @override
  late final drift.GeneratedColumn<DateTime> date =
      drift.GeneratedColumn<DateTime>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _todoServerIdMeta =
      const drift.VerificationMeta('todoServerId');
  @override
  late final drift.GeneratedColumn<int> todoServerId =
      drift.GeneratedColumn<int>(
        'todo_server_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _isDeletedMeta =
      const drift.VerificationMeta('isDeleted');
  @override
  late final drift.GeneratedColumn<bool> isDeleted =
      drift.GeneratedColumn<bool>(
        'is_deleted',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_deleted" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _isSyncedMeta =
      const drift.VerificationMeta('isSynced');
  @override
  late final drift.GeneratedColumn<bool> isSynced = drift.GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(true),
  );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    scheduleId,
    groupId,
    content,
    colorType,
    isDone,
    timeMinutes,
    scheduleType,
    categoryId,
    alarmMinutes,
    date,
    todoServerId,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Todo> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
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
    if (data.containsKey('todo_server_id')) {
      context.handle(
        _todoServerIdMeta,
        todoServerId.isAcceptableOrUnknown(
          data['todo_server_id']!,
          _todoServerIdMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
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
      todoServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}todo_server_id'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends drift.DataClass implements drift.Insertable<Todo> {
  final int id;
  final int? scheduleId;
  final int? groupId;
  final String content;
  final int colorType;
  final bool isDone;
  final int? timeMinutes;
  final String scheduleType;
  final int? categoryId;
  final int? alarmMinutes;
  final DateTime date;
  final int? todoServerId;
  final bool isDeleted;
  final bool isSynced;
  const Todo({
    required this.id,
    this.scheduleId,
    this.groupId,
    required this.content,
    required this.colorType,
    required this.isDone,
    this.timeMinutes,
    required this.scheduleType,
    this.categoryId,
    this.alarmMinutes,
    required this.date,
    this.todoServerId,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = drift.Variable<int>(scheduleId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = drift.Variable<int>(groupId);
    }
    map['content'] = drift.Variable<String>(content);
    map['color_type'] = drift.Variable<int>(colorType);
    map['is_done'] = drift.Variable<bool>(isDone);
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = drift.Variable<int>(timeMinutes);
    }
    map['schedule_type'] = drift.Variable<String>(scheduleType);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = drift.Variable<int>(categoryId);
    }
    if (!nullToAbsent || alarmMinutes != null) {
      map['alarm_minutes'] = drift.Variable<int>(alarmMinutes);
    }
    map['date'] = drift.Variable<DateTime>(date);
    if (!nullToAbsent || todoServerId != null) {
      map['todo_server_id'] = drift.Variable<int>(todoServerId);
    }
    map['is_deleted'] = drift.Variable<bool>(isDeleted);
    map['is_synced'] = drift.Variable<bool>(isSynced);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: drift.Value(id),
      scheduleId:
          scheduleId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(scheduleId),
      groupId:
          groupId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(groupId),
      content: drift.Value(content),
      colorType: drift.Value(colorType),
      isDone: drift.Value(isDone),
      timeMinutes:
          timeMinutes == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(timeMinutes),
      scheduleType: drift.Value(scheduleType),
      categoryId:
          categoryId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(categoryId),
      alarmMinutes:
          alarmMinutes == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(alarmMinutes),
      date: drift.Value(date),
      todoServerId:
          todoServerId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(todoServerId),
      isDeleted: drift.Value(isDeleted),
      isSynced: drift.Value(isSynced),
    );
  }

  factory Todo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      content: serializer.fromJson<String>(json['content']),
      colorType: serializer.fromJson<int>(json['colorType']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      timeMinutes: serializer.fromJson<int?>(json['timeMinutes']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      alarmMinutes: serializer.fromJson<int?>(json['alarmMinutes']),
      date: serializer.fromJson<DateTime>(json['date']),
      todoServerId: serializer.fromJson<int?>(json['todoServerId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'groupId': serializer.toJson<int?>(groupId),
      'content': serializer.toJson<String>(content),
      'colorType': serializer.toJson<int>(colorType),
      'isDone': serializer.toJson<bool>(isDone),
      'timeMinutes': serializer.toJson<int?>(timeMinutes),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'categoryId': serializer.toJson<int?>(categoryId),
      'alarmMinutes': serializer.toJson<int?>(alarmMinutes),
      'date': serializer.toJson<DateTime>(date),
      'todoServerId': serializer.toJson<int?>(todoServerId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Todo copyWith({
    int? id,
    drift.Value<int?> scheduleId = const drift.Value.absent(),
    drift.Value<int?> groupId = const drift.Value.absent(),
    String? content,
    int? colorType,
    bool? isDone,
    drift.Value<int?> timeMinutes = const drift.Value.absent(),
    String? scheduleType,
    drift.Value<int?> categoryId = const drift.Value.absent(),
    drift.Value<int?> alarmMinutes = const drift.Value.absent(),
    DateTime? date,
    drift.Value<int?> todoServerId = const drift.Value.absent(),
    bool? isDeleted,
    bool? isSynced,
  }) => Todo(
    id: id ?? this.id,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    groupId: groupId.present ? groupId.value : this.groupId,
    content: content ?? this.content,
    colorType: colorType ?? this.colorType,
    isDone: isDone ?? this.isDone,
    timeMinutes: timeMinutes.present ? timeMinutes.value : this.timeMinutes,
    scheduleType: scheduleType ?? this.scheduleType,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    alarmMinutes: alarmMinutes.present ? alarmMinutes.value : this.alarmMinutes,
    date: date ?? this.date,
    todoServerId: todoServerId.present ? todoServerId.value : this.todoServerId,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Todo copyWithCompanion(TodosCompanion data) {
    return Todo(
      id: data.id.present ? data.id.value : this.id,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
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
      todoServerId:
          data.todoServerId.present
              ? data.todoServerId.value
              : this.todoServerId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('date: $date, ')
          ..write('todoServerId: $todoServerId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    groupId,
    content,
    colorType,
    isDone,
    timeMinutes,
    scheduleType,
    categoryId,
    alarmMinutes,
    date,
    todoServerId,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.groupId == this.groupId &&
          other.content == this.content &&
          other.colorType == this.colorType &&
          other.isDone == this.isDone &&
          other.timeMinutes == this.timeMinutes &&
          other.scheduleType == this.scheduleType &&
          other.categoryId == this.categoryId &&
          other.alarmMinutes == this.alarmMinutes &&
          other.date == this.date &&
          other.todoServerId == this.todoServerId &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class TodosCompanion extends drift.UpdateCompanion<Todo> {
  final drift.Value<int> id;
  final drift.Value<int?> scheduleId;
  final drift.Value<int?> groupId;
  final drift.Value<String> content;
  final drift.Value<int> colorType;
  final drift.Value<bool> isDone;
  final drift.Value<int?> timeMinutes;
  final drift.Value<String> scheduleType;
  final drift.Value<int?> categoryId;
  final drift.Value<int?> alarmMinutes;
  final drift.Value<DateTime> date;
  final drift.Value<int?> todoServerId;
  final drift.Value<bool> isDeleted;
  final drift.Value<bool> isSynced;
  const TodosCompanion({
    this.id = const drift.Value.absent(),
    this.scheduleId = const drift.Value.absent(),
    this.groupId = const drift.Value.absent(),
    this.content = const drift.Value.absent(),
    this.colorType = const drift.Value.absent(),
    this.isDone = const drift.Value.absent(),
    this.timeMinutes = const drift.Value.absent(),
    this.scheduleType = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.alarmMinutes = const drift.Value.absent(),
    this.date = const drift.Value.absent(),
    this.todoServerId = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  });
  TodosCompanion.insert({
    this.id = const drift.Value.absent(),
    this.scheduleId = const drift.Value.absent(),
    this.groupId = const drift.Value.absent(),
    required String content,
    this.colorType = const drift.Value.absent(),
    this.isDone = const drift.Value.absent(),
    this.timeMinutes = const drift.Value.absent(),
    this.scheduleType = const drift.Value.absent(),
    this.categoryId = const drift.Value.absent(),
    this.alarmMinutes = const drift.Value.absent(),
    required DateTime date,
    this.todoServerId = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.isSynced = const drift.Value.absent(),
  }) : content = drift.Value(content),
       date = drift.Value(date);
  static drift.Insertable<Todo> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? scheduleId,
    drift.Expression<int>? groupId,
    drift.Expression<String>? content,
    drift.Expression<int>? colorType,
    drift.Expression<bool>? isDone,
    drift.Expression<int>? timeMinutes,
    drift.Expression<String>? scheduleType,
    drift.Expression<int>? categoryId,
    drift.Expression<int>? alarmMinutes,
    drift.Expression<DateTime>? date,
    drift.Expression<int>? todoServerId,
    drift.Expression<bool>? isDeleted,
    drift.Expression<bool>? isSynced,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (groupId != null) 'group_id': groupId,
      if (content != null) 'content': content,
      if (colorType != null) 'color_type': colorType,
      if (isDone != null) 'is_done': isDone,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (categoryId != null) 'category_id': categoryId,
      if (alarmMinutes != null) 'alarm_minutes': alarmMinutes,
      if (date != null) 'date': date,
      if (todoServerId != null) 'todo_server_id': todoServerId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  TodosCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int?>? scheduleId,
    drift.Value<int?>? groupId,
    drift.Value<String>? content,
    drift.Value<int>? colorType,
    drift.Value<bool>? isDone,
    drift.Value<int?>? timeMinutes,
    drift.Value<String>? scheduleType,
    drift.Value<int?>? categoryId,
    drift.Value<int?>? alarmMinutes,
    drift.Value<DateTime>? date,
    drift.Value<int?>? todoServerId,
    drift.Value<bool>? isDeleted,
    drift.Value<bool>? isSynced,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      colorType: colorType ?? this.colorType,
      isDone: isDone ?? this.isDone,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      scheduleType: scheduleType ?? this.scheduleType,
      categoryId: categoryId ?? this.categoryId,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
      date: date ?? this.date,
      todoServerId: todoServerId ?? this.todoServerId,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = drift.Variable<int>(scheduleId.value);
    }
    if (groupId.present) {
      map['group_id'] = drift.Variable<int>(groupId.value);
    }
    if (content.present) {
      map['content'] = drift.Variable<String>(content.value);
    }
    if (colorType.present) {
      map['color_type'] = drift.Variable<int>(colorType.value);
    }
    if (isDone.present) {
      map['is_done'] = drift.Variable<bool>(isDone.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = drift.Variable<int>(timeMinutes.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = drift.Variable<String>(scheduleType.value);
    }
    if (categoryId.present) {
      map['category_id'] = drift.Variable<int>(categoryId.value);
    }
    if (alarmMinutes.present) {
      map['alarm_minutes'] = drift.Variable<int>(alarmMinutes.value);
    }
    if (date.present) {
      map['date'] = drift.Variable<DateTime>(date.value);
    }
    if (todoServerId.present) {
      map['todo_server_id'] = drift.Variable<int>(todoServerId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = drift.Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = drift.Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('colorType: $colorType, ')
          ..write('isDone: $isDone, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('categoryId: $categoryId, ')
          ..write('alarmMinutes: $alarmMinutes, ')
          ..write('date: $date, ')
          ..write('todoServerId: $todoServerId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $CompletedRoutinesTable extends CompletedRoutines
    with drift.TableInfo<$CompletedRoutinesTable, CompletedRoutine> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedRoutinesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _routineIdMeta =
      const drift.VerificationMeta('routineId');
  @override
  late final drift.GeneratedColumn<int> routineId = drift.GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _dateMeta = const drift.VerificationMeta(
    'date',
  );
  @override
  late final drift.GeneratedColumn<DateTime> date =
      drift.GeneratedColumn<DateTime>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [id, routineId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_routines';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<CompletedRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
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

class CompletedRoutine extends drift.DataClass
    implements drift.Insertable<CompletedRoutine> {
  final int id;
  final int routineId;
  final DateTime date;
  const CompletedRoutine({
    required this.id,
    required this.routineId,
    required this.date,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['routine_id'] = drift.Variable<int>(routineId);
    map['date'] = drift.Variable<DateTime>(date);
    return map;
  }

  CompletedRoutinesCompanion toCompanion(bool nullToAbsent) {
    return CompletedRoutinesCompanion(
      id: drift.Value(id),
      routineId: drift.Value(routineId),
      date: drift.Value(date),
    );
  }

  factory CompletedRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return CompletedRoutine(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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

class CompletedRoutinesCompanion
    extends drift.UpdateCompanion<CompletedRoutine> {
  final drift.Value<int> id;
  final drift.Value<int> routineId;
  final drift.Value<DateTime> date;
  const CompletedRoutinesCompanion({
    this.id = const drift.Value.absent(),
    this.routineId = const drift.Value.absent(),
    this.date = const drift.Value.absent(),
  });
  CompletedRoutinesCompanion.insert({
    this.id = const drift.Value.absent(),
    required int routineId,
    required DateTime date,
  }) : routineId = drift.Value(routineId),
       date = drift.Value(date);
  static drift.Insertable<CompletedRoutine> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? routineId,
    drift.Expression<DateTime>? date,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (date != null) 'date': date,
    });
  }

  CompletedRoutinesCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int>? routineId,
    drift.Value<DateTime>? date,
  }) {
    return CompletedRoutinesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = drift.Variable<int>(routineId.value);
    }
    if (date.present) {
      map['date'] = drift.Variable<DateTime>(date.value);
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
    with drift.TableInfo<$CompletedTodosTable, CompletedTodo> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedTodosTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _todoIdMeta =
      const drift.VerificationMeta('todoId');
  @override
  late final drift.GeneratedColumn<int> todoId = drift.GeneratedColumn<int>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _dateMeta = const drift.VerificationMeta(
    'date',
  );
  @override
  late final drift.GeneratedColumn<DateTime> date =
      drift.GeneratedColumn<DateTime>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [id, todoId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_todos';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<CompletedTodo> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
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

class CompletedTodo extends drift.DataClass
    implements drift.Insertable<CompletedTodo> {
  final int id;
  final int todoId;
  final DateTime date;
  const CompletedTodo({
    required this.id,
    required this.todoId,
    required this.date,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['todo_id'] = drift.Variable<int>(todoId);
    map['date'] = drift.Variable<DateTime>(date);
    return map;
  }

  CompletedTodosCompanion toCompanion(bool nullToAbsent) {
    return CompletedTodosCompanion(
      id: drift.Value(id),
      todoId: drift.Value(todoId),
      date: drift.Value(date),
    );
  }

  factory CompletedTodo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return CompletedTodo(
      id: serializer.fromJson<int>(json['id']),
      todoId: serializer.fromJson<int>(json['todoId']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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

class CompletedTodosCompanion extends drift.UpdateCompanion<CompletedTodo> {
  final drift.Value<int> id;
  final drift.Value<int> todoId;
  final drift.Value<DateTime> date;
  const CompletedTodosCompanion({
    this.id = const drift.Value.absent(),
    this.todoId = const drift.Value.absent(),
    this.date = const drift.Value.absent(),
  });
  CompletedTodosCompanion.insert({
    this.id = const drift.Value.absent(),
    required int todoId,
    required DateTime date,
  }) : todoId = drift.Value(todoId),
       date = drift.Value(date);
  static drift.Insertable<CompletedTodo> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? todoId,
    drift.Expression<DateTime>? date,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoId != null) 'todo_id': todoId,
      if (date != null) 'date': date,
    });
  }

  CompletedTodosCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int>? todoId,
    drift.Value<DateTime>? date,
  }) {
    return CompletedTodosCompanion(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (todoId.present) {
      map['todo_id'] = drift.Variable<int>(todoId.value);
    }
    if (date.present) {
      map['date'] = drift.Variable<DateTime>(date.value);
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

class $DayLogsTable extends DayLogs
    with drift.TableInfo<$DayLogsTable, DayLog> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _dateMeta = const drift.VerificationMeta(
    'date',
  );
  @override
  late final drift.GeneratedColumn<DateTime> date =
      drift.GeneratedColumn<DateTime>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _emotionMeta =
      const drift.VerificationMeta('emotion');
  @override
  late final drift.GeneratedColumn<String> emotion =
      drift.GeneratedColumn<String>(
        'emotion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _answerMapJsonMeta =
      const drift.VerificationMeta('answerMapJson');
  @override
  late final drift.GeneratedColumn<String> answerMapJson =
      drift.GeneratedColumn<String>(
        'answer_map_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _diaryMeta = const drift.VerificationMeta(
    'diary',
  );
  @override
  late final drift.GeneratedColumn<String> diary =
      drift.GeneratedColumn<String>(
        'diary',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    date,
    emotion,
    answerMapJson,
    diary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_logs';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<DayLog> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {date};
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

class DayLog extends drift.DataClass implements drift.Insertable<DayLog> {
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['date'] = drift.Variable<DateTime>(date);
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = drift.Variable<String>(emotion);
    }
    if (!nullToAbsent || answerMapJson != null) {
      map['answer_map_json'] = drift.Variable<String>(answerMapJson);
    }
    if (!nullToAbsent || diary != null) {
      map['diary'] = drift.Variable<String>(diary);
    }
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      date: drift.Value(date),
      emotion:
          emotion == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(emotion),
      answerMapJson:
          answerMapJson == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(answerMapJson),
      diary:
          diary == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(diary),
    );
  }

  factory DayLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return DayLog(
      date: serializer.fromJson<DateTime>(json['date']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      answerMapJson: serializer.fromJson<String?>(json['answerMapJson']),
      diary: serializer.fromJson<String?>(json['diary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'emotion': serializer.toJson<String?>(emotion),
      'answerMapJson': serializer.toJson<String?>(answerMapJson),
      'diary': serializer.toJson<String?>(diary),
    };
  }

  DayLog copyWith({
    DateTime? date,
    drift.Value<String?> emotion = const drift.Value.absent(),
    drift.Value<String?> answerMapJson = const drift.Value.absent(),
    drift.Value<String?> diary = const drift.Value.absent(),
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

class DayLogsCompanion extends drift.UpdateCompanion<DayLog> {
  final drift.Value<DateTime> date;
  final drift.Value<String?> emotion;
  final drift.Value<String?> answerMapJson;
  final drift.Value<String?> diary;
  final drift.Value<int> rowid;
  const DayLogsCompanion({
    this.date = const drift.Value.absent(),
    this.emotion = const drift.Value.absent(),
    this.answerMapJson = const drift.Value.absent(),
    this.diary = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  DayLogsCompanion.insert({
    required DateTime date,
    this.emotion = const drift.Value.absent(),
    this.answerMapJson = const drift.Value.absent(),
    this.diary = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  }) : date = drift.Value(date);
  static drift.Insertable<DayLog> custom({
    drift.Expression<DateTime>? date,
    drift.Expression<String>? emotion,
    drift.Expression<String>? answerMapJson,
    drift.Expression<String>? diary,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (date != null) 'date': date,
      if (emotion != null) 'emotion': emotion,
      if (answerMapJson != null) 'answer_map_json': answerMapJson,
      if (diary != null) 'diary': diary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogsCompanion copyWith({
    drift.Value<DateTime>? date,
    drift.Value<String?>? emotion,
    drift.Value<String?>? answerMapJson,
    drift.Value<String?>? diary,
    drift.Value<int>? rowid,
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (date.present) {
      map['date'] = drift.Variable<DateTime>(date.value);
    }
    if (emotion.present) {
      map['emotion'] = drift.Variable<String>(emotion.value);
    }
    if (answerMapJson.present) {
      map['answer_map_json'] = drift.Variable<String>(answerMapJson.value);
    }
    if (diary.present) {
      map['diary'] = drift.Variable<String>(diary.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
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

class $NoticesTable extends Notices
    with drift.TableInfo<$NoticesTable, Notice> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoticesTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _groupIdMeta =
      const drift.VerificationMeta('groupId');
  @override
  late final drift.GeneratedColumn<int> groupId = drift.GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _contentMeta =
      const drift.VerificationMeta('content');
  @override
  late final drift.GeneratedColumn<String> content =
      drift.GeneratedColumn<String>(
        'content',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<DateTime> createdAt =
      drift.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _authorNameMeta =
      const drift.VerificationMeta('authorName');
  @override
  late final drift.GeneratedColumn<String> authorName =
      drift.GeneratedColumn<String>(
        'author_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _isDeletedMeta =
      const drift.VerificationMeta('isDeleted');
  @override
  late final drift.GeneratedColumn<bool> isDeleted =
      drift.GeneratedColumn<bool>(
        'is_deleted',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_deleted" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _noticeDateMeta =
      const drift.VerificationMeta('noticeDate');
  @override
  late final drift.GeneratedColumn<DateTime> noticeDate =
      drift.GeneratedColumn<DateTime>(
        'notice_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
    groupId,
    id,
    content,
    createdAt,
    authorName,
    isDeleted,
    noticeDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notices';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Notice> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('notice_date')) {
      context.handle(
        _noticeDateMeta,
        noticeDate.isAcceptableOrUnknown(data['notice_date']!, _noticeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_noticeDateMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Notice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notice(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
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
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      noticeDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}notice_date'],
          )!,
    );
  }

  @override
  $NoticesTable createAlias(String alias) {
    return $NoticesTable(attachedDatabase, alias);
  }
}

class Notice extends drift.DataClass implements drift.Insertable<Notice> {
  final int? groupId;
  final int id;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final bool isDeleted;
  final DateTime noticeDate;
  const Notice({
    this.groupId,
    required this.id,
    required this.content,
    required this.createdAt,
    this.authorName,
    required this.isDeleted,
    required this.noticeDate,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = drift.Variable<int>(groupId);
    }
    map['id'] = drift.Variable<int>(id);
    map['content'] = drift.Variable<String>(content);
    map['created_at'] = drift.Variable<DateTime>(createdAt);
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = drift.Variable<String>(authorName);
    }
    map['is_deleted'] = drift.Variable<bool>(isDeleted);
    map['notice_date'] = drift.Variable<DateTime>(noticeDate);
    return map;
  }

  NoticesCompanion toCompanion(bool nullToAbsent) {
    return NoticesCompanion(
      groupId:
          groupId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(groupId),
      id: drift.Value(id),
      content: drift.Value(content),
      createdAt: drift.Value(createdAt),
      authorName:
          authorName == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(authorName),
      isDeleted: drift.Value(isDeleted),
      noticeDate: drift.Value(noticeDate),
    );
  }

  factory Notice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Notice(
      groupId: serializer.fromJson<int?>(json['groupId']),
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      noticeDate: serializer.fromJson<DateTime>(json['noticeDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int?>(groupId),
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'authorName': serializer.toJson<String?>(authorName),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'noticeDate': serializer.toJson<DateTime>(noticeDate),
    };
  }

  Notice copyWith({
    drift.Value<int?> groupId = const drift.Value.absent(),
    int? id,
    String? content,
    DateTime? createdAt,
    drift.Value<String?> authorName = const drift.Value.absent(),
    bool? isDeleted,
    DateTime? noticeDate,
  }) => Notice(
    groupId: groupId.present ? groupId.value : this.groupId,
    id: id ?? this.id,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    authorName: authorName.present ? authorName.value : this.authorName,
    isDeleted: isDeleted ?? this.isDeleted,
    noticeDate: noticeDate ?? this.noticeDate,
  );
  Notice copyWithCompanion(NoticesCompanion data) {
    return Notice(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      authorName:
          data.authorName.present ? data.authorName.value : this.authorName,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      noticeDate:
          data.noticeDate.present ? data.noticeDate.value : this.noticeDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notice(')
          ..write('groupId: $groupId, ')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('authorName: $authorName, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('noticeDate: $noticeDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    groupId,
    id,
    content,
    createdAt,
    authorName,
    isDeleted,
    noticeDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notice &&
          other.groupId == this.groupId &&
          other.id == this.id &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.authorName == this.authorName &&
          other.isDeleted == this.isDeleted &&
          other.noticeDate == this.noticeDate);
}

class NoticesCompanion extends drift.UpdateCompanion<Notice> {
  final drift.Value<int?> groupId;
  final drift.Value<int> id;
  final drift.Value<String> content;
  final drift.Value<DateTime> createdAt;
  final drift.Value<String?> authorName;
  final drift.Value<bool> isDeleted;
  final drift.Value<DateTime> noticeDate;
  const NoticesCompanion({
    this.groupId = const drift.Value.absent(),
    this.id = const drift.Value.absent(),
    this.content = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.authorName = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    this.noticeDate = const drift.Value.absent(),
  });
  NoticesCompanion.insert({
    this.groupId = const drift.Value.absent(),
    this.id = const drift.Value.absent(),
    required String content,
    required DateTime createdAt,
    this.authorName = const drift.Value.absent(),
    this.isDeleted = const drift.Value.absent(),
    required DateTime noticeDate,
  }) : content = drift.Value(content),
       createdAt = drift.Value(createdAt),
       noticeDate = drift.Value(noticeDate);
  static drift.Insertable<Notice> custom({
    drift.Expression<int>? groupId,
    drift.Expression<int>? id,
    drift.Expression<String>? content,
    drift.Expression<DateTime>? createdAt,
    drift.Expression<String>? authorName,
    drift.Expression<bool>? isDeleted,
    drift.Expression<DateTime>? noticeDate,
  }) {
    return drift.RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (authorName != null) 'author_name': authorName,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (noticeDate != null) 'notice_date': noticeDate,
    });
  }

  NoticesCompanion copyWith({
    drift.Value<int?>? groupId,
    drift.Value<int>? id,
    drift.Value<String>? content,
    drift.Value<DateTime>? createdAt,
    drift.Value<String?>? authorName,
    drift.Value<bool>? isDeleted,
    drift.Value<DateTime>? noticeDate,
  }) {
    return NoticesCompanion(
      groupId: groupId ?? this.groupId,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      isDeleted: isDeleted ?? this.isDeleted,
      noticeDate: noticeDate ?? this.noticeDate,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (groupId.present) {
      map['group_id'] = drift.Variable<int>(groupId.value);
    }
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = drift.Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<DateTime>(createdAt.value);
    }
    if (authorName.present) {
      map['author_name'] = drift.Variable<String>(authorName.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = drift.Variable<bool>(isDeleted.value);
    }
    if (noticeDate.present) {
      map['notice_date'] = drift.Variable<DateTime>(noticeDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoticesCompanion(')
          ..write('groupId: $groupId, ')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('authorName: $authorName, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('noticeDate: $noticeDate')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with drift.TableInfo<$UsersTable, User> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _nicknameMeta =
      const drift.VerificationMeta('nickname');
  @override
  late final drift.GeneratedColumn<String> nickname =
      drift.GeneratedColumn<String>(
        'nickname',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [id, nickname];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      nickname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nickname'],
          )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends drift.DataClass implements drift.Insertable<User> {
  final int id;
  final String nickname;
  const User({required this.id, required this.nickname});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['nickname'] = drift.Variable<String>(nickname);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(id: drift.Value(id), nickname: drift.Value(nickname));
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
    };
  }

  User copyWith({int? id, String? nickname}) =>
      User(id: id ?? this.id, nickname: nickname ?? this.nickname);
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('nickname: $nickname')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User && other.id == this.id && other.nickname == this.nickname);
}

class UsersCompanion extends drift.UpdateCompanion<User> {
  final drift.Value<int> id;
  final drift.Value<String> nickname;
  const UsersCompanion({
    this.id = const drift.Value.absent(),
    this.nickname = const drift.Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const drift.Value.absent(),
    required String nickname,
  }) : nickname = drift.Value(nickname);
  static drift.Insertable<User> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? nickname,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
    });
  }

  UsersCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<String>? nickname,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = drift.Variable<String>(nickname.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with drift.TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _groupIdMeta =
      const drift.VerificationMeta('groupId');
  @override
  late final drift.GeneratedColumn<int> groupId = drift.GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
    ),
  );
  static const drift.VerificationMeta _userIdMeta =
      const drift.VerificationMeta('userId');
  @override
  late final drift.GeneratedColumn<int> userId = drift.GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const drift.VerificationMeta _roleMeta = const drift.VerificationMeta(
    'role',
  );
  @override
  late final drift.GeneratedColumn<String> role = drift.GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant('MEMBER'),
  );
  @override
  List<drift.GeneratedColumn> get $columns => [groupId, userId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<GroupMember> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {groupId, userId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      groupId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}group_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}user_id'],
          )!,
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends drift.DataClass
    implements drift.Insertable<GroupMember> {
  final int groupId;
  final int userId;
  final String role;
  const GroupMember({
    required this.groupId,
    required this.userId,
    required this.role,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['group_id'] = drift.Variable<int>(groupId);
    map['user_id'] = drift.Variable<int>(userId);
    map['role'] = drift.Variable<String>(role);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      groupId: drift.Value(groupId),
      userId: drift.Value(userId),
      role: drift.Value(role),
    );
  }

  factory GroupMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      groupId: serializer.fromJson<int>(json['groupId']),
      userId: serializer.fromJson<int>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'userId': serializer.toJson<int>(userId),
      'role': serializer.toJson<String>(role),
    };
  }

  GroupMember copyWith({int? groupId, int? userId, String? role}) =>
      GroupMember(
        groupId: groupId ?? this.groupId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, userId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.role == this.role);
}

class GroupMembersCompanion extends drift.UpdateCompanion<GroupMember> {
  final drift.Value<int> groupId;
  final drift.Value<int> userId;
  final drift.Value<String> role;
  final drift.Value<int> rowid;
  const GroupMembersCompanion({
    this.groupId = const drift.Value.absent(),
    this.userId = const drift.Value.absent(),
    this.role = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  });
  GroupMembersCompanion.insert({
    required int groupId,
    required int userId,
    this.role = const drift.Value.absent(),
    this.rowid = const drift.Value.absent(),
  }) : groupId = drift.Value(groupId),
       userId = drift.Value(userId);
  static drift.Insertable<GroupMember> custom({
    drift.Expression<int>? groupId,
    drift.Expression<int>? userId,
    drift.Expression<String>? role,
    drift.Expression<int>? rowid,
  }) {
    return drift.RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith({
    drift.Value<int>? groupId,
    drift.Value<int>? userId,
    drift.Value<String>? role,
    drift.Value<int>? rowid,
  }) {
    return GroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (groupId.present) {
      map['group_id'] = drift.Variable<int>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = drift.Variable<int>(userId.value);
    }
    if (role.present) {
      map['role'] = drift.Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = drift.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with drift.TableInfo<$NotificationsTable, Notification> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _typeMeta = const drift.VerificationMeta(
    'type',
  );
  @override
  late final drift.GeneratedColumn<String> type = drift.GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _contentMeta =
      const drift.VerificationMeta('content');
  @override
  late final drift.GeneratedColumn<String> content =
      drift.GeneratedColumn<String>(
        'content',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _timestampMeta =
      const drift.VerificationMeta('timestamp');
  @override
  late final drift.GeneratedColumn<DateTime> timestamp =
      drift.GeneratedColumn<DateTime>(
        'timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _relatedIdMeta =
      const drift.VerificationMeta('relatedId');
  @override
  late final drift.GeneratedColumn<int> relatedId = drift.GeneratedColumn<int>(
    'related_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _isReadMeta =
      const drift.VerificationMeta('isRead');
  @override
  late final drift.GeneratedColumn<bool> isRead = drift.GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  @override
  List<drift.GeneratedColumn> get $columns => [
    id,
    type,
    content,
    timestamp,
    relatedId,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  drift.VerificationContext validateIntegrity(
    drift.Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('related_id')) {
      context.handle(
        _relatedIdMeta,
        relatedId.isAcceptableOrUnknown(data['related_id']!, _relatedIdMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      relatedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_id'],
      ),
      isRead:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_read'],
          )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends drift.DataClass
    implements drift.Insertable<Notification> {
  final int id;
  final String type;
  final String content;
  final DateTime timestamp;
  final int? relatedId;
  final bool isRead;
  const Notification({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.relatedId,
    required this.isRead,
  });
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['type'] = drift.Variable<String>(type);
    map['content'] = drift.Variable<String>(content);
    map['timestamp'] = drift.Variable<DateTime>(timestamp);
    if (!nullToAbsent || relatedId != null) {
      map['related_id'] = drift.Variable<int>(relatedId);
    }
    map['is_read'] = drift.Variable<bool>(isRead);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: drift.Value(id),
      type: drift.Value(type),
      content: drift.Value(content),
      timestamp: drift.Value(timestamp),
      relatedId:
          relatedId == null && nullToAbsent
              ? const drift.Value.absent()
              : drift.Value(relatedId),
      isRead: drift.Value(isRead),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      relatedId: serializer.fromJson<int?>(json['relatedId']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'relatedId': serializer.toJson<int?>(relatedId),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  Notification copyWith({
    int? id,
    String? type,
    String? content,
    DateTime? timestamp,
    drift.Value<int?> relatedId = const drift.Value.absent(),
    bool? isRead,
  }) => Notification(
    id: id ?? this.id,
    type: type ?? this.type,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
    relatedId: relatedId.present ? relatedId.value : this.relatedId,
    isRead: isRead ?? this.isRead,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      relatedId: data.relatedId.present ? data.relatedId.value : this.relatedId,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('relatedId: $relatedId, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, content, timestamp, relatedId, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.type == this.type &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.relatedId == this.relatedId &&
          other.isRead == this.isRead);
}

class NotificationsCompanion extends drift.UpdateCompanion<Notification> {
  final drift.Value<int> id;
  final drift.Value<String> type;
  final drift.Value<String> content;
  final drift.Value<DateTime> timestamp;
  final drift.Value<int?> relatedId;
  final drift.Value<bool> isRead;
  const NotificationsCompanion({
    this.id = const drift.Value.absent(),
    this.type = const drift.Value.absent(),
    this.content = const drift.Value.absent(),
    this.timestamp = const drift.Value.absent(),
    this.relatedId = const drift.Value.absent(),
    this.isRead = const drift.Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const drift.Value.absent(),
    required String type,
    required String content,
    required DateTime timestamp,
    this.relatedId = const drift.Value.absent(),
    this.isRead = const drift.Value.absent(),
  }) : type = drift.Value(type),
       content = drift.Value(content),
       timestamp = drift.Value(timestamp);
  static drift.Insertable<Notification> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? type,
    drift.Expression<String>? content,
    drift.Expression<DateTime>? timestamp,
    drift.Expression<int>? relatedId,
    drift.Expression<bool>? isRead,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (relatedId != null) 'related_id': relatedId,
      if (isRead != null) 'is_read': isRead,
    });
  }

  NotificationsCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<String>? type,
    drift.Value<String>? content,
    drift.Value<DateTime>? timestamp,
    drift.Value<int?>? relatedId,
    drift.Value<bool>? isRead,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = drift.Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = drift.Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = drift.Variable<DateTime>(timestamp.value);
    }
    if (relatedId.present) {
      map['related_id'] = drift.Variable<int>(relatedId.value);
    }
    if (isRead.present) {
      map['is_read'] = drift.Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('relatedId: $relatedId, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends drift.GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $DayLogQuestionsTable dayLogQuestions = $DayLogQuestionsTable(
    this,
  );
  late final $GroupsTable groups = $GroupsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $CompletedRoutinesTable completedRoutines =
      $CompletedRoutinesTable(this);
  late final $CompletedTodosTable completedTodos = $CompletedTodosTable(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  late final $NoticesTable notices = $NoticesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    dayLogQuestions,
    groups,
    routines,
    todos,
    completedRoutines,
    completedTodos,
    dayLogs,
    notices,
    users,
    groupMembers,
    notifications,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> categoryId,
      required String name,
      required String type,
      required String color,
      drift.Value<bool> isDeleted,
      drift.Value<int?> serverId,
      drift.Value<bool> isSynced,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> categoryId,
      drift.Value<String> name,
      drift.Value<String> type,
      drift.Value<String> color,
      drift.Value<bool> isDeleted,
      drift.Value<int?> serverId,
      drift.Value<bool> isSynced,
    });

class $$CategoriesTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  drift.GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  drift.GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  drift.GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  drift.GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<_$LocalDatabase, $CategoriesTable, Category>,
          ),
          Category,
          drift.PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$LocalDatabase db, $CategoriesTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                drift.Value<String> name = const drift.Value.absent(),
                drift.Value<String> type = const drift.Value.absent(),
                drift.Value<String> color = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<int?> serverId = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                type: type,
                color: color,
                isDeleted: isDeleted,
                serverId: serverId,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                required String name,
                required String type,
                required String color,
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<int?> serverId = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                type: type,
                color: color,
                isDeleted: isDeleted,
                serverId: serverId,
                isSynced: isSynced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<_$LocalDatabase, $CategoriesTable, Category>,
      ),
      Category,
      drift.PrefetchHooks Function()
    >;
typedef $$DayLogQuestionsTableCreateCompanionBuilder =
    DayLogQuestionsCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> serverId,
      required String question,
      drift.Value<String> emoji,
    });
typedef $$DayLogQuestionsTableUpdateCompanionBuilder =
    DayLogQuestionsCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> serverId,
      drift.Value<String> question,
      drift.Value<String> emoji,
    });

class $$DayLogQuestionsTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$DayLogQuestionsTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$DayLogQuestionsTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $DayLogQuestionsTable> {
  $$DayLogQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  drift.GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  drift.GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);
}

class $$DayLogQuestionsTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<
              _$LocalDatabase,
              $DayLogQuestionsTable,
              DayLogQuestion
            >,
          ),
          DayLogQuestion,
          drift.PrefetchHooks Function()
        > {
  $$DayLogQuestionsTableTableManager(
    _$LocalDatabase db,
    $DayLogQuestionsTable table,
  ) : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> serverId = const drift.Value.absent(),
                drift.Value<String> question = const drift.Value.absent(),
                drift.Value<String> emoji = const drift.Value.absent(),
              }) => DayLogQuestionsCompanion(
                id: id,
                serverId: serverId,
                question: question,
                emoji: emoji,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> serverId = const drift.Value.absent(),
                required String question,
                drift.Value<String> emoji = const drift.Value.absent(),
              }) => DayLogQuestionsCompanion.insert(
                id: id,
                serverId: serverId,
                question: question,
                emoji: emoji,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogQuestionsTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<
          _$LocalDatabase,
          $DayLogQuestionsTable,
          DayLogQuestion
        >,
      ),
      DayLogQuestion,
      drift.PrefetchHooks Function()
    >;
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      drift.Value<int> id,
      required String name,
      drift.Value<String?> description,
      drift.Value<int> colorType,
      drift.Value<int?> maxMembers,
      drift.Value<String?> password,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      drift.Value<int> id,
      drift.Value<String> name,
      drift.Value<String?> description,
      drift.Value<int> colorType,
      drift.Value<int?> maxMembers,
      drift.Value<String?> password,
    });

final class $$GroupsTableReferences
    extends drift.BaseReferences<_$LocalDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$RoutinesTable, List<Routine>>
  _routinesRefsTable(_$LocalDatabase db) => drift.MultiTypedResultKey.fromTable(
    db.routines,
    aliasName: drift.$_aliasNameGenerator(db.groups.id, db.routines.groupId),
  );

  $$RoutinesTableProcessedTableManager get routinesRefs {
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesRefsTable($_db));
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static drift.MultiTypedResultKey<$TodosTable, List<Todo>> _todosRefsTable(
    _$LocalDatabase db,
  ) => drift.MultiTypedResultKey.fromTable(
    db.todos,
    aliasName: drift.$_aliasNameGenerator(db.groups.id, db.todos.groupId),
  );

  $$TodosTableProcessedTableManager get todosRefs {
    final manager = $$TodosTableTableManager(
      $_db,
      $_db.todos,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_todosRefsTable($_db));
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static drift.MultiTypedResultKey<$NoticesTable, List<Notice>>
  _noticesRefsTable(_$LocalDatabase db) => drift.MultiTypedResultKey.fromTable(
    db.notices,
    aliasName: drift.$_aliasNameGenerator(db.groups.id, db.notices.groupId),
  );

  $$NoticesTableProcessedTableManager get noticesRefs {
    final manager = $$NoticesTableTableManager(
      $_db,
      $_db.notices,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noticesRefsTable($_db));
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static drift.MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$LocalDatabase db) =>
      drift.MultiTypedResultKey.fromTable(
        db.groupMembers,
        aliasName: drift.$_aliasNameGenerator(
          db.groups.id,
          db.groupMembers.groupId,
        ),
      );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.Expression<bool> routinesRefs(
    drift.Expression<bool> Function($$RoutinesTableFilterComposer f) f,
  ) {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<bool> todosRefs(
    drift.Expression<bool> Function($$TodosTableFilterComposer f) f,
  ) {
    final $$TodosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableFilterComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<bool> noticesRefs(
    drift.Expression<bool> Function($$NoticesTableFilterComposer f) f,
  ) {
    final $$NoticesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notices,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoticesTableFilterComposer(
            $db: $db,
            $table: $db.notices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<bool> groupMembersRefs(
    drift.Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get colorType =>
      $composableBuilder(column: $table.colorType, builder: (column) => column);

  drift.GeneratedColumn<int> get maxMembers => $composableBuilder(
    column: $table.maxMembers,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  drift.Expression<T> routinesRefs<T extends Object>(
    drift.Expression<T> Function($$RoutinesTableAnnotationComposer a) f,
  ) {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<T> todosRefs<T extends Object>(
    drift.Expression<T> Function($$TodosTableAnnotationComposer a) f,
  ) {
    final $$TodosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todos,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodosTableAnnotationComposer(
            $db: $db,
            $table: $db.todos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<T> noticesRefs<T extends Object>(
    drift.Expression<T> Function($$NoticesTableAnnotationComposer a) f,
  ) {
    final $$NoticesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notices,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoticesTableAnnotationComposer(
            $db: $db,
            $table: $db.notices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  drift.Expression<T> groupMembersRefs<T extends Object>(
    drift.Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, $$GroupsTableReferences),
          Group,
          drift.PrefetchHooks Function({
            bool routinesRefs,
            bool todosRefs,
            bool noticesRefs,
            bool groupMembersRefs,
          })
        > {
  $$GroupsTableTableManager(_$LocalDatabase db, $GroupsTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String> name = const drift.Value.absent(),
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<int?> maxMembers = const drift.Value.absent(),
                drift.Value<String?> password = const drift.Value.absent(),
              }) => GroupsCompanion(
                id: id,
                name: name,
                description: description,
                colorType: colorType,
                maxMembers: maxMembers,
                password: password,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                required String name,
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<int?> maxMembers = const drift.Value.absent(),
                drift.Value<String?> password = const drift.Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                name: name,
                description: description,
                colorType: colorType,
                maxMembers: maxMembers,
                password: password,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GroupsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            routinesRefs = false,
            todosRefs = false,
            noticesRefs = false,
            groupMembersRefs = false,
          }) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (routinesRefs) db.routines,
                if (todosRefs) db.todos,
                if (noticesRefs) db.notices,
                if (groupMembersRefs) db.groupMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routinesRefs)
                    await drift
                        .$_getPrefetchedData<Group, $GroupsTable, Routine>(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._routinesRefsTable(db),
                          managerFromTypedResult:
                              (p0) =>
                                  $$GroupsTableReferences(
                                    db,
                                    table,
                                    p0,
                                  ).routinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                  if (todosRefs)
                    await drift.$_getPrefetchedData<Group, $GroupsTable, Todo>(
                      currentTable: table,
                      referencedTable: $$GroupsTableReferences._todosRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$GroupsTableReferences(db, table, p0).todosRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.groupId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (noticesRefs)
                    await drift
                        .$_getPrefetchedData<Group, $GroupsTable, Notice>(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._noticesRefsTable(db),
                          managerFromTypedResult:
                              (p0) =>
                                  $$GroupsTableReferences(
                                    db,
                                    table,
                                    p0,
                                  ).noticesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                  if (groupMembersRefs)
                    await drift
                        .$_getPrefetchedData<Group, $GroupsTable, GroupMember>(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult:
                              (p0) =>
                                  $$GroupsTableReferences(
                                    db,
                                    table,
                                    p0,
                                  ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, $$GroupsTableReferences),
      Group,
      drift.PrefetchHooks Function({
        bool routinesRefs,
        bool todosRefs,
        bool noticesRefs,
        bool groupMembersRefs,
      })
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> scheduleId,
      drift.Value<int?> routineId,
      drift.Value<int?> groupId,
      required String content,
      drift.Value<int> colorType,
      drift.Value<bool> isDone,
      drift.Value<DateTime?> startDate,
      drift.Value<DateTime?> endDate,
      drift.Value<int?> timeMinutes,
      drift.Value<String?> weekDays,
      drift.Value<String> scheduleType,
      drift.Value<int?> categoryId,
      drift.Value<int?> alarmMinutes,
      drift.Value<bool> isDeleted,
      drift.Value<bool> isSynced,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> scheduleId,
      drift.Value<int?> routineId,
      drift.Value<int?> groupId,
      drift.Value<String> content,
      drift.Value<int> colorType,
      drift.Value<bool> isDone,
      drift.Value<DateTime?> startDate,
      drift.Value<DateTime?> endDate,
      drift.Value<int?> timeMinutes,
      drift.Value<String?> weekDays,
      drift.Value<String> scheduleType,
      drift.Value<int?> categoryId,
      drift.Value<int?> alarmMinutes,
      drift.Value<bool> isDeleted,
      drift.Value<bool> isSynced,
    });

final class $$RoutinesTableReferences
    extends drift.BaseReferences<_$LocalDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$LocalDatabase db) =>
      db.groups.createAlias(
        drift.$_aliasNameGenerator(db.routines.groupId, db.groups.id),
      );

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get weekDays => $composableBuilder(
    column: $table.weekDays,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get weekDays => $composableBuilder(
    column: $table.weekDays,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  drift.GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  drift.GeneratedColumn<int> get colorType =>
      $composableBuilder(column: $table.colorType, builder: (column) => column);

  drift.GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  drift.GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get weekDays =>
      $composableBuilder(column: $table.weekDays, builder: (column) => column);

  drift.GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  drift.GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          drift.PrefetchHooks Function({bool groupId})
        > {
  $$RoutinesTableTableManager(_$LocalDatabase db, $RoutinesTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> scheduleId = const drift.Value.absent(),
                drift.Value<int?> routineId = const drift.Value.absent(),
                drift.Value<int?> groupId = const drift.Value.absent(),
                drift.Value<String> content = const drift.Value.absent(),
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<bool> isDone = const drift.Value.absent(),
                drift.Value<DateTime?> startDate = const drift.Value.absent(),
                drift.Value<DateTime?> endDate = const drift.Value.absent(),
                drift.Value<int?> timeMinutes = const drift.Value.absent(),
                drift.Value<String?> weekDays = const drift.Value.absent(),
                drift.Value<String> scheduleType = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                drift.Value<int?> alarmMinutes = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                scheduleId: scheduleId,
                routineId: routineId,
                groupId: groupId,
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
                isDeleted: isDeleted,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> scheduleId = const drift.Value.absent(),
                drift.Value<int?> routineId = const drift.Value.absent(),
                drift.Value<int?> groupId = const drift.Value.absent(),
                required String content,
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<bool> isDone = const drift.Value.absent(),
                drift.Value<DateTime?> startDate = const drift.Value.absent(),
                drift.Value<DateTime?> endDate = const drift.Value.absent(),
                drift.Value<int?> timeMinutes = const drift.Value.absent(),
                drift.Value<String?> weekDays = const drift.Value.absent(),
                drift.Value<String> scheduleType = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                drift.Value<int?> alarmMinutes = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                routineId: routineId,
                groupId: groupId,
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
                isDeleted: isDeleted,
                isSynced: isSynced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RoutinesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends drift.TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (groupId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$RoutinesTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$RoutinesTableReferences._groupIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      drift.PrefetchHooks Function({bool groupId})
    >;
typedef $$TodosTableCreateCompanionBuilder =
    TodosCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> scheduleId,
      drift.Value<int?> groupId,
      required String content,
      drift.Value<int> colorType,
      drift.Value<bool> isDone,
      drift.Value<int?> timeMinutes,
      drift.Value<String> scheduleType,
      drift.Value<int?> categoryId,
      drift.Value<int?> alarmMinutes,
      required DateTime date,
      drift.Value<int?> todoServerId,
      drift.Value<bool> isDeleted,
      drift.Value<bool> isSynced,
    });
typedef $$TodosTableUpdateCompanionBuilder =
    TodosCompanion Function({
      drift.Value<int> id,
      drift.Value<int?> scheduleId,
      drift.Value<int?> groupId,
      drift.Value<String> content,
      drift.Value<int> colorType,
      drift.Value<bool> isDone,
      drift.Value<int?> timeMinutes,
      drift.Value<String> scheduleType,
      drift.Value<int?> categoryId,
      drift.Value<int?> alarmMinutes,
      drift.Value<DateTime> date,
      drift.Value<int?> todoServerId,
      drift.Value<bool> isDeleted,
      drift.Value<bool> isSynced,
    });

final class $$TodosTableReferences
    extends drift.BaseReferences<_$LocalDatabase, $TodosTable, Todo> {
  $$TodosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$LocalDatabase db) => db.groups
      .createAlias(drift.$_aliasNameGenerator(db.todos.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TodosTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get todoServerId => $composableBuilder(
    column: $table.todoServerId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get colorType => $composableBuilder(
    column: $table.colorType,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get todoServerId => $composableBuilder(
    column: $table.todoServerId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => drift.ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  drift.GeneratedColumn<int> get colorType =>
      $composableBuilder(column: $table.colorType, builder: (column) => column);

  drift.GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  drift.GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get alarmMinutes => $composableBuilder(
    column: $table.alarmMinutes,
    builder: (column) => column,
  );

  drift.GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  drift.GeneratedColumn<int> get todoServerId => $composableBuilder(
    column: $table.todoServerId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  drift.GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodosTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $TodosTable,
          Todo,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (Todo, $$TodosTableReferences),
          Todo,
          drift.PrefetchHooks Function({bool groupId})
        > {
  $$TodosTableTableManager(_$LocalDatabase db, $TodosTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> scheduleId = const drift.Value.absent(),
                drift.Value<int?> groupId = const drift.Value.absent(),
                drift.Value<String> content = const drift.Value.absent(),
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<bool> isDone = const drift.Value.absent(),
                drift.Value<int?> timeMinutes = const drift.Value.absent(),
                drift.Value<String> scheduleType = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                drift.Value<int?> alarmMinutes = const drift.Value.absent(),
                drift.Value<DateTime> date = const drift.Value.absent(),
                drift.Value<int?> todoServerId = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => TodosCompanion(
                id: id,
                scheduleId: scheduleId,
                groupId: groupId,
                content: content,
                colorType: colorType,
                isDone: isDone,
                timeMinutes: timeMinutes,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
                date: date,
                todoServerId: todoServerId,
                isDeleted: isDeleted,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int?> scheduleId = const drift.Value.absent(),
                drift.Value<int?> groupId = const drift.Value.absent(),
                required String content,
                drift.Value<int> colorType = const drift.Value.absent(),
                drift.Value<bool> isDone = const drift.Value.absent(),
                drift.Value<int?> timeMinutes = const drift.Value.absent(),
                drift.Value<String> scheduleType = const drift.Value.absent(),
                drift.Value<int?> categoryId = const drift.Value.absent(),
                drift.Value<int?> alarmMinutes = const drift.Value.absent(),
                required DateTime date,
                drift.Value<int?> todoServerId = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<bool> isSynced = const drift.Value.absent(),
              }) => TodosCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                groupId: groupId,
                content: content,
                colorType: colorType,
                isDone: isDone,
                timeMinutes: timeMinutes,
                scheduleType: scheduleType,
                categoryId: categoryId,
                alarmMinutes: alarmMinutes,
                date: date,
                todoServerId: todoServerId,
                isDeleted: isDeleted,
                isSynced: isSynced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TodosTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends drift.TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (groupId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$TodosTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$TodosTableReferences._groupIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TodosTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $TodosTable,
      Todo,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (Todo, $$TodosTableReferences),
      Todo,
      drift.PrefetchHooks Function({bool groupId})
    >;
typedef $$CompletedRoutinesTableCreateCompanionBuilder =
    CompletedRoutinesCompanion Function({
      drift.Value<int> id,
      required int routineId,
      required DateTime date,
    });
typedef $$CompletedRoutinesTableUpdateCompanionBuilder =
    CompletedRoutinesCompanion Function({
      drift.Value<int> id,
      drift.Value<int> routineId,
      drift.Value<DateTime> date,
    });

class $$CompletedRoutinesTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$CompletedRoutinesTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$CompletedRoutinesTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $CompletedRoutinesTable> {
  $$CompletedRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$CompletedRoutinesTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<
              _$LocalDatabase,
              $CompletedRoutinesTable,
              CompletedRoutine
            >,
          ),
          CompletedRoutine,
          drift.PrefetchHooks Function()
        > {
  $$CompletedRoutinesTableTableManager(
    _$LocalDatabase db,
    $CompletedRoutinesTable table,
  ) : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int> routineId = const drift.Value.absent(),
                drift.Value<DateTime> date = const drift.Value.absent(),
              }) => CompletedRoutinesCompanion(
                id: id,
                routineId: routineId,
                date: date,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
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
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedRoutinesTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<
          _$LocalDatabase,
          $CompletedRoutinesTable,
          CompletedRoutine
        >,
      ),
      CompletedRoutine,
      drift.PrefetchHooks Function()
    >;
typedef $$CompletedTodosTableCreateCompanionBuilder =
    CompletedTodosCompanion Function({
      drift.Value<int> id,
      required int todoId,
      required DateTime date,
    });
typedef $$CompletedTodosTableUpdateCompanionBuilder =
    CompletedTodosCompanion Function({
      drift.Value<int> id,
      drift.Value<int> todoId,
      drift.Value<DateTime> date,
    });

class $$CompletedTodosTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$CompletedTodosTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$CompletedTodosTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $CompletedTodosTable> {
  $$CompletedTodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$CompletedTodosTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<
              _$LocalDatabase,
              $CompletedTodosTable,
              CompletedTodo
            >,
          ),
          CompletedTodo,
          drift.PrefetchHooks Function()
        > {
  $$CompletedTodosTableTableManager(
    _$LocalDatabase db,
    $CompletedTodosTable table,
  ) : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int> todoId = const drift.Value.absent(),
                drift.Value<DateTime> date = const drift.Value.absent(),
              }) => CompletedTodosCompanion(id: id, todoId: todoId, date: date),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
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
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedTodosTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<
          _$LocalDatabase,
          $CompletedTodosTable,
          CompletedTodo
        >,
      ),
      CompletedTodo,
      drift.PrefetchHooks Function()
    >;
typedef $$DayLogsTableCreateCompanionBuilder =
    DayLogsCompanion Function({
      required DateTime date,
      drift.Value<String?> emotion,
      drift.Value<String?> answerMapJson,
      drift.Value<String?> diary,
      drift.Value<int> rowid,
    });
typedef $$DayLogsTableUpdateCompanionBuilder =
    DayLogsCompanion Function({
      drift.Value<DateTime> date,
      drift.Value<String?> emotion,
      drift.Value<String?> answerMapJson,
      drift.Value<String?> diary,
      drift.Value<int> rowid,
    });

class $$DayLogsTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get diary => $composableBuilder(
    column: $table.diary,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get diary => $composableBuilder(
    column: $table.diary,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  drift.GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  drift.GeneratedColumn<String> get answerMapJson => $composableBuilder(
    column: $table.answerMapJson,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get diary =>
      $composableBuilder(column: $table.diary, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $DayLogsTable,
          DayLog,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (
            DayLog,
            drift.BaseReferences<_$LocalDatabase, $DayLogsTable, DayLog>,
          ),
          DayLog,
          drift.PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$LocalDatabase db, $DayLogsTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<DateTime> date = const drift.Value.absent(),
                drift.Value<String?> emotion = const drift.Value.absent(),
                drift.Value<String?> answerMapJson = const drift.Value.absent(),
                drift.Value<String?> diary = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
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
                drift.Value<String?> emotion = const drift.Value.absent(),
                drift.Value<String?> answerMapJson = const drift.Value.absent(),
                drift.Value<String?> diary = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
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
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $DayLogsTable,
      DayLog,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLog, drift.BaseReferences<_$LocalDatabase, $DayLogsTable, DayLog>),
      DayLog,
      drift.PrefetchHooks Function()
    >;
typedef $$NoticesTableCreateCompanionBuilder =
    NoticesCompanion Function({
      drift.Value<int?> groupId,
      drift.Value<int> id,
      required String content,
      required DateTime createdAt,
      drift.Value<String?> authorName,
      drift.Value<bool> isDeleted,
      required DateTime noticeDate,
    });
typedef $$NoticesTableUpdateCompanionBuilder =
    NoticesCompanion Function({
      drift.Value<int?> groupId,
      drift.Value<int> id,
      drift.Value<String> content,
      drift.Value<DateTime> createdAt,
      drift.Value<String?> authorName,
      drift.Value<bool> isDeleted,
      drift.Value<DateTime> noticeDate,
    });

final class $$NoticesTableReferences
    extends drift.BaseReferences<_$LocalDatabase, $NoticesTable, Notice> {
  $$NoticesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$LocalDatabase db) =>
      db.groups.createAlias(
        drift.$_aliasNameGenerator(db.notices.groupId, db.groups.id),
      );

  $$GroupsTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<int>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoticesTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $NoticesTable> {
  $$NoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get noticeDate => $composableBuilder(
    column: $table.noticeDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoticesTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $NoticesTable> {
  $$NoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get noticeDate => $composableBuilder(
    column: $table.noticeDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoticesTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $NoticesTable> {
  $$NoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get noticeDate => $composableBuilder(
    column: $table.noticeDate,
    builder: (column) => column,
  );

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoticesTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $NoticesTable,
          Notice,
          $$NoticesTableFilterComposer,
          $$NoticesTableOrderingComposer,
          $$NoticesTableAnnotationComposer,
          $$NoticesTableCreateCompanionBuilder,
          $$NoticesTableUpdateCompanionBuilder,
          (Notice, $$NoticesTableReferences),
          Notice,
          drift.PrefetchHooks Function({bool groupId})
        > {
  $$NoticesTableTableManager(_$LocalDatabase db, $NoticesTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$NoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$NoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<int?> groupId = const drift.Value.absent(),
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String> content = const drift.Value.absent(),
                drift.Value<DateTime> createdAt = const drift.Value.absent(),
                drift.Value<String?> authorName = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                drift.Value<DateTime> noticeDate = const drift.Value.absent(),
              }) => NoticesCompanion(
                groupId: groupId,
                id: id,
                content: content,
                createdAt: createdAt,
                authorName: authorName,
                isDeleted: isDeleted,
                noticeDate: noticeDate,
              ),
          createCompanionCallback:
              ({
                drift.Value<int?> groupId = const drift.Value.absent(),
                drift.Value<int> id = const drift.Value.absent(),
                required String content,
                required DateTime createdAt,
                drift.Value<String?> authorName = const drift.Value.absent(),
                drift.Value<bool> isDeleted = const drift.Value.absent(),
                required DateTime noticeDate,
              }) => NoticesCompanion.insert(
                groupId: groupId,
                id: id,
                content: content,
                createdAt: createdAt,
                authorName: authorName,
                isDeleted: isDeleted,
                noticeDate: noticeDate,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$NoticesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends drift.TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (groupId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$NoticesTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$NoticesTableReferences._groupIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoticesTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $NoticesTable,
      Notice,
      $$NoticesTableFilterComposer,
      $$NoticesTableOrderingComposer,
      $$NoticesTableAnnotationComposer,
      $$NoticesTableCreateCompanionBuilder,
      $$NoticesTableUpdateCompanionBuilder,
      (Notice, $$NoticesTableReferences),
      Notice,
      drift.PrefetchHooks Function({bool groupId})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({drift.Value<int> id, required String nickname});
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      drift.Value<int> id,
      drift.Value<String> nickname,
    });

final class $$UsersTableReferences
    extends drift.BaseReferences<_$LocalDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static drift.MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
  _groupMembersRefsTable(_$LocalDatabase db) => drift
      .MultiTypedResultKey.fromTable(
    db.groupMembers,
    aliasName: drift.$_aliasNameGenerator(db.users.id, db.groupMembers.userId),
  );

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager(
      $_db,
      $_db.groupMembers,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.Expression<bool> groupMembersRefs(
    drift.Expression<bool> Function($$GroupMembersTableFilterComposer f) f,
  ) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableFilterComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  drift.Expression<T> groupMembersRefs<T extends Object>(
    drift.Expression<T> Function($$GroupMembersTableAnnotationComposer a) f,
  ) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMembers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          drift.PrefetchHooks Function({bool groupMembersRefs})
        > {
  $$UsersTableTableManager(_$LocalDatabase db, $UsersTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String> nickname = const drift.Value.absent(),
              }) => UsersCompanion(id: id, nickname: nickname),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                required String nickname,
              }) => UsersCompanion.insert(id: id, nickname: nickname),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UsersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({groupMembersRefs = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (groupMembersRefs) db.groupMembers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await drift
                        .$_getPrefetchedData<User, $UsersTable, GroupMember>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._groupMembersRefsTable(db),
                          managerFromTypedResult:
                              (p0) =>
                                  $$UsersTableReferences(
                                    db,
                                    table,
                                    p0,
                                  ).groupMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      drift.PrefetchHooks Function({bool groupMembersRefs})
    >;
typedef $$GroupMembersTableCreateCompanionBuilder =
    GroupMembersCompanion Function({
      required int groupId,
      required int userId,
      drift.Value<String> role,
      drift.Value<int> rowid,
    });
typedef $$GroupMembersTableUpdateCompanionBuilder =
    GroupMembersCompanion Function({
      drift.Value<int> groupId,
      drift.Value<int> userId,
      drift.Value<String> role,
      drift.Value<int> rowid,
    });

final class $$GroupMembersTableReferences
    extends
        drift.BaseReferences<_$LocalDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$LocalDatabase db) =>
      db.groups.createAlias(
        drift.$_aliasNameGenerator(db.groupMembers.groupId, db.groups.id),
      );

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$LocalDatabase db) => db.users.createAlias(
    drift.$_aliasNameGenerator(db.groupMembers.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return drift.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupMembersTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => drift.ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => drift.ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembersTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $GroupMembersTable,
          GroupMember,
          $$GroupMembersTableFilterComposer,
          $$GroupMembersTableOrderingComposer,
          $$GroupMembersTableAnnotationComposer,
          $$GroupMembersTableCreateCompanionBuilder,
          $$GroupMembersTableUpdateCompanionBuilder,
          (GroupMember, $$GroupMembersTableReferences),
          GroupMember,
          drift.PrefetchHooks Function({bool groupId, bool userId})
        > {
  $$GroupMembersTableTableManager(_$LocalDatabase db, $GroupMembersTable table)
    : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                drift.Value<int> groupId = const drift.Value.absent(),
                drift.Value<int> userId = const drift.Value.absent(),
                drift.Value<String> role = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => GroupMembersCompanion(
                groupId: groupId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required int userId,
                drift.Value<String> role = const drift.Value.absent(),
                drift.Value<int> rowid = const drift.Value.absent(),
              }) => GroupMembersCompanion.insert(
                groupId: groupId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GroupMembersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({groupId = false, userId = false}) {
            return drift.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends drift.TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (groupId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable: $$GroupMembersTableReferences
                                ._groupIdTable(db),
                            referencedColumn:
                                $$GroupMembersTableReferences
                                    ._groupIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (userId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.userId,
                            referencedTable: $$GroupMembersTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$GroupMembersTableReferences
                                    ._userIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupMembersTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $GroupMembersTable,
      GroupMember,
      $$GroupMembersTableFilterComposer,
      $$GroupMembersTableOrderingComposer,
      $$GroupMembersTableAnnotationComposer,
      $$GroupMembersTableCreateCompanionBuilder,
      $$GroupMembersTableUpdateCompanionBuilder,
      (GroupMember, $$GroupMembersTableReferences),
      GroupMember,
      drift.PrefetchHooks Function({bool groupId, bool userId})
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      drift.Value<int> id,
      required String type,
      required String content,
      required DateTime timestamp,
      drift.Value<int?> relatedId,
      drift.Value<bool> isRead,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      drift.Value<int> id,
      drift.Value<String> type,
      drift.Value<String> content,
      drift.Value<DateTime> timestamp,
      drift.Value<int?> relatedId,
      drift.Value<bool> isRead,
    });

class $$NotificationsTableFilterComposer
    extends drift.Composer<_$LocalDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get relatedId => $composableBuilder(
    column: $table.relatedId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends drift.Composer<_$LocalDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get relatedId => $composableBuilder(
    column: $table.relatedId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends drift.Composer<_$LocalDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  drift.GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  drift.GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  drift.GeneratedColumn<int> get relatedId =>
      $composableBuilder(column: $table.relatedId, builder: (column) => column);

  drift.GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        drift.RootTableManager<
          _$LocalDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            drift.BaseReferences<
              _$LocalDatabase,
              $NotificationsTable,
              Notification
            >,
          ),
          Notification,
          drift.PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(
    _$LocalDatabase db,
    $NotificationsTable table,
  ) : super(
        drift.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$NotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String> type = const drift.Value.absent(),
                drift.Value<String> content = const drift.Value.absent(),
                drift.Value<DateTime> timestamp = const drift.Value.absent(),
                drift.Value<int?> relatedId = const drift.Value.absent(),
                drift.Value<bool> isRead = const drift.Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                type: type,
                content: content,
                timestamp: timestamp,
                relatedId: relatedId,
                isRead: isRead,
              ),
          createCompanionCallback:
              ({
                drift.Value<int> id = const drift.Value.absent(),
                required String type,
                required String content,
                required DateTime timestamp,
                drift.Value<int?> relatedId = const drift.Value.absent(),
                drift.Value<bool> isRead = const drift.Value.absent(),
              }) => NotificationsCompanion.insert(
                id: id,
                type: type,
                content: content,
                timestamp: timestamp,
                relatedId: relatedId,
                isRead: isRead,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          drift.BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    drift.ProcessedTableManager<
      _$LocalDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        drift.BaseReferences<
          _$LocalDatabase,
          $NotificationsTable,
          Notification
        >,
      ),
      Notification,
      drift.PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$DayLogQuestionsTableTableManager get dayLogQuestions =>
      $$DayLogQuestionsTableTableManager(_db, _db.dayLogQuestions);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
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
  $$NoticesTableTableManager get notices =>
      $$NoticesTableTableManager(_db, _db.notices);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
}
