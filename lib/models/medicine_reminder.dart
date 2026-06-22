class MedicineReminder {
  final int id;
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final List<int> days;
  final String notes;
  final bool enabled;
  final List<String> takenOn;

  const MedicineReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    required this.days,
    required this.notes,
    required this.enabled,
    required this.takenOn,
  });

  MedicineReminder copyWith({
    int? id,
    String? name,
    String? dosage,
    int? hour,
    int? minute,
    List<int>? days,
    String? notes,
    bool? enabled,
    List<String>? takenOn,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      notes: notes ?? this.notes,
      enabled: enabled ?? this.enabled,
      takenOn: takenOn ?? this.takenOn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'hour': hour,
        'minute': minute,
        'days': days,
        'notes': notes,
        'enabled': enabled,
        'takenOn': takenOn,
      };

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    return MedicineReminder(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      dosage: (json['dosage'] ?? '') as String,
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      days: (json['days'] as List).map((e) => (e as num).toInt()).toList(),
      notes: (json['notes'] ?? '') as String,
      enabled: (json['enabled'] ?? true) as bool,
      takenOn: ((json['takenOn'] ?? []) as List).map((e) => e.toString()).toList(),
    );
  }
}
