class Enrollment {
  final int? id;
  final int volunteeringId;
  final int volunteerId;
  final String enrolledAt;

  // Campos calculados (joins)
  final String? volunteerName;
  final String? volunteerEmail;
  final String? volunteerPhone;
  final String? volunteeringTitle;

  const Enrollment({
    this.id,
    required this.volunteeringId,
    required this.volunteerId,
    required this.enrolledAt,
    this.volunteerName,
    this.volunteerEmail,
    this.volunteerPhone,
    this.volunteeringTitle,
  });

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'] as int?,
      volunteeringId: map['volunteering_id'] as int,
      volunteerId: map['volunteer_id'] as int,
      enrolledAt: map['enrolled_at'] as String,
      volunteerName: map['volunteer_name'] as String?,
      volunteerEmail: map['volunteer_email'] as String?,
      volunteerPhone: map['volunteer_phone'] as String?,
      volunteeringTitle: map['volunteering_title'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'volunteering_id': volunteeringId,
      'volunteer_id': volunteerId,
      'enrolled_at': enrolledAt,
    };
  }
}
