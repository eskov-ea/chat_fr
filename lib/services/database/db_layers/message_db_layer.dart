import 'dart:developer';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';


class MessageDBLayer {

  Future<List<Object?>> saveMessages(List<MessageData> messages) async {
      String? lastObject;
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var message in messages) {
        lastObject = message.toString();
        batch.execute(
            'INSERT OR IGNORE INTO message(id, chat_id, user_id, parent_id, message, file, created_at, '
            'updated_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?) ',
            [message.messageId, message.dialogId, message.senderId, message.parentMessageId,
              message.message, message.file?.attachmentId, message.rawDate.toString(), message.rawDate.toString()]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error batch: $lastObject \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<List<MessageData>> getMessages() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT m.id, m.chat_id, m.user_id, m.parent_id, m.message, m.file, m.created_at, m.updated_at, '
            's.id message_status_id, s.user_id message_status_user_id, '
            's.chat_message_id, s.chat_message_status_id '
            'FROM message m '
            ''
            'LEFT JOIN message_status s ON (m.id = s.chat_message_id) '
        );
        log('Messages from db::: $res');
        Map<int, String> messages = {};
        for (var messageObj  in res) {
          messageObj as Map;
          final id = messageObj["id"];
          if (messages.containsKey(id)) {
            final status = "{id: ${messageObj["message_status_id"]}, "
                "user_id: ${messageObj["message_status_user_id"]}, chat_id: ${messageObj["chat_id"]}, "
                "chat_message_status_id: ${messageObj["chat_message_status_id"]}}";
            print('EXISITING status::');
          } else {
            final messageWithStatus = "{"
                "id: $id, chat_id: ${messageObj["chat_id"]}, user_id: ${messageObj["user_id"]}, parent_id: ${messageObj["parent_id"]}, "
                "message: ${messageObj["message"]}, file: ${messageObj["file"]}, created_at: ${messageObj["created_at"]}, "
                "updated_at: ${messageObj["updated_at"]}, "
                "statuses: [{id: ${messageObj["message_status_id"]}, "
                "user_id: ${messageObj["message_status_user_id"]}, chat_id: ${messageObj["chat_id"]}, "
                "chat_message_status_id: ${messageObj["chat_message_status_id"]}}]"
            "}";
          }
          print('::://:::  ${messageObj["id"]}');
        }
        // return res.map((el) => MessageData.fromJson(el)).toList();
        return [];
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}