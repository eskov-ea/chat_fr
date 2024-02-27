import 'dart:developer';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/services/database/db_provider.dart';

class ChatUsersDBLayer {


  Future<void> saveChatUser(ChatUser cu) async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO chat_user(chat_id, chat_user_role_id, active, user_id) VALUES(?, ?, ?, ?)',
            [cu.chatId, cu.chatUserRole, cu.active ? 1 : 0, cu.userId]
        );
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }

  Future<List<ChatUserDB>> readChatUsers() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery('SELECT * FROM chat_user ');
        print(res);
        return res.map((el) => ChatUserDB.fromJson(el)).toList();
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}