import 'package:drift/drift.dart';

class GlucoseReadings extends Table {
  TextColumn get id => text()();
  IntColumn get valueMgDl => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get context => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FoodLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get mealType => text()();
  TextColumn get name => text()();
  IntColumn get estimatedCarbsGrams => integer()();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MedicationReminders extends Table {
  TextColumn get id => text()();
  TextColumn get reminderType => text()();
  TextColumn get label => text().nullable()();
  IntColumn get timeMinutes => integer()();
  TextColumn get daysOfWeek => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get notificationId => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
