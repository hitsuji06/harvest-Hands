class Volunteering {
  final int? id;
  final int companyId;
  final String title;
  final String description;
  final String? imagePath;
  final String eventDate; // ISO 8601
  final int maxCapacity;
  final String createdAt;

  // Campos calculados (no almacenados en DB)
  final String? companyName;
  final int enrolledCount;

  const Volunteering({
    this.id,
    required this.companyId,
    required this.title,
    required this.description,
    this.imagePath,
    required this.eventDate,
    required this.maxCapacity,
    required this.createdAt,
    this.companyName,
    this.enrolledCount = 0,
  });

  bool get isFull => enrolledCount >= maxCapacity;

  /// Verdadero si la fecha del evento es anterior al día de hoy (solo por día, sin hora).
  bool get isPast {
    final dt = DateTime.tryParse(eventDate);
    if (dt == null) return false;
    final today = DateTime.now();
    final eventDay = DateTime(dt.year, dt.month, dt.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return eventDay.isBefore(todayDay);
  }

  bool get isVisible => !isFull && !isPast;

  factory Volunteering.fromMap(Map<String, dynamic> map) {
    return Volunteering(
      id: map['id'] as int?,
      companyId: map['company_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String?,
      eventDate: map['event_date'] as String,
      maxCapacity: map['max_capacity'] as int,
      createdAt: map['created_at'] as String,
      companyName: map['company_name'] as String?,
      enrolledCount: (map['enrolled_count'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'image_path': imagePath,
      'event_date': eventDate,
      'max_capacity': maxCapacity,
      'created_at': createdAt,
    };
  }

  Volunteering copyWith({
    int? id,
    int? companyId,
    String? title,
    String? description,
    String? imagePath,
    String? eventDate,
    int? maxCapacity,
    String? createdAt,
    String? companyName,
    int? enrolledCount,
  }) {
    return Volunteering(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      eventDate: eventDate ?? this.eventDate,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      enrolledCount: enrolledCount ?? this.enrolledCount,
    );
  }
}
