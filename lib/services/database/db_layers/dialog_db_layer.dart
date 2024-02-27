import 'dart:developer';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';


void onDBErrorHandler(err, stack) {
  print('DBErrorHandler::   $stack');
}


class DialogDBLayer {

  Future<void> saveDialog(List<DialogData> dialogs) async {
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var d in dialogs) {
        batch.insert('dialog', {
          "id": d.dialogId, //id
          "name": d.name, //name
          "description": d.description, //description
          "chat_type_name": d.chatType.name, //chat_type
          "author_id": d.userData.id, //user_id
          "last_message_id": d.lastMessage.messageId, //message
          "is_closed": 0, //d.isClosed,
          "is_public": 1, //d.isPublic,
          "message_count": d.messageCount,
          "picture": d.picture,
          "created_at": d.createdAt.toString(),
          "updated_at": d.createdAt.toString()
        });
      }
      await batch.commit(noResult: true);
    } on Exception catch(err, stack) {
      onDBErrorHandler(err, stack);
      rethrow;
    }
  }

  Future<List<DialogData>> readDialogs() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn
          .rawQuery(
            'SELECT d.id, d.name, d.description, d.author_id, d.last_message_id, d.is_closed, d.is_public, d.message_count, d.picture, d.created_at, d.updated_at, '
            'ct.name chat_type_name, ct.description chat_type_description, ct.p2p chat_type_p2p, ct.secure chat_type_secure, ct.readonly chat_type_readonly, ct.picture chat_type_picture, '
            '(SELECT GROUP_CONCAT(user_id) FROM chat_user WHERE chat_id = d.id) as users '
            'FROM dialog d '
            'LEFT JOIN chat_type ct ON (d.chat_type_name = ct.name) '
            'LEFT JOIN chat_user cu ON (d.id = cu.chat_id) '
            'WHERE d.is_closed = 0; '

        // 'SELECT d.id, (SELECT GROUP_CONCAT(user_id) from chat_user Where chat_id = d.id) as users FROM dialog d '
         );
        print(res);
        return res.map((el) => DialogData.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

}