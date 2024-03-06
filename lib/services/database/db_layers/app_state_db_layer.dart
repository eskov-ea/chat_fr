import 'dart:developer';
import 'package:chat/services/database/db_provider.dart';


class AppStateDBLayer {
  Future<String> getLastUpdateTime() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT last_update FROM app_settings;'
        );
        return res.first.toString();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> setLastUpdateTime() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE app_settings SET last_update = "${DateTime.now()}" ;'
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}