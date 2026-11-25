import 'package:drift/drift.dart';

import '../../domain/entities/glucose_context.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/repositories/glucose_repository.dart';
import '../database/app_database.dart' hide GlucoseReading;

class DatabaseGlucoseRepository implements GlucoseRepository {
  const DatabaseGlucoseRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<GlucoseReading>> watchReadings({
    required DateTime start,
    required DateTime end,
  }) {
    final query = _database.select(_database.glucoseReadings)
      ..where(
        (row) =>
            row.timestamp.isBiggerOrEqualValue(start) &
            row.timestamp.isSmallerThanValue(end),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.timestamp)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => GlucoseReading(
                  id: row.id,
                  valueMgDl: row.valueMgDl,
                  timestamp: row.timestamp,
                  context: GlucoseContext.values.byName(row.context),
                  note: row.note,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveReading(GlucoseReading reading) async {
    await _database.into(_database.glucoseReadings).insertOnConflictUpdate(
          GlucoseReadingsCompanion.insert(
            id: reading.id,
            valueMgDl: reading.valueMgDl,
            timestamp: reading.timestamp,
            context: reading.context.name,
            note: Value(reading.note),
          ),
        );
  }

  @override
  Future<void> deleteReading(String id) async {
    await (_database.delete(_database.glucoseReadings)
          ..where((row) => row.id.equals(id)))
        .go();
  }
}
