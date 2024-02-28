import 'dart:developer';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';

class ChatUsersDBLayer {


  Future<List<Object?>> saveChatUsers(List<ChatUserDB> chatUsers) async {
    try {
      final db = await DBProvider.db.database;
      final Batch batch = db.batch();
      for (var chatUser in chatUsers) {
        batch.execute(
            'INSERT INTO chat_user(chat_id, chat_user_role_id, active, user_id) VALUES(?, ?, ?, ?) '
                'ON CONFLICT(id) DO UPDATE SET '
                'chat_id = ${chatUser.chatId}, '
                'chat_user_role_id = ${chatUser.chatUserRole}, '
                'active = ${chatUser.active}, '
                'user_id = ${chatUser.userId} ',
            [chatUser.chatId, chatUser.chatUserRole, chatUser.active, chatUser.userId]
        );
      }
      return await batch.commit(noResult: true);
    } catch (err, stackTrace) {
      log('DB operation error:  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<List<ChatUserDB>> getChatUsers() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('SELECT * FROM chat_user ');
        print('Chat users::: $res');
        return res.map((el) => ChatUserDB.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}