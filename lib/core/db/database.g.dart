// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DayLogsTable extends DayLogs with TableInfo<$DayLogsTable, DayLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<int> flow = GeneratedColumn<int>(
    'flow',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intercourseMeta = const VerificationMeta(
    'intercourse',
  );
  @override
  late final GeneratedColumn<bool> intercourse = GeneratedColumn<bool>(
    'intercourse',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("intercourse" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _protectedSexMeta = const VerificationMeta(
    'protectedSex',
  );
  @override
  late final GeneratedColumn<bool> protectedSex = GeneratedColumn<bool>(
    'protected_sex',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("protected_sex" IN (0, 1))',
    ),
  );
  static const VerificationMeta _libidoMeta = const VerificationMeta('libido');
  @override
  late final GeneratedColumn<int> libido = GeneratedColumn<int>(
    'libido',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _moodsMeta = const VerificationMeta('moods');
  @override
  late final GeneratedColumn<String> moods = GeneratedColumn<String>(
    'moods',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bbtCelsiusMeta = const VerificationMeta(
    'bbtCelsius',
  );
  @override
  late final GeneratedColumn<double> bbtCelsius = GeneratedColumn<double>(
    'bbt_celsius',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cervicalMucusMeta = const VerificationMeta(
    'cervicalMucus',
  );
  @override
  late final GeneratedColumn<int> cervicalMucus = GeneratedColumn<int>(
    'cervical_mucus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pillTakenMeta = const VerificationMeta(
    'pillTaken',
  );
  @override
  late final GeneratedColumn<bool> pillTaken = GeneratedColumn<bool>(
    'pill_taken',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pill_taken" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    flow,
    intercourse,
    protectedSex,
    libido,
    symptoms,
    moods,
    weightKg,
    bbtCelsius,
    cervicalMucus,
    pillTaken,
    notes,
  ];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
        _flowMeta,
        flow.isAcceptableOrUnknown(data['flow']!, _flowMeta),
      );
    }
    if (data.containsKey('intercourse')) {
      context.handle(
        _intercourseMeta,
        intercourse.isAcceptableOrUnknown(
          data['intercourse']!,
          _intercourseMeta,
        ),
      );
    }
    if (data.containsKey('protected_sex')) {
      context.handle(
        _protectedSexMeta,
        protectedSex.isAcceptableOrUnknown(
          data['protected_sex']!,
          _protectedSexMeta,
        ),
      );
    }
    if (data.containsKey('libido')) {
      context.handle(
        _libidoMeta,
        libido.isAcceptableOrUnknown(data['libido']!, _libidoMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('moods')) {
      context.handle(
        _moodsMeta,
        moods.isAcceptableOrUnknown(data['moods']!, _moodsMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('bbt_celsius')) {
      context.handle(
        _bbtCelsiusMeta,
        bbtCelsius.isAcceptableOrUnknown(data['bbt_celsius']!, _bbtCelsiusMeta),
      );
    }
    if (data.containsKey('cervical_mucus')) {
      context.handle(
        _cervicalMucusMeta,
        cervicalMucus.isAcceptableOrUnknown(
          data['cervical_mucus']!,
          _cervicalMucusMeta,
        ),
      );
    }
    if (data.containsKey('pill_taken')) {
      context.handle(
        _pillTakenMeta,
        pillTaken.isAcceptableOrUnknown(data['pill_taken']!, _pillTakenMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      flow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flow'],
      ),
      intercourse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}intercourse'],
      )!,
      protectedSex: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}protected_sex'],
      ),
      libido: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}libido'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      moods: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moods'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      bbtCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bbt_celsius'],
      ),
      cervicalMucus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cervical_mucus'],
      ),
      pillTaken: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pill_taken'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DayLogsTable createAlias(String alias) {
    return $DayLogsTable(attachedDatabase, alias);
  }
}

class DayLog extends DataClass implements Insertable<DayLog> {
  final int id;

