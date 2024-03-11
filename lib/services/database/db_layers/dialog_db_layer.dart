import 'dart:developer';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';


void onDBErrorHandler(err, stack) {
  print('DBErrorHandler::   $stack');
}


class DialogDBLayer {

  Future saveDialog(List<DialogData> dialogs) async {
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var d in dialogs) {
        batch.execute(
        'INSERT INTO dialog(id, name, description, chat_type_name, author_id, '
        'last_message_id, is_closed, is_public, message_count, picture, created_at, '
        'updated_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET '
          'name = "${d.name}", '
          'description = "${d.description}", '
          'chat_type_name = "${d.chatType.typeName}", '
          'author_id = "${d.dialogAuthorId}", '
          'last_message_id = "${d.lastMessage?.messageId}", '
          'is_closed = ${d.isClosed}, '
          'is_public = ${d.isPublic}, '
          'message_count = "${d.messageCount}", '
          'picture = "${d.picture}"',
          [d.dialogId, d.name, d.description, d.chatType.typeName, d.dialogAuthorId,
          d.lastMessage?.messageId, 0, 1, d.messageCount, d.picture,
          d.createdAt.toString(), d.createdAt.toString()]
        );
      }
      return await batch.commit(noResult: true);
    } on Exception catch(err, stack) {
      onDBErrorHandler(err, stack);
      rethrow;
    }
  }

  Future<List<DialogData>> getDialogs() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn
          .rawQuery(
            'SELECT d.id, d.name, d.description, d.author_id, '
            '(SELECT id FROM message m WHERE m.chat_id = d.id ORDER BY id DESC LIMIT 1) AS dialog_last_message_id, '
            'd.is_closed, d.is_public, d.message_count, d.picture, d.created_at, d.updated_at, d.last_page, '
            'ct.id chat_type_id, ct.name chat_type_name, ct.description chat_type_description, ct.p2p chat_type_p2p, ct.secure chat_type_secure, ct.readonly chat_type_readonly, ct.picture chat_type_picture, '
            'm.id message_id, m.replied_message_id replied_message_id, m.replied_message_text, m.replied_message_author, m.user_id, m.chat_id, m.message, m.created_at message_created_at, '
            'f.id file_id, f.name file_name, f.ext file_ext, f.preview file_preview, f.path file_path, f.created_at file_created_at, '
            '(SELECT GROUP_CONCAT(user_id) FROM chat_user WHERE chat_id = d.id) as chat_users '
            'FROM dialog d '
            'LEFT JOIN chat_type ct ON (d.chat_type_name = ct.name) '
            'LEFT JOIN message m ON (dialog_last_message_id = m.id) '
            'LEFT JOIN attachments f ON (d.last_message_id = f.chat_message_id) '
            'WHERE d.is_closed = 0 '
            'ORDER BY CASE WHEN m.created_at IS NOT NULL THEN m.created_at ELSE d.created_at END DESC; '
         );
        log('dialogs res::: $res');
        return res.map((el) => DialogData.fromDBJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> updateDialogLastPage(int dialogId, int page) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return txn.rawUpdate(
          'UPDATE dialog SET last_page = "$page" '
          'WHERE id = "$dialogId"; '
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int> updateDialogLastMessage(MessageData message) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return txn.rawUpdate(
          'UPDATE dialog SET last_message_id = "${message.messageId}" '
          'WHERE id = "${message.dialogId}"; '
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int?> getLastDialogPage(int dialogId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        final res = await txn.rawQuery(
          'SELECT last_page FROM dialog '
          'WHERE id = "$dialogId"; '
        );
        return (res.first as Map)["last_page"];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

}