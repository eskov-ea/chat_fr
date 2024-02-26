import 'package:chat/services/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }


  /// DB INITIALIZE

  Future<Database> initDB() async {
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'pleyona.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await createTables(db);
        },
        onOpen: (db) async {
          final List<Object> rawTables = await db.rawQuery(
              'SELECT * FROM sqlite_master');
          final List<DBTable> existingTables = rawTables.map((el) =>
              DBTable.fromJson(el)).toList();
          tables.forEach((k, sql) async {
            if (!checkIfTableExists(existingTables, k)) {
              await db.execute(sql);
              print("TABLE CREATED ::::::");
            }
          });
        }
    );
  }

  Future<void> createTables(Database db) async {
    try {
      tables.forEach((key, sql) async {
        await db.execute(sql);
      });
    } catch (err) {
      print("ERROR:DBProvider:73:: $err");
    }
  }


  Future<void> DeveloperModeClearPersonTable() async {
    final db = await database;
    // await db.execute("DROP TABLE IF EXISTS person");
    // await db.execute("DROP TABLE IF EXISTS trip");
    // await db.execute("DROP TABLE IF EXISTS person_documents");
    await db.execute("DROP TABLE IF EXISTS seat");
  }


  String dateFormatter(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

}

class DBTable {
  final String name;
  const DBTable({required this.name});
  static DBTable fromJson(json) => DBTable(name: json["name"]);
}


bool checkIfTableExists(List<DBTable> existingTables, String searchingTableName) {
  final res = existingTables.where((el) =>
  el.name == searchingTableName
  );
  return res.isEmpty ?  false : true;
}