  /// Normalized to midnight (local). Unique per day.
  final DateTime date;

  /// Index into [FlowLevel], null when no flow logged.
  final int? flow;
  final bool intercourse;

  /// Null when [intercourse] is false.
  final bool? protectedSex;

  /// Index into [Libido].
  final int? libido;

  /// Comma-separated entries from [Symptoms.all].
  final String symptoms;

  /// Comma-separated entries from [Moods.all].
  final String moods;
  final double? weightKg;
  final double? bbtCelsius;

  /// Index into [CervicalMucus].
  final int? cervicalMucus;
  final bool pillTaken;
  final String? notes;
  const DayLog({
    required this.id,
    required this.date,
    this.flow,
    required this.intercourse,
    this.protectedSex,
    this.libido,
    required this.symptoms,
    required this.moods,
    this.weightKg,
    this.bbtCelsius,
    this.cervicalMucus,
    required this.pillTaken,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || flow != null) {
      map['flow'] = Variable<int>(flow);
    }
    map['intercourse'] = Variable<bool>(intercourse);
    if (!nullToAbsent || protectedSex != null) {
      map['protected_sex'] = Variable<bool>(protectedSex);
    }
    if (!nullToAbsent || libido != null) {
      map['libido'] = Variable<int>(libido);
    }
    map['symptoms'] = Variable<String>(symptoms);
    map['moods'] = Variable<String>(moods);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || bbtCelsius != null) {
      map['bbt_celsius'] = Variable<double>(bbtCelsius);
    }
    if (!nullToAbsent || cervicalMucus != null) {
      map['cervical_mucus'] = Variable<int>(cervicalMucus);
    }
    map['pill_taken'] = Variable<bool>(pillTaken);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      id: Value(id),
      date: Value(date),
      flow: flow == null && nullToAbsent ? const Value.absent() : Value(flow),
      intercourse: Value(intercourse),
      protectedSex: protectedSex == null && nullToAbsent
          ? const Value.absent()
          : Value(protectedSex),
      libido: libido == null && nullToAbsent
          ? const Value.absent()
          : Value(libido),
      symptoms: Value(symptoms),
      moods: Value(moods),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      bbtCelsius: bbtCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(bbtCelsius),
      cervicalMucus: cervicalMucus == null && nullToAbsent
          ? const Value.absent()
          : Value(cervicalMucus),
      pillTaken: Value(pillTaken),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DayLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      flow: serializer.fromJson<int?>(json['flow']),
      intercourse: serializer.fromJson<bool>(json['intercourse']),
      protectedSex: serializer.fromJson<bool?>(json['protectedSex']),
      libido: serializer.fromJson<int?>(json['libido']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      moods: serializer.fromJson<String>(json['moods']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      bbtCelsius: serializer.fromJson<double?>(json['bbtCelsius']),
      cervicalMucus: serializer.fromJson<int?>(json['cervicalMucus']),
      pillTaken: serializer.fromJson<bool>(json['pillTaken']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'flow': serializer.toJson<int?>(flow),
      'intercourse': serializer.toJson<bool>(intercourse),
      'protectedSex': serializer.toJson<bool?>(protectedSex),
      'libido': serializer.toJson<int?>(libido),
      'symptoms': serializer.toJson<String>(symptoms),
      'moods': serializer.toJson<String>(moods),
      'weightKg': serializer.toJson<double?>(weightKg),
      'bbtCelsius': serializer.toJson<double?>(bbtCelsius),
      'cervicalMucus': serializer.toJson<int?>(cervicalMucus),
      'pillTaken': serializer.toJson<bool>(pillTaken),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DayLog copyWith({
    int? id,
    DateTime? date,
    Value<int?> flow = const Value.absent(),
    bool? intercourse,
    Value<bool?> protectedSex = const Value.absent(),
    Value<int?> libido = const Value.absent(),
    String? symptoms,
    String? moods,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> bbtCelsius = const Value.absent(),
    Value<int?> cervicalMucus = const Value.absent(),
    bool? pillTaken,
    Value<String?> notes = const Value.absent(),
  }) => DayLog(
    id: id ?? this.id,
    date: date ?? this.date,
    flow: flow.present ? flow.value : this.flow,
    intercourse: intercourse ?? this.intercourse,
    protectedSex: protectedSex.present ? protectedSex.value : this.protectedSex,
    libido: libido.present ? libido.value : this.libido,
    symptoms: symptoms ?? this.symptoms,
    moods: moods ?? this.moods,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    bbtCelsius: bbtCelsius.present ? bbtCelsius.value : this.bbtCelsius,
    cervicalMucus: cervicalMucus.present
        ? cervicalMucus.value
        : this.cervicalMucus,
    pillTaken: pillTaken ?? this.pillTaken,
    notes: notes.present ? notes.value : this.notes,
  );
  DayLog copyWithCompanion(DayLogsCompanion data) {
    return DayLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      flow: data.flow.present ? data.flow.value : this.flow,
      intercourse: data.intercourse.present
          ? data.intercourse.value
          : this.intercourse,
      protectedSex: data.protectedSex.present
          ? data.protectedSex.value
          : this.protectedSex,
      libido: data.libido.present ? data.libido.value : this.libido,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      moods: data.moods.present ? data.moods.value : this.moods,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      bbtCelsius: data.bbtCelsius.present
          ? data.bbtCelsius.value
          : this.bbtCelsius,
      cervicalMucus: data.cervicalMucus.present
          ? data.cervicalMucus.value
          : this.cervicalMucus,
      pillTaken: data.pillTaken.present ? data.pillTaken.value : this.pillTaken,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('intercourse: $intercourse, ')
          ..write('protectedSex: $protectedSex, ')
          ..write('libido: $libido, ')
          ..write('symptoms: $symptoms, ')
          ..write('moods: $moods, ')
          ..write('weightKg: $weightKg, ')
          ..write('bbtCelsius: $bbtCelsius, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('pillTaken: $pillTaken, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    flow,
    intercourse,
    protectedSex,
    libido,
    symptoms,
    moods,
    weightKg,
    bbtCelsius,
    cervicalMucus,
    pillTaken,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.flow == this.flow &&
          other.intercourse == this.intercourse &&
          other.protectedSex == this.protectedSex &&
          other.libido == this.libido &&
          other.symptoms == this.symptoms &&
          other.moods == this.moods &&
          other.weightKg == this.weightKg &&
          other.bbtCelsius == this.bbtCelsius &&
          other.cervicalMucus == this.cervicalMucus &&
          other.pillTaken == this.pillTaken &&
          other.notes == this.notes);
}

class DayLogsCompanion extends UpdateCompanion<DayLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int?> flow;
  final Value<bool> intercourse;
  final Value<bool?> protectedSex;
  final Value<int?> libido;
  final Value<String> symptoms;
  final Value<String> moods;
  final Value<double?> weightKg;
  final Value<double?> bbtCelsius;
  final Value<int?> cervicalMucus;
  final Value<bool> pillTaken;
  final Value<String?> notes;
  const DayLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.flow = const Value.absent(),
    this.intercourse = const Value.absent(),
    this.protectedSex = const Value.absent(),
    this.libido = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.moods = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bbtCelsius = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.pillTaken = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DayLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.flow = const Value.absent(),
    this.intercourse = const Value.absent(),
    this.protectedSex = const Value.absent(),
    this.libido = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.moods = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.bbtCelsius = const Value.absent(),
    this.cervicalMucus = const Value.absent(),
    this.pillTaken = const Value.absent(),
    this.notes = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DayLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? flow,
    Expression<bool>? intercourse,
    Expression<bool>? protectedSex,
    Expression<int>? libido,
    Expression<String>? symptoms,
    Expression<String>? moods,
    Expression<double>? weightKg,
    Expression<double>? bbtCelsius,
    Expression<int>? cervicalMucus,
    Expression<bool>? pillTaken,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (flow != null) 'flow': flow,
      if (intercourse != null) 'intercourse': intercourse,
      if (protectedSex != null) 'protected_sex': protectedSex,
      if (libido != null) 'libido': libido,
      if (symptoms != null) 'symptoms': symptoms,
      if (moods != null) 'moods': moods,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bbtCelsius != null) 'bbt_celsius': bbtCelsius,
      if (cervicalMucus != null) 'cervical_mucus': cervicalMucus,
      if (pillTaken != null) 'pill_taken': pillTaken,
      if (notes != null) 'notes': notes,
    });
  }

  DayLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int?>? flow,
    Value<bool>? intercourse,
    Value<bool?>? protectedSex,
    Value<int?>? libido,
    Value<String>? symptoms,
    Value<String>? moods,
    Value<double?>? weightKg,
    Value<double?>? bbtCelsius,
    Value<int?>? cervicalMucus,
    Value<bool>? pillTaken,
    Value<String?>? notes,
  }) {
    return DayLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      intercourse: intercourse ?? this.intercourse,
      protectedSex: protectedSex ?? this.protectedSex,
      libido: libido ?? this.libido,
      symptoms: symptoms ?? this.symptoms,
      moods: moods ?? this.moods,
      weightKg: weightKg ?? this.weightKg,
      bbtCelsius: bbtCelsius ?? this.bbtCelsius,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      pillTaken: pillTaken ?? this.pillTaken,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (flow.present) {
      map['flow'] = Variable<int>(flow.value);
    }
    if (intercourse.present) {
      map['intercourse'] = Variable<bool>(intercourse.value);
    }
    if (protectedSex.present) {
      map['protected_sex'] = Variable<bool>(protectedSex.value);
    }
    if (libido.present) {
      map['libido'] = Variable<int>(libido.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (moods.present) {
      map['moods'] = Variable<String>(moods.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (bbtCelsius.present) {
      map['bbt_celsius'] = Variable<double>(bbtCelsius.value);
    }
    if (cervicalMucus.present) {
      map['cervical_mucus'] = Variable<int>(cervicalMucus.value);
    }
    if (pillTaken.present) {
      map['pill_taken'] = Variable<bool>(pillTaken.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('intercourse: $intercourse, ')
          ..write('protectedSex: $protectedSex, ')
          ..write('libido: $libido, ')
          ..write('symptoms: $symptoms, ')
          ..write('moods: $moods, ')
          ..write('weightKg: $weightKg, ')
          ..write('bbtCelsius: $bbtCelsius, ')
          ..write('cervicalMucus: $cervicalMucus, ')
          ..write('pillTaken: $pillTaken, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValue(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValue extends DataClass implements Insertable<KeyValue> {
  final String key;
  final String value;
  const KeyValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValue(
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

  KeyValue copyWith({String? key, String? value}) =>
      KeyValue(key: key ?? this.key, value: value ?? this.value);
  KeyValue copyWithCompanion(KeyValuesCompanion data) {
    return KeyValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValue(')
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
      (other is KeyValue && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValue> custom({
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

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
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
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PillRemindersTable extends PillReminders
    with TableInfo<$PillRemindersTable, PillReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PillRemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, hour, minute, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pill_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PillReminder> instance, {
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
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PillReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PillReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $PillRemindersTable createAlias(String alias) {
    return $PillRemindersTable(attachedDatabase, alias);
  }
}

class PillReminder extends DataClass implements Insertable<PillReminder> {
  final int id;
  final String name;
  final int hour;
  final int minute;
  final bool enabled;
  const PillReminder({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  PillRemindersCompanion toCompanion(bool nullToAbsent) {
    return PillRemindersCompanion(
      id: Value(id),
      name: Value(name),
      hour: Value(hour),
      minute: Value(minute),
      enabled: Value(enabled),
    );
  }

  factory PillReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PillReminder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  PillReminder copyWith({
    int? id,
    String? name,
    int? hour,
    int? minute,
    bool? enabled,
  }) => PillReminder(
    id: id ?? this.id,
    name: name ?? this.name,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
  );
  PillReminder copyWithCompanion(PillRemindersCompanion data) {
    return PillReminder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PillReminder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, hour, minute, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PillReminder &&
          other.id == this.id &&
          other.name == this.name &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.enabled == this.enabled);
}

class PillRemindersCompanion extends UpdateCompanion<PillReminder> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> hour;
  final Value<int> minute;
  final Value<bool> enabled;
  const PillRemindersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  PillRemindersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int hour,
    required int minute,
    this.enabled = const Value.absent(),
  }) : name = Value(name),
       hour = Value(hour),
       minute = Value(minute);
  static Insertable<PillReminder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (enabled != null) 'enabled': enabled,
    });
  }

  PillRemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? hour,
    Value<int>? minute,
    Value<bool>? enabled,
  }) {
    return PillRemindersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
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
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PillRemindersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  late final $PillRemindersTable pillReminders = $PillRemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dayLogs,
    keyValues,
    pillReminders,
  ];
}

typedef $$DayLogsTableCreateCompanionBuilder =
    DayLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int?> flow,
      Value<bool> intercourse,
      Value<bool?> protectedSex,
      Value<int?> libido,
      Value<String> symptoms,
      Value<String> moods,
      Value<double?> weightKg,
      Value<double?> bbtCelsius,
      Value<int?> cervicalMucus,
      Value<bool> pillTaken,
      Value<String?> notes,
    });
typedef $$DayLogsTableUpdateCompanionBuilder =
    DayLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int?> flow,
      Value<bool> intercourse,
      Value<bool?> protectedSex,
      Value<int?> libido,
      Value<String> symptoms,
      Value<String> moods,
      Value<double?> weightKg,
      Value<double?> bbtCelsius,
      Value<int?> cervicalMucus,
      Value<bool> pillTaken,
      Value<String?> notes,
    });

class $$DayLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get intercourse => $composableBuilder(
    column: $table.intercourse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get protectedSex => $composableBuilder(
    column: $table.protectedSex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get libido => $composableBuilder(
    column: $table.libido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moods => $composableBuilder(
    column: $table.moods,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bbtCelsius => $composableBuilder(
    column: $table.bbtCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pillTaken => $composableBuilder(
    column: $table.pillTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get intercourse => $composableBuilder(
    column: $table.intercourse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get protectedSex => $composableBuilder(
    column: $table.protectedSex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get libido => $composableBuilder(
    column: $table.libido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moods => $composableBuilder(
    column: $table.moods,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bbtCelsius => $composableBuilder(
    column: $table.bbtCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pillTaken => $composableBuilder(
    column: $table.pillTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get flow =>
      $composableBuilder(column: $table.flow, builder: (column) => column);

  GeneratedColumn<bool> get intercourse => $composableBuilder(
    column: $table.intercourse,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get protectedSex => $composableBuilder(
    column: $table.protectedSex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get libido =>
      $composableBuilder(column: $table.libido, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get moods =>
      $composableBuilder(column: $table.moods, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get bbtCelsius => $composableBuilder(
    column: $table.bbtCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cervicalMucus => $composableBuilder(
    column: $table.cervicalMucus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pillTaken =>
      $composableBuilder(column: $table.pillTaken, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayLogsTable,
          DayLog,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (DayLog, BaseReferences<_$AppDatabase, $DayLogsTable, DayLog>),
          DayLog,
          PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$AppDatabase db, $DayLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> flow = const Value.absent(),
                Value<bool> intercourse = const Value.absent(),
                Value<bool?> protectedSex = const Value.absent(),
                Value<int?> libido = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String> moods = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bbtCelsius = const Value.absent(),
                Value<int?> cervicalMucus = const Value.absent(),
                Value<bool> pillTaken = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DayLogsCompanion(
                id: id,
                date: date,
                flow: flow,
                intercourse: intercourse,
                protectedSex: protectedSex,
                libido: libido,
                symptoms: symptoms,
                moods: moods,
                weightKg: weightKg,
                bbtCelsius: bbtCelsius,
                cervicalMucus: cervicalMucus,
                pillTaken: pillTaken,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int?> flow = const Value.absent(),
                Value<bool> intercourse = const Value.absent(),
                Value<bool?> protectedSex = const Value.absent(),
                Value<int?> libido = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String> moods = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> bbtCelsius = const Value.absent(),
                Value<int?> cervicalMucus = const Value.absent(),
                Value<bool> pillTaken = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DayLogsCompanion.insert(
                id: id,
                date: date,
                flow: flow,
                intercourse: intercourse,
                protectedSex: protectedSex,
                libido: libido,
                symptoms: symptoms,
                moods: moods,
                weightKg: weightKg,
                bbtCelsius: bbtCelsius,
                cervicalMucus: cervicalMucus,
                pillTaken: pillTaken,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayLogsTable,
      DayLog,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLog, BaseReferences<_$AppDatabase, $DayLogsTable, DayLog>),
      DayLog,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder =
    KeyValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KeyValuesTableUpdateCompanionBuilder =
    KeyValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
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

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValue,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
          KeyValue,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KeyValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValue,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
      KeyValue,
      PrefetchHooks Function()
    >;
typedef $$PillRemindersTableCreateCompanionBuilder =
    PillRemindersCompanion Function({
      Value<int> id,
      required String name,
      required int hour,
      required int minute,
      Value<bool> enabled,
    });
typedef $$PillRemindersTableUpdateCompanionBuilder =
    PillRemindersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> hour,
      Value<int> minute,
      Value<bool> enabled,
    });

class $$PillRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $PillRemindersTable> {
  $$PillRemindersTableFilterComposer({
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

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PillRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $PillRemindersTable> {
  $$PillRemindersTableOrderingComposer({
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

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PillRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PillRemindersTable> {
  $$PillRemindersTableAnnotationComposer({
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

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$PillRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PillRemindersTable,
          PillReminder,
          $$PillRemindersTableFilterComposer,
          $$PillRemindersTableOrderingComposer,
          $$PillRemindersTableAnnotationComposer,
          $$PillRemindersTableCreateCompanionBuilder,
          $$PillRemindersTableUpdateCompanionBuilder,
          (
            PillReminder,
            BaseReferences<_$AppDatabase, $PillRemindersTable, PillReminder>,
          ),
          PillReminder,
          PrefetchHooks Function()
        > {
  $$PillRemindersTableTableManager(_$AppDatabase db, $PillRemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PillRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PillRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PillRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => PillRemindersCompanion(
                id: id,
                name: name,
                hour: hour,
                minute: minute,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int hour,
                required int minute,
                Value<bool> enabled = const Value.absent(),
              }) => PillRemindersCompanion.insert(
                id: id,
                name: name,
                hour: hour,
                minute: minute,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PillRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PillRemindersTable,
      PillReminder,
      $$PillRemindersTableFilterComposer,
      $$PillRemindersTableOrderingComposer,
      $$PillRemindersTableAnnotationComposer,
      $$PillRemindersTableCreateCompanionBuilder,
      $$PillRemindersTableUpdateCompanionBuilder,
      (
        PillReminder,
        BaseReferences<_$AppDatabase, $PillRemindersTable, PillReminder>,
      ),
      PillReminder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
  $$PillRemindersTableTableManager get pillReminders =>
      $$PillRemindersTableTableManager(_db, _db.pillReminders);
}
