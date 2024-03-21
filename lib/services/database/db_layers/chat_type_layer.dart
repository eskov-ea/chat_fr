import 'package:chat/services/database/db_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatTypeDBLayer {

  Future initializeChatTypeValues() async {
    final db = await DBProvider.db.database;
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT OR IGNORE INTO chat_type(name, description, p2p, secure, readonly) VALUES(?, ?, ?, ?, ?)',
          ['Приват', 'Приватный чат между двумя участниками', 1, 0, 0]
      );
      await txn.rawInsert(
          'INSERT OR IGNORE INTO chat_type(name, description, p2p, secure, readonly) VALUES(?, ?, ?, ?, ?)',
          ['Групповой', 'Групповой чат', 0, 0, 0]
      );
      await txn.rawInsert(
          'INSERT OR IGNORE INTO chat_type(name, description, p2p, secure, readonly) VALUES(?, ?, ?, ?, ?)',
          ['Приват безопасный', 'Приватный чат с шифрацией и без хранения', 1, 1, 0]
      );
      await txn.rawInsert(
          'INSERT OR IGNORE INTO chat_type(name, description, p2p, secure, readonly) VALUES(?, ?, ?, ?, ?)',
          ['Групповой безопасный', 'Групповой чат с шифрацией и без хранения', 0, 1, 0]
      );
      await txn.rawInsert(
          'INSERT OR IGNORE INTO chat_type(name, description, p2p, secure, readonly) VALUES(?, ?, ?, ?, ?)',
          ['Групповой для чтения', 'Групповой чат в ражиме чтения пользователя-создателя', 0, 0, 1]
      );
    });
  }

  Future<List<Object>> readChatTypes() async {
    final db = await DBProvider.db.database;
    return await db.transaction((txn) async {
      return await txn
          .rawQuery(
          'SELECT * FROM chat_type ');
    });
  }
}