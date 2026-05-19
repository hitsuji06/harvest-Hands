import '../db/database_helper.dart';
import '../models/volunteering.dart';

class VolunteeringRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Feed visible para voluntarios: fecha futura y cupo disponible.
  Future<List<Volunteering>> getFeed() async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT v.*,
             u.name AS company_name,
             (SELECT COUNT(*) FROM enrollments e WHERE e.volunteering_id = v.id) AS enrolled_count
      FROM volunteerings v
      JOIN users u ON u.id = v.company_id
      WHERE date(v.event_date) >= date('now')
        AND (SELECT COUNT(*) FROM enrollments e WHERE e.volunteering_id = v.id) < v.max_capacity
      ORDER BY v.event_date ASC
    ''');

    return rows.map(Volunteering.fromMap).toList();
  }

  /// Todos los voluntariados de una empresa (incluyendo cerrados/pasados).
  Future<List<Volunteering>> getByCompany(int companyId) async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT v.*,
             u.name AS company_name,
             (SELECT COUNT(*) FROM enrollments e WHERE e.volunteering_id = v.id) AS enrolled_count
      FROM volunteerings v
      JOIN users u ON u.id = v.company_id
      WHERE v.company_id = ?
      ORDER BY v.event_date DESC
    ''', [companyId]);

    return rows.map(Volunteering.fromMap).toList();
  }

  Future<Volunteering?> getById(int id) async {
    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT v.*,
             u.name AS company_name,
             (SELECT COUNT(*) FROM enrollments e WHERE e.volunteering_id = v.id) AS enrolled_count
      FROM volunteerings v
      JOIN users u ON u.id = v.company_id
      WHERE v.id = ?
    ''', [id]);

    if (rows.isEmpty) return null;
    return Volunteering.fromMap(rows.first);
  }

  Future<int> create({
    required int companyId,
    required String title,
    required String description,
    String? imagePath,
    required DateTime eventDate,
    required int maxCapacity,
  }) async {
    final db = await _db.database;

    return db.insert('volunteerings', {
      'company_id': companyId,
      'title': title.trim(),
      'description': description.trim(),
      'image_path': imagePath,
      'event_date': eventDate.toIso8601String(),
      'max_capacity': maxCapacity,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('volunteerings', where: 'id = ?', whereArgs: [id]);
  }
}
