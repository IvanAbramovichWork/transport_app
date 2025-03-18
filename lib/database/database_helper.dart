import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/transport.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('Инициализация базы данных'); // Отладочное сообщение
    if (!kIsWeb) {
      // Для мобильных и настольных платформ
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } else if (Platform.isAndroid || Platform.isIOS) {
        databaseFactory = databaseFactory;
      }
    } else {
      // Для веб-платформы
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transport_app.db');
    print('Путь к базе данных: $path'); // Отладочное сообщение
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Создаем таблицу transports
    await db.execute('''
    CREATE TABLE transports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      model TEXT NOT NULL,
      licensePlate TEXT NOT NULL UNIQUE,
      availability INTEGER NOT NULL
    )
  ''');

    // Создаем таблицу orders
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      status TEXT NOT NULL,
      userId INTEGER NOT NULL,
      transportId INTEGER NOT NULL,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
  ''');
  }


  Future<int> insertTransport(Transport transport) async {
    final db = await database;
    return await db.insert('transports', transport.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Получение транспорта по id
  Future<Transport?> getTransportById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transport.fromMap(maps.first);
    }
    return null;
  }

  // Получение всех транспортов
  Future<List<Transport>> getAllTransports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transports');
    return maps.map((map) => Transport.fromMap(map)).toList();
  }

  // Обновление транспорта
  Future<int> updateTransport(Transport transport) async {
    final db = await database;
    return await db.update(
      'transports',
      transport.toMap(),
      where: 'id = ?',
      whereArgs: [transport.id],
    );
  }

  // Удаление транспорта
  Future<int> deleteTransport(int id) async {
    final db = await database;
    return await db.delete(
      'transports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
