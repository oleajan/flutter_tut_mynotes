// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_tut_mynotes/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:path/path.dart' show join;

// import 'crud_exceptions.dart';

// class NotesService {
//   Database? _database;

//   // our source of truth
//   List<DatabaseNote> _notes = [];

//   DatabaseUser? _user;

//   // hacky way to to singletons
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _shared;  

//   // controls the _notes
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   // Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

//   Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note) {
//     final currentUser = _user;

//     if (currentUser != null) {
//       return note.userId == currentUser.id;
//     } else {
//       throw UserShouldBeSetBeforeReadingAllNotes();
//     }
//   });

//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote ({required DatabaseNote note, required String text}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     await getNote(id: note.id);

//     final updatesCount = await database.update(
//       noteTable, 
//       {
//         textColumn: text,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0) throw CouldNotUpdateNote;
 
//    final newNote = await getNote(id: note.id);
//    _notes.removeWhere((element) => element.id == newNote.id);
//    _notes.add(newNote);
//    _notesStreamController.add(_notes);

//    return newNote;
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();
//     final notes = await database.query(noteTable);
//     return notes.map((e) => DatabaseNote.fromRow(e));
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final notes = await database.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) throw CouldNotFindNote;

//     final note = DatabaseNote.fromRow(notes.first);
//     _notes.removeWhere((element) => element.id == id);
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();
//     final deleteCount =  await database.delete(noteTable);

//     _notes = [];
//     _notesStreamController.add(_notes);

//     return deleteCount;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final deletedCount = await database.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (deletedCount == 0) throw CouldNotDeleteNote;    

//     _notes.removeWhere((note) => note.id == id);
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) throw CouldNotFindUser();

//     const text = '';
//     final noteId = await database
//         .insert(noteTable, {userIdColumn: owner.id, textColumn: text});

//     final note = DatabaseNote(id: noteId, userId: owner.id, text: text);

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final result = await database.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (result.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(result.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final results = await database.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isNotEmpty) throw UserAlreadyExists();

//     final userId = await database.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final database = _getDatabaseOrThrow();

//     final deletedCount = await database.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (deletedCount != 1) throw CouldNotDeleteUser();
//   }

//   Database _getDatabaseOrThrow() {
//     final database = _database;

//     if (database == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return database;
//     }
//   }

//   Future<void> close() async {
//     final database = _database;

//     if (database == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       await database.close();
//       _database = null;
//     }
//   }

//   Future<void> open() async {
//     if (_database != null) {
//       // throw DatabaseAlreadyOpenException();
//       return;
//     }

//     String dbPath = "";
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       dbPath = join(docsPath.path, dbName);
//       final database = await openDatabase(dbPath);
//       _database = database;

//       const createUserTable = '''
//         CREATE TABLE IF NOT EXISTS user (
//             id    INTEGER PRIMARY KEY ASC AUTOINCREMENT
//                           UNIQUE
//                           NOT NULL,
//             email TEXT    UNIQUE
//                           NOT NULL
//         );
//       ''';
//       await database.execute(createUserTable);

//       const createNoteTable = ''' 
//         CREATE TABLE IF NOT EXISTS note (
//         id      INTEGER PRIMARY KEY ASC AUTOINCREMENT
//                     NOT NULL
//                     UNIQUE,
//         user_id INTEGER REFERENCES user (id),
//         text    TEXT
//       );
//       ''';
//       await database.execute(createNoteTable);

//       await _cacheNotes();

//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // empty
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, Id = $id, Email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// // @immutable
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String;

//   @override
//   String toString() => 'Note, Id=$id, userId = $userId';

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'testing.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
