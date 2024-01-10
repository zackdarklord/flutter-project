import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import "dart:developer" as developer;
import '../models/birthday.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'todos';

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('db not null');
      return;
    }
    try {
      String path = '${await getDatabasesPath()}/reminder.db';
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (Database db, int version) async {
          return db.execute(
            'CREATE TABLE $_tableName ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'remind INTEGER, repeat STRING, '
            'color INTEGER, '
            'isCompleted INTEGER)',
          );
        },
      );
      developer.log('DB Created', name: 'DB');
    } catch (e) {
      developer.log(e.toString(), name: 'DB');
    }
  }

  static Future<int> insert(Birthday? bd) async {
    try {
      return await _db!.insert(_tableName, bd!.toJson());
    } catch (e) {
      return 9000;
    }
  }

  static Future<int> delete(Birthday bd) async {
    return await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [bd.id],
    );
  }

  static Future<int> deleteAll() async {
    return await _db!.delete(_tableName);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName);
  }
  Future<bool> _checkContactExists(String firstName, String lastName, String birthday) async {
    // Fetch all contacts from the database
    List<Map<String, dynamic>> contactsFromDb = await DBHelper.query();

    // Check if the contact already exists based on first name, last name, and birthday
    bool contactExists = contactsFromDb.any((dbContact) {
      return dbContact['firstName'] == firstName &&
          dbContact['lastName'] == lastName &&
          dbContact['birthday'] == birthday;
    });

    return contactExists;
  }
  static Future<bool> contactExists(String firstName, String lastName, String birthday) async {
    try {
      int count = Sqflite.firstIntValue(await _db!.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE title = ? AND note = ? AND date = ?',
        [
          '$firstName $lastName',
          "It's $firstName's birthday",
          _formatBirthday(birthday),
        ],
      ))!;
      return count > 0;
    } catch (e) {
      developer.log(e.toString(), name: 'DB');
      return false;
    }
  }

  static String _formatBirthday(String birthday) {
    return birthday;
  }
  static Future<int> update(int id) async {
    return await _db!.rawUpdate('''
    UPDATE $_tableName
    SET isCompleted = ?
    WHERE id = ?
    ''', [1, id]);
  }
}
