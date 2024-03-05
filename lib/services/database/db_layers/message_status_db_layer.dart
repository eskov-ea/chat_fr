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
            'INSERT INTO message_status(id, chat_id, user_id, chat_message_id, chat_message_status_id, '
            'created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?) '
            'ON CONFLICT(id) DO UPDATE SET '
            'chat_message_status_id = "${status.statusId}", '
            'created_at = "${status.createdAt}", '
            'updated_at = "${status.updatedAt}" ',
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

  Future<int> saveMessageStatus(MessageStatus status) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO message_status(id, chat_id, user_id, chat_message_id, chat_message_status_id, '
            'created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?) '
            'ON CONFLICT(id) DO UPDATE SET '
            'chat_message_status_id = "${status.statusId}", '
            'created_at = "${status.createdAt}", '
            'updated_at = "${status.updatedAt}" ',
            [status.id, status.dialogId, status.userId, status.messageId,
              status.statusId, status.createdAt, status.createdAt]
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
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

  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT id, chat_id, user_id, chat_message_id, chat_message_status_id, created_at, updated_at '
                'FROM message_status WHERE chat_message_id = "$id"; '
        );
        return res.map((el) => MessageStatus.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<int?> saveLocalMessageStatus(MessageStatus? status) async {
    if ( status == null) return null;
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT OR IGNORE INTO message_status(id, chat_id, user_id, chat_message_id, chat_message_status_id, '
                'created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?, ?) ',
            [status.id, status.dialogId, status.userId, status.messageId,
              status.statusId, status.createdAt, status.createdAt]
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }
}