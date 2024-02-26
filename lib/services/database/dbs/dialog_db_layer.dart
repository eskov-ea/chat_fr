import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';



class DialogDBLayer {

  Future<int> saveDialog(DialogData d) async {
    final db = await DBProvider.db.database;
    return await db.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO person(firstname, lastname, middlename, gender, birthdate, phone, email, citizenship, class_person, parent_id, comment, photo, created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          []
      );
      return id;
    });
  }

}