import 'package:flutter_test/flutter_test.dart';
import 'package:gulaku/features/glucose/data/database/app_database.dart'
    hide GlucoseReading;
import 'package:gulaku/features/glucose/data/repositories/database_glucose_repository.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_context.dart';
import 'package:gulaku/features/glucose/domain/entities/glucose_reading.dart';

void main() {
  late AppDatabase database;
  late DatabaseGlucoseRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    repository = DatabaseGlucoseRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates all local tables and persists glucose readings', () async {
    final reading = _reading('reading-1', DateTime.utc(2026, 11, 25, 8), 112);

    await repository.saveReading(reading);

    final rows = await repository
        .watchReadings(
          start: DateTime.utc(2026, 11, 25),
          end: DateTime.utc(2026, 11, 26),
        )
        .first;
    expect(rows, hasLength(1));
    expect(rows.single.id, reading.id);
    expect(rows.single.valueMgDl, reading.valueMgDl);
    expect(rows.single.timestamp.isAtSameMomentAs(reading.timestamp), isTrue);
    expect(rows.single.context, reading.context);
    expect(await database.select(database.foodLogs).get(), isEmpty);
    expect(await database.select(database.medicationReminders).get(), isEmpty);
    expect(await database.select(database.userSettings).get(), isEmpty);
  });

  test('filters the requested date range and sorts newest first', () async {
    await repository.saveReading(
      _reading('older', DateTime.utc(2026, 11, 25, 8), 100),
    );
    await repository.saveReading(
      _reading('newer', DateTime.utc(2026, 11, 25, 12), 140),
    );
    await repository.saveReading(
      _reading('outside', DateTime.utc(2026, 11, 26), 180),
    );

    final rows = await repository
        .watchReadings(
          start: DateTime.utc(2026, 11, 25),
          end: DateTime.utc(2026, 11, 26),
        )
        .first;

    expect(rows.map((reading) => reading.id), ['newer', 'older']);
  });

  test('updates and deletes a reading by id', () async {
    final timestamp = DateTime.utc(2026, 11, 25, 8);
    await repository.saveReading(_reading('reading-1', timestamp, 100));
    await repository.saveReading(_reading('reading-1', timestamp, 130));

    var rows = await repository
        .watchReadings(
          start: DateTime.utc(2026, 11, 25),
          end: DateTime.utc(2026, 11, 26),
        )
        .first;
    expect(rows.single.valueMgDl, 130);

    await repository.deleteReading('reading-1');
    rows = await repository
        .watchReadings(
          start: DateTime.utc(2026, 11, 25),
          end: DateTime.utc(2026, 11, 26),
        )
        .first;
    expect(rows, isEmpty);
  });

  test('deletes all locally stored user data', () async {
    await database.into(database.glucoseReadings).insert(
          GlucoseReadingsCompanion.insert(
            id: 'reading-1',
            valueMgDl: 120,
            timestamp: DateTime.utc(2026, 11, 25, 8),
            context: 'puasa',
          ),
        );
    await database.into(database.foodLogs).insert(
          FoodLogsCompanion.insert(
            id: 'food-1',
            timestamp: DateTime.utc(2026, 11, 25, 8),
            mealType: 'sarapan',
            name: 'Nasi',
            estimatedCarbsGrams: 40,
          ),
        );
    await database.into(database.medicationReminders).insert(
          MedicationRemindersCompanion.insert(
            id: 'reminder-1',
            reminderType: 'cek_gula',
            timeMinutes: 480,
            daysOfWeek: '',
            notificationId: 1,
          ),
        );
    await database.into(database.userSettings).insert(
          UserSettingsCompanion.insert(key: 'doctor_phone', value: '123'),
        );

    await database.deleteAllUserData();

    expect(await database.select(database.glucoseReadings).get(), isEmpty);
    expect(await database.select(database.foodLogs).get(), isEmpty);
    expect(await database.select(database.medicationReminders).get(), isEmpty);
    expect(await database.select(database.userSettings).get(), isEmpty);
  });
}

GlucoseReading _reading(String id, DateTime timestamp, int valueMgDl) {
  return GlucoseReading(
    id: id,
    valueMgDl: valueMgDl,
    timestamp: timestamp,
    context: GlucoseContext.puasa,
  );
}
