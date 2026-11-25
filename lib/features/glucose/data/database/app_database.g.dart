// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GlucoseReadingsTable extends GlucoseReadings
    with TableInfo<$GlucoseReadingsTable, GlucoseReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlucoseReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMgDlMeta =
      const VerificationMeta('valueMgDl');
  @override
  late final GeneratedColumn<int> valueMgDl = GeneratedColumn<int>(
      'value_mg_dl', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, valueMgDl, timestamp, context, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glucose_readings';
  @override
  VerificationContext validateIntegrity(Insertable<GlucoseReading> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value_mg_dl')) {
      context.handle(
          _valueMgDlMeta,
          valueMgDl.isAcceptableOrUnknown(
              data['value_mg_dl']!, _valueMgDlMeta));
    } else if (isInserting) {
      context.missing(_valueMgDlMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlucoseReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlucoseReading(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      valueMgDl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value_mg_dl'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $GlucoseReadingsTable createAlias(String alias) {
    return $GlucoseReadingsTable(attachedDatabase, alias);
  }
}

class GlucoseReading extends DataClass implements Insertable<GlucoseReading> {
  final String id;
  final int valueMgDl;
  final DateTime timestamp;
  final String context;
  final String? note;
  const GlucoseReading(
      {required this.id,
      required this.valueMgDl,
      required this.timestamp,
      required this.context,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['value_mg_dl'] = Variable<int>(valueMgDl);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['context'] = Variable<String>(context);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  GlucoseReadingsCompanion toCompanion(bool nullToAbsent) {
    return GlucoseReadingsCompanion(
      id: Value(id),
      valueMgDl: Value(valueMgDl),
      timestamp: Value(timestamp),
      context: Value(context),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory GlucoseReading.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlucoseReading(
      id: serializer.fromJson<String>(json['id']),
      valueMgDl: serializer.fromJson<int>(json['valueMgDl']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      context: serializer.fromJson<String>(json['context']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'valueMgDl': serializer.toJson<int>(valueMgDl),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'context': serializer.toJson<String>(context),
      'note': serializer.toJson<String?>(note),
    };
  }

  GlucoseReading copyWith(
          {String? id,
          int? valueMgDl,
          DateTime? timestamp,
          String? context,
          Value<String?> note = const Value.absent()}) =>
      GlucoseReading(
        id: id ?? this.id,
        valueMgDl: valueMgDl ?? this.valueMgDl,
        timestamp: timestamp ?? this.timestamp,
        context: context ?? this.context,
        note: note.present ? note.value : this.note,
      );
  GlucoseReading copyWithCompanion(GlucoseReadingsCompanion data) {
    return GlucoseReading(
      id: data.id.present ? data.id.value : this.id,
      valueMgDl: data.valueMgDl.present ? data.valueMgDl.value : this.valueMgDl,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      context: data.context.present ? data.context.value : this.context,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseReading(')
          ..write('id: $id, ')
          ..write('valueMgDl: $valueMgDl, ')
          ..write('timestamp: $timestamp, ')
          ..write('context: $context, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, valueMgDl, timestamp, context, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlucoseReading &&
          other.id == this.id &&
          other.valueMgDl == this.valueMgDl &&
          other.timestamp == this.timestamp &&
          other.context == this.context &&
          other.note == this.note);
}

class GlucoseReadingsCompanion extends UpdateCompanion<GlucoseReading> {
  final Value<String> id;
  final Value<int> valueMgDl;
  final Value<DateTime> timestamp;
  final Value<String> context;
  final Value<String?> note;
  final Value<int> rowid;
  const GlucoseReadingsCompanion({
    this.id = const Value.absent(),
    this.valueMgDl = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.context = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlucoseReadingsCompanion.insert({
    required String id,
    required int valueMgDl,
    required DateTime timestamp,
    required String context,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        valueMgDl = Value(valueMgDl),
        timestamp = Value(timestamp),
        context = Value(context);
  static Insertable<GlucoseReading> custom({
    Expression<String>? id,
    Expression<int>? valueMgDl,
    Expression<DateTime>? timestamp,
    Expression<String>? context,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valueMgDl != null) 'value_mg_dl': valueMgDl,
      if (timestamp != null) 'timestamp': timestamp,
      if (context != null) 'context': context,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlucoseReadingsCompanion copyWith(
      {Value<String>? id,
      Value<int>? valueMgDl,
      Value<DateTime>? timestamp,
      Value<String>? context,
      Value<String?>? note,
      Value<int>? rowid}) {
    return GlucoseReadingsCompanion(
      id: id ?? this.id,
      valueMgDl: valueMgDl ?? this.valueMgDl,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (valueMgDl.present) {
      map['value_mg_dl'] = Variable<int>(valueMgDl.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseReadingsCompanion(')
          ..write('id: $id, ')
          ..write('valueMgDl: $valueMgDl, ')
          ..write('timestamp: $timestamp, ')
          ..write('context: $context, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodLogsTable extends FoodLogs with TableInfo<$FoodLogsTable, FoodLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedCarbsGramsMeta =
      const VerificationMeta('estimatedCarbsGrams');
  @override
  late final GeneratedColumn<int> estimatedCarbsGrams = GeneratedColumn<int>(
      'estimated_carbs_grams', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, timestamp, mealType, name, estimatedCarbsGrams, photoPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_logs';
  @override
  VerificationContext validateIntegrity(Insertable<FoodLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('estimated_carbs_grams')) {
      context.handle(
          _estimatedCarbsGramsMeta,
          estimatedCarbsGrams.isAcceptableOrUnknown(
              data['estimated_carbs_grams']!, _estimatedCarbsGramsMeta));
    } else if (isInserting) {
      context.missing(_estimatedCarbsGramsMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      estimatedCarbsGrams: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}estimated_carbs_grams'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
    );
  }

  @override
  $FoodLogsTable createAlias(String alias) {
    return $FoodLogsTable(attachedDatabase, alias);
  }
}

class FoodLog extends DataClass implements Insertable<FoodLog> {
  final String id;
  final DateTime timestamp;
  final String mealType;
  final String name;
  final int estimatedCarbsGrams;
  final String? photoPath;
  const FoodLog(
      {required this.id,
      required this.timestamp,
      required this.mealType,
      required this.name,
      required this.estimatedCarbsGrams,
      this.photoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['meal_type'] = Variable<String>(mealType);
    map['name'] = Variable<String>(name);
    map['estimated_carbs_grams'] = Variable<int>(estimatedCarbsGrams);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  FoodLogsCompanion toCompanion(bool nullToAbsent) {
    return FoodLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      mealType: Value(mealType),
      name: Value(name),
      estimatedCarbsGrams: Value(estimatedCarbsGrams),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory FoodLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLog(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      mealType: serializer.fromJson<String>(json['mealType']),
      name: serializer.fromJson<String>(json['name']),
      estimatedCarbsGrams:
          serializer.fromJson<int>(json['estimatedCarbsGrams']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'mealType': serializer.toJson<String>(mealType),
      'name': serializer.toJson<String>(name),
      'estimatedCarbsGrams': serializer.toJson<int>(estimatedCarbsGrams),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  FoodLog copyWith(
          {String? id,
          DateTime? timestamp,
          String? mealType,
          String? name,
          int? estimatedCarbsGrams,
          Value<String?> photoPath = const Value.absent()}) =>
      FoodLog(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        mealType: mealType ?? this.mealType,
        name: name ?? this.name,
        estimatedCarbsGrams: estimatedCarbsGrams ?? this.estimatedCarbsGrams,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
      );
  FoodLog copyWithCompanion(FoodLogsCompanion data) {
    return FoodLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      name: data.name.present ? data.name.value : this.name,
      estimatedCarbsGrams: data.estimatedCarbsGrams.present
          ? data.estimatedCarbsGrams.value
          : this.estimatedCarbsGrams,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('mealType: $mealType, ')
          ..write('name: $name, ')
          ..write('estimatedCarbsGrams: $estimatedCarbsGrams, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, timestamp, mealType, name, estimatedCarbsGrams, photoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.mealType == this.mealType &&
          other.name == this.name &&
          other.estimatedCarbsGrams == this.estimatedCarbsGrams &&
          other.photoPath == this.photoPath);
}

class FoodLogsCompanion extends UpdateCompanion<FoodLog> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String> mealType;
  final Value<String> name;
  final Value<int> estimatedCarbsGrams;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const FoodLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.mealType = const Value.absent(),
    this.name = const Value.absent(),
    this.estimatedCarbsGrams = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodLogsCompanion.insert({
    required String id,
    required DateTime timestamp,
    required String mealType,
    required String name,
    required int estimatedCarbsGrams,
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp),
        mealType = Value(mealType),
        name = Value(name),
        estimatedCarbsGrams = Value(estimatedCarbsGrams);
  static Insertable<FoodLog> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? mealType,
    Expression<String>? name,
    Expression<int>? estimatedCarbsGrams,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (mealType != null) 'meal_type': mealType,
      if (name != null) 'name': name,
      if (estimatedCarbsGrams != null)
        'estimated_carbs_grams': estimatedCarbsGrams,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodLogsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? timestamp,
      Value<String>? mealType,
      Value<String>? name,
      Value<int>? estimatedCarbsGrams,
      Value<String?>? photoPath,
      Value<int>? rowid}) {
    return FoodLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      estimatedCarbsGrams: estimatedCarbsGrams ?? this.estimatedCarbsGrams,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (estimatedCarbsGrams.present) {
      map['estimated_carbs_grams'] = Variable<int>(estimatedCarbsGrams.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('mealType: $mealType, ')
          ..write('name: $name, ')
          ..write('estimatedCarbsGrams: $estimatedCarbsGrams, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationRemindersTable extends MedicationReminders
    with TableInfo<$MedicationRemindersTable, MedicationReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reminderTypeMeta =
      const VerificationMeta('reminderType');
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
      'reminder_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeMinutesMeta =
      const VerificationMeta('timeMinutes');
  @override
  late final GeneratedColumn<int> timeMinutes = GeneratedColumn<int>(
      'time_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _daysOfWeekMeta =
      const VerificationMeta('daysOfWeek');
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
      'days_of_week', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reminderType,
        label,
        timeMinutes,
        daysOfWeek,
        enabled,
        notificationId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_reminders';
  @override
  VerificationContext validateIntegrity(Insertable<MedicationReminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
          _reminderTypeMeta,
          reminderType.isAcceptableOrUnknown(
              data['reminder_type']!, _reminderTypeMeta));
    } else if (isInserting) {
      context.missing(_reminderTypeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('time_minutes')) {
      context.handle(
          _timeMinutesMeta,
          timeMinutes.isAcceptableOrUnknown(
              data['time_minutes']!, _timeMinutesMeta));
    } else if (isInserting) {
      context.missing(_timeMinutesMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
          _daysOfWeekMeta,
          daysOfWeek.isAcceptableOrUnknown(
              data['days_of_week']!, _daysOfWeekMeta));
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationReminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      reminderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_type'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      timeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_minutes'])!,
      daysOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}days_of_week'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id'])!,
    );
  }

  @override
  $MedicationRemindersTable createAlias(String alias) {
    return $MedicationRemindersTable(attachedDatabase, alias);
  }
}

class MedicationReminder extends DataClass
    implements Insertable<MedicationReminder> {
  final String id;
  final String reminderType;
  final String? label;
  final int timeMinutes;
  final String daysOfWeek;
  final bool enabled;
  final int notificationId;
  const MedicationReminder(
      {required this.id,
      required this.reminderType,
      this.label,
      required this.timeMinutes,
      required this.daysOfWeek,
      required this.enabled,
      required this.notificationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reminder_type'] = Variable<String>(reminderType);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['time_minutes'] = Variable<int>(timeMinutes);
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['enabled'] = Variable<bool>(enabled);
    map['notification_id'] = Variable<int>(notificationId);
    return map;
  }

  MedicationRemindersCompanion toCompanion(bool nullToAbsent) {
    return MedicationRemindersCompanion(
      id: Value(id),
      reminderType: Value(reminderType),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      timeMinutes: Value(timeMinutes),
      daysOfWeek: Value(daysOfWeek),
      enabled: Value(enabled),
      notificationId: Value(notificationId),
    );
  }

  factory MedicationReminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationReminder(
      id: serializer.fromJson<String>(json['id']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      label: serializer.fromJson<String?>(json['label']),
      timeMinutes: serializer.fromJson<int>(json['timeMinutes']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reminderType': serializer.toJson<String>(reminderType),
      'label': serializer.toJson<String?>(label),
      'timeMinutes': serializer.toJson<int>(timeMinutes),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'enabled': serializer.toJson<bool>(enabled),
      'notificationId': serializer.toJson<int>(notificationId),
    };
  }

  MedicationReminder copyWith(
          {String? id,
          String? reminderType,
          Value<String?> label = const Value.absent(),
          int? timeMinutes,
          String? daysOfWeek,
          bool? enabled,
          int? notificationId}) =>
      MedicationReminder(
        id: id ?? this.id,
        reminderType: reminderType ?? this.reminderType,
        label: label.present ? label.value : this.label,
        timeMinutes: timeMinutes ?? this.timeMinutes,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        enabled: enabled ?? this.enabled,
        notificationId: notificationId ?? this.notificationId,
      );
  MedicationReminder copyWithCompanion(MedicationRemindersCompanion data) {
    return MedicationReminder(
      id: data.id.present ? data.id.value : this.id,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      label: data.label.present ? data.label.value : this.label,
      timeMinutes:
          data.timeMinutes.present ? data.timeMinutes.value : this.timeMinutes,
      daysOfWeek:
          data.daysOfWeek.present ? data.daysOfWeek.value : this.daysOfWeek,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationReminder(')
          ..write('id: $id, ')
          ..write('reminderType: $reminderType, ')
          ..write('label: $label, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('enabled: $enabled, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reminderType, label, timeMinutes,
      daysOfWeek, enabled, notificationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationReminder &&
          other.id == this.id &&
          other.reminderType == this.reminderType &&
          other.label == this.label &&
          other.timeMinutes == this.timeMinutes &&
          other.daysOfWeek == this.daysOfWeek &&
          other.enabled == this.enabled &&
          other.notificationId == this.notificationId);
}

class MedicationRemindersCompanion extends UpdateCompanion<MedicationReminder> {
  final Value<String> id;
  final Value<String> reminderType;
  final Value<String?> label;
  final Value<int> timeMinutes;
  final Value<String> daysOfWeek;
  final Value<bool> enabled;
  final Value<int> notificationId;
  final Value<int> rowid;
  const MedicationRemindersCompanion({
    this.id = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.label = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.enabled = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationRemindersCompanion.insert({
    required String id,
    required String reminderType,
    this.label = const Value.absent(),
    required int timeMinutes,
    required String daysOfWeek,
    this.enabled = const Value.absent(),
    required int notificationId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        reminderType = Value(reminderType),
        timeMinutes = Value(timeMinutes),
        daysOfWeek = Value(daysOfWeek),
        notificationId = Value(notificationId);
  static Insertable<MedicationReminder> custom({
    Expression<String>? id,
    Expression<String>? reminderType,
    Expression<String>? label,
    Expression<int>? timeMinutes,
    Expression<String>? daysOfWeek,
    Expression<bool>? enabled,
    Expression<int>? notificationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderType != null) 'reminder_type': reminderType,
      if (label != null) 'label': label,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (enabled != null) 'enabled': enabled,
      if (notificationId != null) 'notification_id': notificationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationRemindersCompanion copyWith(
      {Value<String>? id,
      Value<String>? reminderType,
      Value<String?>? label,
      Value<int>? timeMinutes,
      Value<String>? daysOfWeek,
      Value<bool>? enabled,
      Value<int>? notificationId,
      Value<int>? rowid}) {
    return MedicationRemindersCompanion(
      id: id ?? this.id,
      reminderType: reminderType ?? this.reminderType,
      label: label ?? this.label,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
      notificationId: notificationId ?? this.notificationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = Variable<int>(timeMinutes.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRemindersCompanion(')
          ..write('id: $id, ')
          ..write('reminderType: $reminderType, ')
          ..write('label: $label, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('enabled: $enabled, ')
          ..write('notificationId: $notificationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String key;
  final String value;
  const UserSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserSetting copyWith({String? key, String? value}) => UserSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<UserSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GlucoseReadingsTable glucoseReadings =
      $GlucoseReadingsTable(this);
  late final $FoodLogsTable foodLogs = $FoodLogsTable(this);
  late final $MedicationRemindersTable medicationReminders =
      $MedicationRemindersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [glucoseReadings, foodLogs, medicationReminders, userSettings];
}

typedef $$GlucoseReadingsTableCreateCompanionBuilder = GlucoseReadingsCompanion
    Function({
  required String id,
  required int valueMgDl,
  required DateTime timestamp,
  required String context,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$GlucoseReadingsTableUpdateCompanionBuilder = GlucoseReadingsCompanion
    Function({
  Value<String> id,
  Value<int> valueMgDl,
  Value<DateTime> timestamp,
  Value<String> context,
  Value<String?> note,
  Value<int> rowid,
});

class $$GlucoseReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $GlucoseReadingsTable> {
  $$GlucoseReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get valueMgDl => $composableBuilder(
      column: $table.valueMgDl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$GlucoseReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GlucoseReadingsTable> {
  $$GlucoseReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get valueMgDl => $composableBuilder(
      column: $table.valueMgDl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$GlucoseReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlucoseReadingsTable> {
  $$GlucoseReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get valueMgDl =>
      $composableBuilder(column: $table.valueMgDl, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$GlucoseReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GlucoseReadingsTable,
    GlucoseReading,
    $$GlucoseReadingsTableFilterComposer,
    $$GlucoseReadingsTableOrderingComposer,
    $$GlucoseReadingsTableAnnotationComposer,
    $$GlucoseReadingsTableCreateCompanionBuilder,
    $$GlucoseReadingsTableUpdateCompanionBuilder,
    (
      GlucoseReading,
      BaseReferences<_$AppDatabase, $GlucoseReadingsTable, GlucoseReading>
    ),
    GlucoseReading,
    PrefetchHooks Function()> {
  $$GlucoseReadingsTableTableManager(
      _$AppDatabase db, $GlucoseReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlucoseReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlucoseReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlucoseReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> valueMgDl = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GlucoseReadingsCompanion(
            id: id,
            valueMgDl: valueMgDl,
            timestamp: timestamp,
            context: context,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int valueMgDl,
            required DateTime timestamp,
            required String context,
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GlucoseReadingsCompanion.insert(
            id: id,
            valueMgDl: valueMgDl,
            timestamp: timestamp,
            context: context,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GlucoseReadingsTable, GlucoseReading>(table),
                    BaseReferences<_$AppDatabase, $GlucoseReadingsTable,
                        GlucoseReading>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GlucoseReadingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GlucoseReadingsTable,
    GlucoseReading,
    $$GlucoseReadingsTableFilterComposer,
    $$GlucoseReadingsTableOrderingComposer,
    $$GlucoseReadingsTableAnnotationComposer,
    $$GlucoseReadingsTableCreateCompanionBuilder,
    $$GlucoseReadingsTableUpdateCompanionBuilder,
    (
      GlucoseReading,
      BaseReferences<_$AppDatabase, $GlucoseReadingsTable, GlucoseReading>
    ),
    GlucoseReading,
    PrefetchHooks Function()>;
typedef $$FoodLogsTableCreateCompanionBuilder = FoodLogsCompanion Function({
  required String id,
  required DateTime timestamp,
  required String mealType,
  required String name,
  required int estimatedCarbsGrams,
  Value<String?> photoPath,
  Value<int> rowid,
});
typedef $$FoodLogsTableUpdateCompanionBuilder = FoodLogsCompanion Function({
  Value<String> id,
  Value<DateTime> timestamp,
  Value<String> mealType,
  Value<String> name,
  Value<int> estimatedCarbsGrams,
  Value<String?> photoPath,
  Value<int> rowid,
});

class $$FoodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedCarbsGrams => $composableBuilder(
      column: $table.estimatedCarbsGrams,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));
}

class $$FoodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedCarbsGrams => $composableBuilder(
      column: $table.estimatedCarbsGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));
}

class $$FoodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get estimatedCarbsGrams => $composableBuilder(
      column: $table.estimatedCarbsGrams, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);
}

class $$FoodLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodLogsTable,
    FoodLog,
    $$FoodLogsTableFilterComposer,
    $$FoodLogsTableOrderingComposer,
    $$FoodLogsTableAnnotationComposer,
    $$FoodLogsTableCreateCompanionBuilder,
    $$FoodLogsTableUpdateCompanionBuilder,
    (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
    FoodLog,
    PrefetchHooks Function()> {
  $$FoodLogsTableTableManager(_$AppDatabase db, $FoodLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> estimatedCarbsGrams = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodLogsCompanion(
            id: id,
            timestamp: timestamp,
            mealType: mealType,
            name: name,
            estimatedCarbsGrams: estimatedCarbsGrams,
            photoPath: photoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime timestamp,
            required String mealType,
            required String name,
            required int estimatedCarbsGrams,
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodLogsCompanion.insert(
            id: id,
            timestamp: timestamp,
            mealType: mealType,
            name: name,
            estimatedCarbsGrams: estimatedCarbsGrams,
            photoPath: photoPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FoodLogsTable, FoodLog>(table),
                    BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodLogsTable,
    FoodLog,
    $$FoodLogsTableFilterComposer,
    $$FoodLogsTableOrderingComposer,
    $$FoodLogsTableAnnotationComposer,
    $$FoodLogsTableCreateCompanionBuilder,
    $$FoodLogsTableUpdateCompanionBuilder,
    (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
    FoodLog,
    PrefetchHooks Function()>;
typedef $$MedicationRemindersTableCreateCompanionBuilder
    = MedicationRemindersCompanion Function({
  required String id,
  required String reminderType,
  Value<String?> label,
  required int timeMinutes,
  required String daysOfWeek,
  Value<bool> enabled,
  required int notificationId,
  Value<int> rowid,
});
typedef $$MedicationRemindersTableUpdateCompanionBuilder
    = MedicationRemindersCompanion Function({
  Value<String> id,
  Value<String> reminderType,
  Value<String?> label,
  Value<int> timeMinutes,
  Value<String> daysOfWeek,
  Value<bool> enabled,
  Value<int> notificationId,
  Value<int> rowid,
});

class $$MedicationRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationRemindersTable> {
  $$MedicationRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderType => $composableBuilder(
      column: $table.reminderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeMinutes => $composableBuilder(
      column: $table.timeMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));
}

class $$MedicationRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationRemindersTable> {
  $$MedicationRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderType => $composableBuilder(
      column: $table.reminderType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeMinutes => $composableBuilder(
      column: $table.timeMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));
}

class $$MedicationRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationRemindersTable> {
  $$MedicationRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
      column: $table.reminderType, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get timeMinutes => $composableBuilder(
      column: $table.timeMinutes, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);
}

class $$MedicationRemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationRemindersTable,
    MedicationReminder,
    $$MedicationRemindersTableFilterComposer,
    $$MedicationRemindersTableOrderingComposer,
    $$MedicationRemindersTableAnnotationComposer,
    $$MedicationRemindersTableCreateCompanionBuilder,
    $$MedicationRemindersTableUpdateCompanionBuilder,
    (
      MedicationReminder,
      BaseReferences<_$AppDatabase, $MedicationRemindersTable,
          MedicationReminder>
    ),
    MedicationReminder,
    PrefetchHooks Function()> {
  $$MedicationRemindersTableTableManager(
      _$AppDatabase db, $MedicationRemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationRemindersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationRemindersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> reminderType = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<int> timeMinutes = const Value.absent(),
            Value<String> daysOfWeek = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> notificationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationRemindersCompanion(
            id: id,
            reminderType: reminderType,
            label: label,
            timeMinutes: timeMinutes,
            daysOfWeek: daysOfWeek,
            enabled: enabled,
            notificationId: notificationId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String reminderType,
            Value<String?> label = const Value.absent(),
            required int timeMinutes,
            required String daysOfWeek,
            Value<bool> enabled = const Value.absent(),
            required int notificationId,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationRemindersCompanion.insert(
            id: id,
            reminderType: reminderType,
            label: label,
            timeMinutes: timeMinutes,
            daysOfWeek: daysOfWeek,
            enabled: enabled,
            notificationId: notificationId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MedicationRemindersTable, MedicationReminder>(
                        table),
                    BaseReferences<_$AppDatabase, $MedicationRemindersTable,
                        MedicationReminder>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationRemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicationRemindersTable,
    MedicationReminder,
    $$MedicationRemindersTableFilterComposer,
    $$MedicationRemindersTableOrderingComposer,
    $$MedicationRemindersTableAnnotationComposer,
    $$MedicationRemindersTableCreateCompanionBuilder,
    $$MedicationRemindersTableUpdateCompanionBuilder,
    (
      MedicationReminder,
      BaseReferences<_$AppDatabase, $MedicationRemindersTable,
          MedicationReminder>
    ),
    MedicationReminder,
    PrefetchHooks Function()>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UserSettingsTable, UserSetting>(table),
                    BaseReferences<_$AppDatabase, $UserSettingsTable,
                        UserSetting>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GlucoseReadingsTableTableManager get glucoseReadings =>
      $$GlucoseReadingsTableTableManager(_db, _db.glucoseReadings);
  $$FoodLogsTableTableManager get foodLogs =>
      $$FoodLogsTableTableManager(_db, _db.foodLogs);
  $$MedicationRemindersTableTableManager get medicationReminders =>
      $$MedicationRemindersTableTableManager(_db, _db.medicationReminders);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
