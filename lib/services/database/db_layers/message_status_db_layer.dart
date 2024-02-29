import 'dart:developer';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';


class MessageStatusDBLayer {

  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses) async {
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var status in statuses) {
        batch.execute(
            'INSERT OR IGNORE INTO message_status(id, chat_id, user_id, chat_message_id, chat_message_status_id, '
            'created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?) ',
            [status.id, status.dialogId, status.userId, status.messageId,
            status.statusId, status.createdAt, status.createdAt]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<List<MessageStatus>> getMessageStatuses() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT id, chat_id, user_id, chat_message_id, chat_message_status_id, created_at, updated_at '
            'FROM message_status; '
        );
        return res.map((el) => MessageStatus.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}