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
        batch.execute(''
        'INSERT INTO dialog(id, name, description, chat_type_name, author_id, '
        'last_message_id, is_closed, is_public, message_count, picture, created_at, '
        'updated_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET '
          'name = "${d.name}", '
          'description = "${d.description}", '
          'chat_type_name = "${d.chatType.name}", '
          'author_id = "${d.userData.id}", '
          'last_message_id = "${d.lastMessage.messageId}", '
          'is_closed = 0, '
          'is_public = 0, '
          'message_count = "${d.messageCount}", '
          'picture = "${d.picture}"',
          [d.dialogId, d.name, d.description, d.chatType.name, d.userData.id,
          d.lastMessage.messageId, 0, 1, d.messageCount, d.picture,
          d.createdAt.toString(), d.createdAt.toString()]
        );
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