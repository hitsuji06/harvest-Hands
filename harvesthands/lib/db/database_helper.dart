import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWebNoWebWorker;
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class DatabaseHelper {
  static const _dbName = 'harvesthands.db';
  static const _dbVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
      return openDatabase(
        _dbName,
        version: _dbVersion,
        onCreate: _onCreate,
      );
    }

    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL CHECK (role IN ('volunteer', 'company')),
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE volunteerings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT,
        event_date TEXT NOT NULL,
        max_capacity INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (company_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        volunteering_id INTEGER NOT NULL,
        volunteer_id INTEGER NOT NULL,
        enrolled_at TEXT NOT NULL,
        UNIQUE(volunteering_id, volunteer_id),
        FOREIGN KEY (volunteering_id) REFERENCES volunteerings(id) ON DELETE CASCADE,
        FOREIGN KEY (volunteer_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();

    final empresa1Salt = _generateSalt();
    final empresa2Salt = _generateSalt();
    final vol1Salt = _generateSalt();
    final vol2Salt = _generateSalt();

    await db.insert('users', {
      'role': 'company',
      'name': 'Verde Esperanza A.C.',
      'email': 'empresa1@demo.com',
      'phone': '6271234567',
      'password_hash': _hashPassword('demo1234', empresa1Salt),
      'salt': empresa1Salt,
      'description': 'Organización dedicada a la reforestación y cuidado del medio ambiente en la región de Chihuahua.',
      'created_at': now.toIso8601String(),
    });

    await db.insert('users', {
      'role': 'company',
      'name': 'Manos Solidarias',
      'email': 'empresa2@demo.com',
      'phone': '6277654321',
      'password_hash': _hashPassword('demo1234', empresa2Salt),
      'salt': empresa2Salt,
      'description': 'Colectivo comunitario que organiza brigadas de apoyo a comunidades rurales de Parral.',
      'created_at': now.toIso8601String(),
    });

    await db.insert('users', {
      'role': 'volunteer',
      'name': 'Ana García López',
      'email': 'vol1@demo.com',
      'phone': '6271112222',
      'password_hash': _hashPassword('demo1234', vol1Salt),
      'salt': vol1Salt,
      'description': null,
      'created_at': now.toIso8601String(),
    });

    await db.insert('users', {
      'role': 'volunteer',
      'name': 'Carlos Mendoza Ríos',
      'email': 'vol2@demo.com',
      'phone': '6273334444',
      'password_hash': _hashPassword('demo1234', vol2Salt),
      'salt': vol2Salt,
      'description': null,
      'created_at': now.toIso8601String(),
    });

    // IDs esperados: empresa1=1, empresa2=2, vol1=3, vol2=4
    final futuro1 = now.add(const Duration(days: 15));
    final futuro2 = now.add(const Duration(days: 30));
    final futuro3 = now.add(const Duration(days: 45));
    final futuro4 = now.add(const Duration(days: 10));

    await db.insert('volunteerings', {
      'company_id': 1,
      'title': 'Reforestación Sierra Parral',
      'description': 'Únete a nuestra jornada de reforestación en las laderas de la sierra. Plantaremos más de 200 árboles nativos de la región. Incluye transporte desde el centro de la ciudad, herramientas y refrigerio.',
      'image_path': null,
      'event_date': futuro1.toIso8601String(),
      'max_capacity': 30,
      'created_at': now.toIso8601String(),
    });

    await db.insert('volunteerings', {
      'company_id': 1,
      'title': 'Limpieza Río Parral',
      'description': 'Brigada de limpieza a lo largo del río. Recolectaremos basura y separación de residuos. Actividad apta para todas las edades. Trae ropa que puedas ensuciar y botas si tienes.',
      'image_path': null,
      'event_date': futuro2.toIso8601String(),
      'max_capacity': 2, // casi lleno para demostración
      'created_at': now.toIso8601String(),
    });

    await db.insert('volunteerings', {
      'company_id': 2,
      'title': 'Apoyo en Banco de Alimentos',
      'description': 'Necesitamos voluntarios para clasificar y empacar alimentos donados en nuestro banco comunitario. El trabajo se realiza en bodega cubierta. Turnos de 4 horas disponibles.',
      'image_path': null,
      'event_date': futuro3.toIso8601String(),
      'max_capacity': 20,
      'created_at': now.toIso8601String(),
    });

    await db.insert('volunteerings', {
      'company_id': 2,
      'title': 'Taller de Lectura Infantil',
      'description': 'Voluntarios para facilitar talleres de lectura y escritura con niños de comunidades rurales. Se requiere paciencia y gusto por trabajar con niños. Material didáctico incluido.',
      'image_path': null,
      'event_date': futuro4.toIso8601String(),
      'max_capacity': 10,
      'created_at': now.toIso8601String(),
    });

    // Inscripciones cruzadas demo
    // vol1 (id=3) en voluntariado 1 y 4
    // vol2 (id=4) en voluntariado 2 (casi lleno) y 3
    await db.insert('enrollments', {
      'volunteering_id': 1,
      'volunteer_id': 3,
      'enrolled_at': now.toIso8601String(),
    });

    await db.insert('enrollments', {
      'volunteering_id': 4,
      'volunteer_id': 3,
      'enrolled_at': now.toIso8601String(),
    });

    await db.insert('enrollments', {
      'volunteering_id': 2,
      'volunteer_id': 4,
      'enrolled_at': now.toIso8601String(),
    });

    await db.insert('enrollments', {
      'volunteering_id': 3,
      'volunteer_id': 4,
      'enrolled_at': now.toIso8601String(),
    });
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  static String generateSalt() => _generateSalt();
  static String hashPassword(String password, String salt) => _hashPassword(password, salt);
}
