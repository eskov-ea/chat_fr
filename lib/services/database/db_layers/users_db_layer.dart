import 'dart:developer';
import 'package:chat/models/contact_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';


class UsersDBLayer {

  Future saveUsers(List<UserModel> users) async {
    final db = await DBProvider.db.database;
    final Batch batch = db.batch();
    for (var user in users) {
      batch.insert('user', {
        "id": user.id,
        "firstname": user.firstname,
        "lastname": user.lastname,
        "middlename": user.middlename,
        "company": user.company,
        "dept": user.dept,
        "position": user.position,
        "phone": user.phone,
        "email": user.email,
        "birthdate": user.birthdate,
        "avatar": user.avatar,
        "banned": user.banned,
        "last_access": user.lastAccess
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<UserModel>> readUsers() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('SELECT * FROM user ');
        print(res);
        return res.map((el) => UserModel.fromJsonDB(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}