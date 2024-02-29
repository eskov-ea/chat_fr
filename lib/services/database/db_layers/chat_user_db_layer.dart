import 'dart:developer';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';

class ChatUsersDBLayer {


  Future<List<Object?>> saveChatUsers(List<ChatUser> chatUsers) async {
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

  Future<Map<int, List<ChatUser>>> getChatUsers() async {
    try {
      final chatUsersMap = <int, List<ChatUser>>{};
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        List<Object> res = await txn.rawQuery(
            'SELECT cu.id chat_user_record_id, cu.chat_id, cu.chat_user_role_id, cu.active, cu.user_id, '
            'u.firstname, u.lastname, u.middlename, u.company, u.dept, u.position, u.phone, u.email, u.birthdate, u.avatar, u.banned, u.last_access '
            'FROM chat_user cu '
            'JOIN user u ON (cu.user_id = u.id); '
        );
        print('Chat users::: $res');
        res.map((el) {
          el as Map;
          if(chatUsersMap.containsKey(el["chat_id"])) {
            chatUsersMap[el["chat_id"]]!.add(ChatUser.fromJson(el));
          } else {
            chatUsersMap.addAll({el["chat_id"]: [ChatUser.fromJson(el)]});
          }
        });
        return chatUsersMap;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $stackTrace');
      rethrow;
    }
  }
}