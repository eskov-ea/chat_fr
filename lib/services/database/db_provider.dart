import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_layers/attachment_db_layer.dart';
import 'package:chat/services/database/db_layers/chat_type_layer.dart';
import 'package:chat/services/database/db_layers/chat_user_db_layer.dart';
import 'package:chat/services/database/db_layers/dialog_db_layer.dart';
import 'package:chat/services/database/db_layers/message_db_layer.dart';
import 'package:chat/services/database/db_layers/message_status_db_layer.dart';
import 'package:chat/services/database/db_layers/users_db_layer.dart';
import 'package:chat/services/database/developers.dart';
import 'package:chat/services/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }


  /// DB INITIALIZE

  Future<Database> initDB() async {
    try {
      final databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'mcfef.db');
      return await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await createTables(db);
        await db.transaction((txn) async {
          return await txn.rawUpdate(
              'INSERT INTO app_settings(id, first_initialize) VALUES(?, ?)',
              [1, 0]
          );
        });
      }, onOpen: (db) async {
        final List<Object> rawTables =
            await db.rawQuery('SELECT * FROM sqlite_master');
        final List<DBTable> existingTables =
            rawTables.map((el) => DBTable.fromJson(el)).toList();
        tables.forEach((k, sql) async {
          if (!checkIfTableExists(existingTables, k)) {
            await db.execute(sql);
            print("TABLE CREATED ::::::");
          }
        });
      });
    } catch(err, stack) {
      log('DBInit error::   $stack');
      rethrow;
    }
  }

  /// CHAT TYPE DB LAYER
  Future initializeChatTypeValues() async => await ChatTypeDBLayer().initializeChatTypeValues();
  Future<List<Object>> readChatTypes() async => await ChatTypeDBLayer().readChatTypes();


  ///   DIALOGS LAYER
  Future<void> saveDialogs(List<DialogData> dialogs) async => await DialogDBLayer().saveDialog(dialogs);
  Future<List<DialogData>> getDialogs() async => await DialogDBLayer().getDialogs();


  ///   MESSAGES LAYER
  Future<List<Object?>> saveMessages(List<MessageData> messages) async => MessageDBLayer().saveMessages(messages);
  Future<Map<int, MessageData>> getMessages() async => MessageDBLayer().getMessages();


  ///   MESSAGE STATUS LAYER
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> messages) async => MessageStatusDBLayer().saveMessageStatuses(messages);
  Future<List<MessageStatus>> getMessageStatuses() async => MessageStatusDBLayer().getMessageStatuses();


      ///   MESSAGE ATTACHMENTS LAYER
  Future saveAttachments(List<MessageAttachmentData> files) async => AttachmentDBLayer().saveAttachment(files);


  ///   USERS LAYER
  Future<void> saveUsers(List<UserModel> users) async => await UsersDBLayer().saveUsers(users);
  Future<Map<int, UserModel>> getUsers() async => await UsersDBLayer().getUsers();


  ///   CHAT USERS LAYER
  Future<void> saveChatUsers(List<ChatUser> chatUsers) async => await ChatUsersDBLayer().saveChatUsers(chatUsers);
  Future<Map<int, List<ChatUser>>> getChatUsers() async => await ChatUsersDBLayer().getChatUsers();


  ///   DB DEVELOPER SERVICE
  Future<List<Object>> checkExistingTables() async => await DBDeveloperService().checkExistingTables();
  Future deleteDBFile() async => await DBDeveloperService().deleteDBFile();


  ///   HELPER FUNCTIONS
  Future<void> createTables(Database db) async {
    try {
      tables.forEach((key, sql) async {
        await db.execute(sql);
        print('Tables initialized');
      });
    } catch (err) {
      print("ERROR:DBProvider:73:: $err");
    }
  }
  Future<bool> checkIfDatabaseIsEmpty() async {
    final db = await database;
    return db.transaction((txn) async {
      final res = await txn.rawQuery('SELECT * FROM app_settings ');
      print('checkIfDatabaseIsNotEmpty  $res');
      if (res.isEmpty) {
        return true;
      } else {
        return res.first["first_initialize"] == 0;
      }
    });
  }

  Future<int> updateAppSettingsTable({int? dbInitialized, String? deviceId}) async {
    final db = await database;
    await db.transaction((txn) async {
      final baseSql = 'UPDATE app_settings SET ';
      final dbInitStatus = dbInitialized == null ? '' : 'first_initialize = $dbInitialized';
      final deviceQuery = deviceId == null ? '' : ', device_id = $deviceId ';
      return await txn.rawUpdate(
        baseSql + dbInitStatus + deviceQuery + ';'
      );
    });
    print('settings updated');
    return 1;
  }


  Future<void> DeveloperModeClearPersonTable() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS dialog");
    await db.execute("DROP TABLE IF EXISTS user");
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mcfef.db');
    final dbFile = File(path);
    print(dbFile.uri);
    print(dbFile.lengthSync());
    print(dbFile.lastAccessedSync());
    dbFile.deleteSync(recursive: true);
    print('Tables deleted');
  }


  String dateFormatter(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

}

class DBTable {
  final String name;
  const DBTable({required this.name});
  static DBTable fromJson(json) => DBTable(name: json["name"]);
}


bool checkIfTableExists(List<DBTable> existingTables, String searchingTableName) {
  final res = existingTables.where((el) =>
  el.name == searchingTableName
  );
  return res.isEmpty ?  false : true;
}




