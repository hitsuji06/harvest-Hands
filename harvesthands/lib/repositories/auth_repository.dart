import '../db/database_helper.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class AuthRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<User> register({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? description,
  }) async {
    final db = await _db.database;

    final normalizedEmail = email.toLowerCase().trim();

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      throw const AuthException('Este correo ya está registrado');
    }

    final salt = DatabaseHelper.generateSalt();
    final hash = DatabaseHelper.hashPassword(password, salt);
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('users', {
      'role': role,
      'name': name.trim(),
      'email': normalizedEmail,
      'phone': phone.trim(),
      'password_hash': hash,
      'salt': salt,
      'description': description?.trim(),
      'created_at': now,
    });

    return User(
      id: id,
      role: role,
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      passwordHash: hash,
      salt: salt,
      description: description?.trim(),
      createdAt: now,
    );
  }

  Future<User> login({required String email, required String password}) async {
    final db = await _db.database;

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (rows.isEmpty) {
      throw const AuthException('Correo o contraseña incorrectos');
    }

    final userData = rows.first;
    final salt = userData['salt'] as String;
    final storedHash = userData['password_hash'] as String;
    final inputHash = DatabaseHelper.hashPassword(password, salt);

    if (inputHash != storedHash) {
      throw const AuthException('Correo o contraseña incorrectos');
    }

    return User.fromMap(userData);
  }

  Future<void> saveSession(int userId) async {
    final db = await _db.database;
    await db.delete('session');
    await db.insert('session', {'id': 1, 'user_id': userId});
  }

  Future<User?> getSessionUser() async {
    final db = await _db.database;

    final sessionRows = await db.query('session', where: 'id = 1');
    if (sessionRows.isEmpty) return null;

    final userId = sessionRows.first['user_id'] as int;

    final userRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (userRows.isEmpty) {
      // Sesión huérfana: limpiar
      await db.delete('session');
      return null;
    }

    return User.fromMap(userRows.first);
  }

  Future<void> logout() async {
    final db = await _db.database;
    await db.delete('session');
  }

  Future<bool> isEmailTaken(String email) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    return rows.isNotEmpty;
  }
}
