import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';



class DialogDBLayer {

  Future<int> saveDialog(DialogData d) async {
    final db = await DBProvider.db.database;
    return await db.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO person(id, name, description, chat_type, user_id, '
            'message, is_closed, is_public, message_count, picture, created_at, updated_at) '
            'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            d.dialogId, //id
            d.name, //name
            d.description, //description
            d.chatType.name, //chat_type
            d.userData.id, //user_id
            d.lastMessage.messageId, //message
            0, //d.isClosed,
            1, //d.isPublic,
            d.messageCount,
            d.picture,
            d.createdAt,
            d.createdAt
          ]
      );
      return id;
    });
  }

}