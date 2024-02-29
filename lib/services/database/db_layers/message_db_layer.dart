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
            'INSERT OR IGNORE INTO message(id, chat_id, user_id, message, created_at, '
            'updated_at, replied_message_id, replied_message_author, replied_message_text) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?) ',
            [message.messageId, message.dialogId, message.senderId, message.message, message.rawDate.toString(),
            message.rawDate.toString(), message.repliedMessage?.parentMessageId, message.repliedMessage?.senderId, message.repliedMessage?.parentMessageText]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error batch: $lastObject \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<Map<int, MessageData>> getMessages() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT m.id message_id, m.chat_id, m.user_id, m.message, m.created_at message_created_at, m.updated_at, '
            'm.replied_message_id, m.replied_message_author, m.replied_message_text, '
            's.id message_status_id, s.user_id message_status_user_id, '
            's.chat_message_id, s.chat_message_status_id, s.created_at message_status_created_at, s.updated_at message_status_updated_at, '
            'f.id file_id, f.name file_name, f.preview file_preview, f.path file_path, f.ext file_ext, f.created_at file_created_at '
            'FROM message m '
            ''
            'LEFT JOIN message_status s ON (m.id = s.chat_message_id) '
            'LEFT JOIN attachments f ON (m.id = f.chat_message_id); '
        );
        Map<int, MessageData> messages = {};
        for (var messageObj  in res) {
          messageObj as Map;
          final id = messageObj["message_id"];
          if (messages.containsKey(id)) {
            final status = MessageStatus.fromDBJson(messageObj);
            messages[id]!.statuses.add(status);
          } else {
            final message = MessageData.fromDBJson(messageObj);
            final status = MessageStatus.fromDBJson(messageObj);
            message.statuses.add(status);
            messages.addAll({message.messageId: message});
          }
        }
        return messages;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}