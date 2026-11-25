import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/glucose_reading.dart';
import '../../domain/repositories/glucose_repository.dart';
import '../database/app_database.dart' hide GlucoseReading;
import '../repositories/database_glucose_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return DatabaseGlucoseRepository(ref.watch(appDatabaseProvider));
});

final todayGlucoseReadingsProvider =
    StreamProvider.autoDispose<List<GlucoseReading>>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref.watch(glucoseRepositoryProvider).watchReadings(
        start: start,
        end: start.add(const Duration(days: 1)),
      );
});

final lastSevenDaysGlucoseReadingsProvider =
    StreamProvider.autoDispose<List<GlucoseReading>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref.watch(glucoseRepositoryProvider).watchReadings(
        start: today.subtract(const Duration(days: 6)),
        end: today.add(const Duration(days: 1)),
      );
});

final lastThirtyDaysGlucoseReadingsProvider =
    StreamProvider.autoDispose<List<GlucoseReading>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref.watch(glucoseRepositoryProvider).watchReadings(
        start: today.subtract(const Duration(days: 29)),
        end: today.add(const Duration(days: 1)),
      );
});
