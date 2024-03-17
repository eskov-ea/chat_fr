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
            'INSERT INTO message(id, chat_id, user_id, message, created_at, '
            'updated_at, replied_message_id, replied_message_author, replied_message_text) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?) '
            'ON CONFLICT(id) DO NOTHING; ',
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
            'm.replied_message_id, m.replied_message_author, m.replied_message_text, m.send_failed, '
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
            if (status != null) messages[id]!.statuses.add(status);
          } else {
            final message = MessageData.fromDBJson(messageObj);
            final status = MessageStatus.fromDBJson(messageObj);
            if (status != null) message.statuses.add(status);
            messages.addAll({message.messageId: message});
          }
        }
        log('statusese db::: ${messages[6035]}');
        return messages;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<List<MessageData>> getMessagesByDialog(int dialogId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT m.id message_id, m.chat_id, m.user_id, m.message, m.created_at message_created_at, m.updated_at, '
                'm.replied_message_id, m.replied_message_author, m.replied_message_text, '
                's.id message_status_id, s.user_id message_status_user_id, m.send_failed, '
                's.chat_message_id, s.chat_message_status_id, s.created_at message_status_created_at, s.updated_at message_status_updated_at, '
                'f.id file_id, f.name file_name, f.preview file_preview, f.path file_path, f.ext file_ext, f.created_at file_created_at '
                'FROM message m '
                ''
                'LEFT JOIN message_status s ON (m.id = s.chat_message_id) '
                'LEFT JOIN attachments f ON (m.id = f.chat_message_id) '
                'WHERE m.chat_id = "$dialogId" '
                'ORDER BY m.id DESC; '
        );
        final messages = <MessageData>[];
        for (var messageObj  in res) {
          messageObj as Map;
          if (messages.isNotEmpty && messages.last.messageId == messageObj["message_id"]) {
            final status = MessageStatus.fromDBJson(messageObj);
            if (status != null) messages.last.statuses.add(status);
          } else {
            final message = MessageData.fromDBJson(messageObj);
            final status = MessageStatus.fromDBJson(messageObj);
            if (status != null) message.statuses.add(status);
            messages.add(message);
          }
        }
        return messages;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<MessageData?> getMessageById(int messageId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT m.id message_id, m.chat_id, m.user_id, m.message, m.created_at message_created_at, m.updated_at, '
                'm.replied_message_id, m.replied_message_author, m.replied_message_text, '
                's.id message_status_id, s.user_id message_status_user_id, m.send_failed, '
                's.chat_message_id, s.chat_message_status_id, s.created_at message_status_created_at, s.updated_at message_status_updated_at, '
                'f.id file_id, f.name file_name, f.preview file_preview, f.path file_path, f.ext file_ext, f.created_at file_created_at '
                'FROM message m '
                ''
                'LEFT JOIN message_status s ON (m.id = s.chat_message_id) '
                'LEFT JOIN attachments f ON (m.id = f.chat_message_id) '
                'WHERE m.id = "$messageId" '
                'ORDER BY m.id DESC; '
        );
        log('jkhjk:::::  $res');
        MessageData? message;
        for (var messageObj  in res) {
          messageObj as Map;
          if (message != null) {
            final status = MessageStatus.fromDBJson(messageObj);
            if (status != null) message.statuses.add(status);
          } else {
            message = MessageData.fromDBJson(messageObj);
            final status = MessageStatus.fromDBJson(messageObj);
            if (status != null) message.statuses.add(status);
          }
        }
        return message;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<String> getMessageInfo() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT * FROM message WHERE id = 6035; '
        );
        print('Message read::: $res');
        return "";
      });
    } catch (err, stackTrace) {
      log('DB operation error batch: \r\n  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<int> saveLocalMessage(MessageData message) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        if (message.file != null) {
          await txn.rawInsert(
            'INSERT INTO attachments(id, chat_message_id, name, ext, preview, path) VALUES(?, ?, ?, ?, ?, ?) ',
            [message.file!.attachmentId, message.file!.chatMessageId, message.file!.name,
              message.file!.filetype, message.file!.preview, message.file!.path]
          );
        }
        return await txn.rawInsert(
            'INSERT INTO message(id, local_id, chat_id, user_id, message, created_at, '
                'updated_at, replied_message_id, replied_message_author, replied_message_text) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ',
            [message.messageId, message.messageId, message.dialogId, message.senderId, message.message, message.rawDate.toString(),
               message.rawDate.toString(), message.repliedMessage?.parentMessageId, message.repliedMessage?.senderId, message.repliedMessage?.parentMessageText]
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future<int> deleteMessages(List<int> ids) async {
    final db = await DBProvider.db.database;
    return await db.transaction((txn) async {
      final res = await txn.rawDelete(
        'DELETE FROM message WHERE id IN (${ids.join(', ')}); '
      );
      print('deleteMessages  $res');
      return res;
    });
  }

  Future<int> updateMessageId(int localMessageId, int messageId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE message SET id = "$messageId", local_id = NULL WHERE local_id = "$localMessageId"; '
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future<int> updateMessageWithSendingFailure(int localMessageId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE message SET send_failed = 1 WHERE local_id = "$localMessageId"; '
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future<int> updateMessageErrorStatusOnResend(int localMessageId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE message SET send_failed = 0 WHERE local_id = "$localMessageId"; '
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future updateMessagesThatFailedToBeSent() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE message SET send_failed = 1 WHERE local_id IS NOT NULL; '
        );
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future<int> checkIfMessageExistWithThisId(int id) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        final res = await txn.rawQuery(
            'SELECT id FROM message WHERE id = $id; '
        );
        print('DBBloc send:: res id: $res');
        return res.isEmpty ? 1 : 0;
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }

  Future<List<int>?> updateLocalMessageByContent(int messageId, String message, int? fileId) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        final res = await txn.rawQuery(
            'SELECT id FROM message '
            'WHERE message = "$message" AND local_id IS NOT NULL; '
        );
        print('updated result  $res  where $messageId, $message');
        if (res.isNotEmpty) {
          final localId = res.first["id"];
          await txn.rawUpdate(
            'UPDATE message SET id = "$messageId", local_id = NULL WHERE id = "$localId"; '
          );
          if (fileId != null) {
            await txn.rawUpdate(
                'UPDATE attachments SET id="$fileId", chat_message_id = "$messageId" WHERE id = "$localId"; '
            );
          }
          return [localId as int, messageId];
        }
        return null;
      });
    } catch (err, stackTrace) {
      rethrow;
    }
  }
}