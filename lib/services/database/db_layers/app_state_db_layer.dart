import 'dart:developer';
import 'package:chat/models/contact_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';


class AppStateDBLayer {



  Future<Map<int, UserModel>> getUsers() async {
    try {
      final db = await DBProvider.db.database;
      final users = <int, UserModel>{};
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT id user_id, firstname, lastname, middlename, company, dept, position, '
                'phone, email, birthdate, avatar, banned, last_access '
                'FROM user '
                'ORDER BY user.lastname; '
        );
        res as List<Map>;
        for (var user in res) {
          users.addAll({user['user_id']: UserModel.fromJsonDB(user)});
        }
        return users;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}