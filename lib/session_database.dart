import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SessionDatabase {
  // Singleton database instance
  static final SessionDatabase instance = SessionDatabase._init();

  static Database? _database;

  SessionDatabase._init();

  // Open database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('studytrack.db');
    return _database!;
  }

  // Create database
  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create study_sessions table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        duration INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Insert a new study session
  Future<int> insertSession(Map<String, dynamic> session) async {
    final db = await instance.database;

    return await db.insert(
      'study_sessions',
      session,
    );
  }

  // Retrieve study sessions with pagination
  Future<List<Map<String, dynamic>>> getSessions({
    required int limit,
    required int offset,
  }) async {
    final db = await instance.database;

    return await db.query(
      'study_sessions',
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
      offset: offset,
    );
  }

  // Count total study sessions
  Future<int> getSessionCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM study_sessions'
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Update an existing study session
  Future<int> updateSession(
    int id,
    Map<String, dynamic> session,
  ) async {
    final db = await instance.database;

    return await db.update(
      'study_sessions',
      session,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a study session
  Future<int> deleteSession(int id) async {
    final db = await instance.database;

    return await db.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
