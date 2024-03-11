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
        return (res.first as Map)["last_update"];
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

  Future<String?> getToken() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT auth_token FROM app_settings;'
        );
        print('getToken:: $res');
        if (res.isEmpty) return null;
        return (res.first as Map)["auth_token"];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> setToken(String token) async {
    try {
      final db = await DBProvider.db.database;
      print('set token:::  $token');
      return await db.transaction((txn) async {
        return await txn.rawInsert(
          'INSERT INTO app_settings(id, auth_token) VALUES(?, ?) '
          'ON CONFLICT(id) DO UPDATE SET auth_token = "$token"; ',
          [1, token]
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int?> getUserId() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT user_id FROM app_settings;'
        );
        print('get userid:::  $res');
        if (res.isEmpty) return null;
        return (res.first as Map)["user_id"];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> setUserId(int userId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawInsert(
            'UPDATE app_settings SET user_id = "$userId" WHERE id = 1; '
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> setDeviceId(String deviceId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawInsert(
            'UPDATE app_settings SET device_id = "$deviceId" WHERE id = 1; '
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error: $err\r\n  $stackTrace');
      rethrow;
    }
  }

  Future<String> getDeviceId() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT device_id FROM app_settings;'
        );
        return (res.first as Map)["device_id"];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<String> getSipContacts() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT sip_contacts FROM app_settings;'
        );
        return (res.first as Map)["sip_contacts"];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> setSipContacts(String contacts) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO app_settings(sip_contacts) VALUES(?) '
                'ON CONFLICT DO UPDATE SET sip_contacts = "$contacts"; ',
            [contacts]
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}