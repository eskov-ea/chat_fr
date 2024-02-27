import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBDeveloperService {

  Future<List<Object>> checkExistingTables() async {
    final db = await DBProvider.db.database;
    return await db.rawQuery(
        'SELECT * FROM sqlite_master');
  }

  Future deleteDBFile() async {
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mcfef.db');
    await databaseFactory.deleteDatabase(path);
    print('DB deleted');
  }

}