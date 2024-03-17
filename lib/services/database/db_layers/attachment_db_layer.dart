import 'dart:developer';

import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';

class AttachmentDBLayer {
  Future saveAttachment(List<MessageAttachmentData> files) async {
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var file in files) {
        batch.execute(
            'INSERT OR IGNORE INTO attachments(id, chat_message_id, name, ext, preview, created_at, path) VALUES(?, ?, ?, ?, ?, ?, ?) ',
            [file.attachmentId, file.chatMessageId, file.name, file.filetype, file.preview, file.createdAt, file.path]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<List<MessageAttachmentData>> getAttachments() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT * FROM attachments ORDER BY id DESC LIMIT 5 ; '
        );
        return res.map((json) => MessageAttachmentData.fromJson(json)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<int> updateFilePath(int id, String path) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE attachments SET path = "$path" '
            'WHERE id = "$id"; '
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<MessageAttachmentData> getAttachmentById(int id) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT * FROM attachments WHERE id = "$id"; '
        );
        return MessageAttachmentData.fromJson(res.first);
      });
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }
}