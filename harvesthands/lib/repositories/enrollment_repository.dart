import '../db/database_helper.dart';
import '../models/enrollment.dart';

class EnrollmentException implements Exception {
  final String message;
  const EnrollmentException(this.message);
}

/// Compara solo por día (sin hora), consistente con el feed SQL.
bool _isEventPast(String isoDate) {
  final dt = DateTime.tryParse(isoDate);
  if (dt == null) return true;
  final today = DateTime.now();
  final eventDay = DateTime(dt.year, dt.month, dt.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  return eventDay.isBefore(todayDay);
}

class EnrollmentRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> enroll({
    required int volunteeringId,
    required int volunteerId,
  }) async {
    final db = await _db.database;

    await db.transaction((txn) async {
      // Verificar que no esté ya inscrito
      final existing = await txn.query(
        'enrollments',
        where: 'volunteering_id = ? AND volunteer_id = ?',
        whereArgs: [volunteeringId, volunteerId],
      );
      if (existing.isNotEmpty) {
        throw const EnrollmentException('Ya estás inscrito en este voluntariado');
      }

      // Verificar cupo y fecha dentro de la misma transacción
      final volRows = await txn.rawQuery('''
        SELECT v.max_capacity,
               v.event_date,
               (SELECT COUNT(*) FROM enrollments e WHERE e.volunteering_id = v.id) AS enrolled_count
        FROM volunteerings v
        WHERE v.id = ?
      ''', [volunteeringId]);

      if (volRows.isEmpty) {
        throw const EnrollmentException('El voluntariado no existe');
      }

      final maxCapacity = volRows.first['max_capacity'] as int;
      final enrolledCount = volRows.first['enrolled_count'] as int;
      final eventDate = volRows.first['event_date'] as String;

      if (_isEventPast(eventDate)) {
        throw const EnrollmentException('Este voluntariado ya concluyó');
      }

      if (enrolledCount >= maxCapacity) {
        throw const EnrollmentException('El voluntariado ya no tiene cupo disponible');
      }

      await txn.insert('enrollments', {
        'volunteering_id': volunteeringId,
        'volunteer_id': volunteerId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Inscripciones de un voluntario con datos del voluntariado.
  Future<List<Enrollment>> getByVolunteer(int volunteerId) async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT e.*,
             u.name AS volunteer_name,
             u.email AS volunteer_email,
             u.phone AS volunteer_phone,
             v.title AS volunteering_title
      FROM enrollments e
      JOIN users u ON u.id = e.volunteer_id
      JOIN volunteerings v ON v.id = e.volunteering_id
      WHERE e.volunteer_id = ?
      ORDER BY e.enrolled_at DESC
    ''', [volunteerId]);

    return rows.map(Enrollment.fromMap).toList();
  }

  /// Inscritos de un voluntariado con datos de contacto.
  Future<List<Enrollment>> getByVolunteering(int volunteeringId) async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT e.*,
             u.name AS volunteer_name,
             u.email AS volunteer_email,
             u.phone AS volunteer_phone,
             v.title AS volunteering_title
      FROM enrollments e
      JOIN users u ON u.id = e.volunteer_id
      JOIN volunteerings v ON v.id = e.volunteering_id
      WHERE e.volunteering_id = ?
      ORDER BY e.enrolled_at ASC
    ''', [volunteeringId]);

    return rows.map(Enrollment.fromMap).toList();
  }

  Future<bool> isEnrolled({
    required int volunteeringId,
    required int volunteerId,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'enrollments',
      where: 'volunteering_id = ? AND volunteer_id = ?',
      whereArgs: [volunteeringId, volunteerId],
    );
    return rows.isNotEmpty;
  }

  Future<int> countByVolunteering(int volunteeringId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM enrollments WHERE volunteering_id = ?',
      [volunteeringId],
    );
    return (rows.first['cnt'] as int?) ?? 0;
  }
}
