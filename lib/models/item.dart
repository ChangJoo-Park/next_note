import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tableItem = 'Items';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnNote = 'note';
final String columnDeletedAt = 'deleted_at';
final String columnCreatedAt = 'created_at';
final String columnUpdatedAt = 'updated_at';

class Item {
  int id;
  String title;
  String note;
  String deletedAt;
  String createdAt;
  String updatedAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnNote: note,
      columnDeletedAt: deletedAt,
      columnCreatedAt: createdAt,
      columnUpdatedAt: updatedAt,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Item();

  Item.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    note = map[columnNote];
    deletedAt = map[columnDeletedAt];
    createdAt = map[columnCreatedAt];
    updatedAt = map[columnUpdatedAt];
  }
}

class ItemProvider {
  Database db;

  Future open({String path = 'note_development.db'}) async {
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Items (
            id INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,
            title TEXT,
            note TEXT,
            deleted_at DATETIME,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
          );
          ''');
      },
    );
  }

  Future<void> removeAllItems() async {
    await db.execute('''
  DELETE FROM Items;
  ''');
  }

  Future<List<Item>> getItems({int limit = 1}) async {
    List<Map> maps =
        await db.query(tableItem, orderBy: 'updated_at DESC', limit: limit);
    List<Item> items = maps.map((item) => Item.fromMap(item)).toList();
    return items;
  }

  Future<Item> create(Item item) async {
    item.createdAt = DateTime.now().toIso8601String();
    item.updatedAt = DateTime.now().toIso8601String();
    item.deletedAt = null;
    item.id = await db.insert(tableItem, item.toMap());
    return item;
  }

  Future<int> update(Item item) async {
    item.updatedAt = DateTime.now().toIso8601String();
    return await db.update(tableItem, item.toMap(),
        where: "$columnId = ?", whereArgs: [item.id]);
  }

  Future<int> delete(int id) async {
    return await db.delete(tableItem, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> getItemById(int id) async {
    await db.execute('SELECT * from Items');
    return 1;
  }

  Future close() async => db.close();
}
