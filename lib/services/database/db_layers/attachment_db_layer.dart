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
            'INSERT OR IGNORE INTO attachments(id, chat_message_id, name, ext, preview, created_at) VALUES(?, ?, ?, ?, ?, ?) ',
            [file.attachmentId, file.chatMessageId, file.name, file.filetype, file.preview, file.createdAt]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }
}