import 'dart:developer' as devtools;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class NotesService {
  Database? _database;

  Future<DatabaseUser> getUser({required String email}) async {
    final database = _getDatabaseOrThrow();

    final result = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final database = _getDatabaseOrThrow();

    final results = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) throw UserAlreadyExists();

    final userId = await database.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final database = _getDatabaseOrThrow();

    final deletedCount = await database.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) throw CouldNotDeleteUser();
  }

  Database _getDatabaseOrThrow() {
    final database = _database;

    if (database == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return database;
    }
  }

  Future<void> close() async {
    final database = _database;

    if (database == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await database.close();
      _database = null;
    }
  }

  Future<void> open() async {
    if (_database != null) throw DatabaseAlreadyOpenException();

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final database = await openDatabase(dbPath);
      _database = database;

      const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id" INTEGER NOT NULL,
          "email" TEXT NOT NULL UNIQUE,
          PRIMARY KEY ("id" AUTOINCREMENT)
        );
      ''';
      await database.execute(createUserTable);

      const createNoteTable = ''' 
        CREATE TABLE IF NOT EXISTS "note" (
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "text" TEXT,
          FOREIGN KEY("user_id") REFERENCES "user("id"),
          PRIMARY KEY ("id" AUTOINCREMENT)
        );
      ''';
      await database.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    } catch (e) {
      devtools.log(e.toString());
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, Id = $id, Email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// @immutable
class DatabaseNotes {
  final int id;
  final int userId;
  final String text;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String;

  @override
  String toString() => 'Note, Id=$id, userId = $userId';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'testing.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
