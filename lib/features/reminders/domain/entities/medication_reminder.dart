enum ReminderType {
  glucoseCheck,
  medication;

  String get label => switch (this) {
        ReminderType.glucoseCheck => 'Cek gula',
        ReminderType.medication => 'Minum obat',
      };
}

class MedicationReminder {
  const MedicationReminder({
    required this.id,
    required this.type,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.enabled,
    required this.notificationId,
    this.label,
  });

  final String id;
  final ReminderType type;
  final String? label;
  final int hour;
  final int minute;
  final Set<int> repeatDays;
  final bool enabled;
  final int notificationId;

  bool get isValid =>
      hour >= 0 &&
      hour < 24 &&
      minute >= 0 &&
      minute < 60 &&
      repeatDays.every((day) => day >= DateTime.monday && day <= DateTime.sunday);

  MedicationReminder copyWith({
    ReminderType? type,
    String? label,
    int? hour,
    int? minute,
    Set<int>? repeatDays,
    bool? enabled,
  }) {
    return MedicationReminder(
      id: id,
      type: type ?? this.type,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      enabled: enabled ?? this.enabled,
      notificationId: notificationId,
    );
  }
}
