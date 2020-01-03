import 'package:sqflite/sqflite.dart';
import 'package:dotenv/dotenv.dart' show env;

enum Environment { TEST, DEVELOPMENT, PRODUCTION }

Future<Database> database() {
  return openDatabase(
    'note_development.db',
    version: 1,
    singleInstance: true,
    onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE Items (
            id INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,
            title TEXT,
            note TEXT,
            deleted_at DATETIME
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
          );
          ''');
    },
  );
}

Future<void> removeAllItems() async {
  Database db = await database();
  await db.execute('''
  DELETE FROM Items;
  ''');
}

Future<List<Map>> getItems() async {
  Database db = await database();
  List<Map> maps = await db.query('Items');
  return maps;
}

Future<int> getItemById(int id) async {
  Database db = await database();
  await db.execute('SELECT * from Items');
  return 1;
}
