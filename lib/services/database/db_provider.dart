import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/database/db_layers/app_state_db_layer.dart';
import 'package:chat/services/database/db_layers/attachment_db_layer.dart';
import 'package:chat/services/database/db_layers/chat_type_layer.dart';
import 'package:chat/services/database/db_layers/chat_user_db_layer.dart';
import 'package:chat/services/database/db_layers/dialog_db_layer.dart';
import 'package:chat/services/database/db_layers/message_db_layer.dart';
import 'package:chat/services/database/db_layers/message_status_db_layer.dart';
import 'package:chat/services/database/db_layers/user_profile_db_layer.dart';
import 'package:chat/services/database/db_layers/users_db_layer.dart';
import 'package:chat/services/database/db_provider_interface.dart';
import 'package:chat/services/database/developers.dart';
import 'package:chat/services/database/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBProvider implements IDBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }


  /// DB INITIALIZE

  @override
  Future<Database> initDB() async {
    print('Init DB:::  $_database');
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
        configAppValues(db);
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

  Future<void> upgradeDBDumbWay() async {
    _database = await initDB();
    return;
  }

  /// CHAT TYPE DB LAYER
  @override
  Future initializeChatTypeValues() async => await ChatTypeDBLayer().initializeChatTypeValues();
  @override
  Future<List<Object>> readChatTypes() async => await ChatTypeDBLayer().readChatTypes();


  ///   DIALOGS LAYER
  @override
  Future<void> saveDialogs(List<DialogData> dialogs) async => await DialogDBLayer().saveDialog(dialogs);
  @override
  Future<List<DialogData>> getDialogs() async => await DialogDBLayer().getDialogs();
  @override
  Future<int> updateDialogLastPage(int dialogId, int page) async => DialogDBLayer().updateDialogLastPage(dialogId, page);
  @override
  Future<int?> getLastDialogPage(int dialogId) async => DialogDBLayer().getLastDialogPage(dialogId);
  @override
  Future<int> updateDialogLastMessage(MessageData message) async => DialogDBLayer().updateDialogLastMessage(message);
  @override
  Future<List<DialogData>> getDialogById(int id) async => await DialogDBLayer().getDialogById(id);


  ///   MESSAGES LAYER
  @override
  Future<List<Object?>> saveMessages(List<MessageData> messages) async => MessageDBLayer().saveMessages(messages);
  @override
  Future<Map<int, MessageData>> getMessages() async => MessageDBLayer().getMessages();
  @override
  Future<List<MessageData>> getMessagesByDialog(int dialogId) async => MessageDBLayer().getMessagesByDialog(dialogId);
  @override
  Future<String> getMessageInfo() async => MessageDBLayer().getMessageInfo();
  @override
  Future<int> saveLocalMessage(MessageData message) async => MessageDBLayer().saveLocalMessage(message);
  @override
  Future<int> updateMessageWithSendFailed(String localMessageId) => MessageDBLayer().updateMessageWithSendingFailure(localMessageId);
  @override
  Future<int> updateMessageId(int localMessageId, int messageId) async => MessageDBLayer().updateMessageId(localMessageId, messageId);
  @override
  Future<MessageData?> getMessageByLocalId(String localId) async => MessageDBLayer().getMessageByLocalId(localId);
  @override
  Future<List?> updateLocalMessage(MessageData message) async => MessageDBLayer().updateLocalMessage(message);
  @override
  Future<int> checkIfMessageExistWithThisId(int id) async => MessageDBLayer().checkIfMessageExistWithThisId(id);
  @override
  Future updateMessagesThatFailedToBeSent() async => MessageDBLayer().updateMessagesThatFailedToBeSent();
  @override
  Future<int> updateMessageErrorStatusOnResend(String localMessageId) async => MessageDBLayer().updateMessageErrorStatusOnResend(localMessageId);
  @override
  Future<int> deleteMessages(List<int> ids) async => MessageDBLayer().deleteMessages(ids);
  @override
  Future<int> getLastId() async => await MessageDBLayer().getLastId();
  @override
  Future<int> deleteNotSentMessagesOlder5days() async => await MessageDBLayer().deleteNotSentMessagesOlder5days();
  Future<MessageData?> getDialogLastMessage(int dialogId) async => await MessageDBLayer().getDialogLastMessage(dialogId);

  ///   MESSAGE STATUS LAYER
  @override
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses) async => MessageStatusDBLayer().saveMessageStatuses(statuses);
  @override
  Future<Object?> saveMessageStatus(MessageStatus status) async => MessageStatusDBLayer().saveMessageStatus(status);
  @override
  Future<List<MessageStatus>> getMessageStatuses() async => MessageStatusDBLayer().getMessageStatuses();
  @override
  Future<int?> saveLocalMessageStatus(MessageStatus? status) async => MessageStatusDBLayer().saveLocalMessageStatus(status);
  @override
  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id) async => MessageStatusDBLayer().getMessageStatusesByMessageId(id);


  ///   MESSAGE ATTACHMENTS LAYER
  @override
  Future saveAttachments(List<MessageAttachmentData> files) async => AttachmentDBLayer().saveAttachment(files);
  @override
  Future<List<MessageAttachmentData>> getAttachments() async => AttachmentDBLayer().getAttachments();
  @override
  Future<MessageAttachmentData> getAttachmentById(int id) async => AttachmentDBLayer().getAttachmentById(id);
  @override
  Future<int> updateFilePath(int id, String path) async => await AttachmentDBLayer().updateFilePath(id, path);


  ///   USERS LAYER
  @override
  Future<void> saveUsers(List<UserModel> users) async => await UsersDBLayer().saveUsers(users);
  @override
  Future<Map<int, UserModel>> getUsers() async => await UsersDBLayer().getUsers();


  ///   CHAT USERS LAYER
  @override
  Future<void> saveChatUsers(List<ChatUser> chatUsers) async => await ChatUsersDBLayer().saveChatUsers(chatUsers);
  @override
  Future<Map<int, List<ChatUser>>> getChatUsers() async => await ChatUsersDBLayer().getChatUsers();
  @override
  Future<int> deleteChatUser(ChatUser chatUser) async => await ChatUsersDBLayer().deleteChatUser(chatUser);
  @override
  Future<int> addUserToChat(ChatUser chatUser) async => await ChatUsersDBLayer().addUserToChat(chatUser);
  @override
  Future<List<ChatUser>> getChatUsersByDialogId(int dialogId) async => await ChatUsersDBLayer().getChatUsersByDialogId(dialogId);


  ///   USER PROFILE LAYER
  @override
  Future<bool> saveUserProfile(UserProfileData profile) async => await UserProfileDBLayer().saveUserProfile(profile);
  @override
  Future<UserProfileData> getProfile() async => await UserProfileDBLayer().getProfile();


  /// APP STATE DB LAYER
  @override
  Future<String> getLastUpdateTime() async => await AppStateDBLayer().getLastUpdateTime();
  @override
  Future<int> setLastUpdateTime() async => await AppStateDBLayer().setLastUpdateTime();
  @override
  Future<String?> getToken() async => await AppStateDBLayer().getToken();
  @override
  Future<int?> getUserId() async => await AppStateDBLayer().getUserId();
  @override
  Future<String> getDeviceId() async => await AppStateDBLayer().getDeviceId();
  @override
  Future<int> setToken(String token) async => AppStateDBLayer().setToken(token);
  @override
  Future<int> setUserId(int userId) async => AppStateDBLayer().setUserId(userId);
  @override
  Future<String> getSipContacts() async => AppStateDBLayer().getSipContacts();
  @override
  Future<int> setSipContacts(String contacts) async => AppStateDBLayer().setSipContacts(contacts);
  @override
  Future<int> setDeviceId(String deviceId) async => AppStateDBLayer().setDeviceId(deviceId);
  @override
  Future<AppSettings> getAppSettings() async => AppStateDBLayer().getAppSettings();
  @override
  Future<int> initAppSettings() async => AppStateDBLayer().initAppSettings();
  @override
  Future<int> updateBooleanAppSettingByFieldAndValue(String field, int value) async => AppStateDBLayer().updateBooleanAppSettingByFieldAndValue(field, value);


  ///   DB DEVELOPER SERVICE
  @override
  Future<List<Object>> checkExistingTables() async => await DBDeveloperService().checkExistingTables();
  @override
  Future deleteDBFile() async => await DBDeveloperService().deleteDBFile();


  ///   HELPER FUNCTIONS
  @override
  Future<void> createTables(Database db) async {
    try {
      tables.forEach((key, sql) async {
        await db.execute(sql);
        print('Table initialized $key');
      });
    } catch (err) {
      print("ERROR:DBProvider:73:: $err");
    }
  }
  @override
  Future<bool> checkIfDatabaseIsEmpty() async {
    final db = await database;
    return db.transaction((txn) async {
      final res = await txn.rawQuery('SELECT first_initialize FROM app_settings ');
      if (res.isEmpty) {
        return true;
      } else {
        return res.first["first_initialize"] == 0;
      }
    });
  }
  @override
  Future<bool> deleteAllDataOnLogout() async {
    final db = await database;
    try {
      tables.forEach((tableName, _) async {
        await db.rawDelete(
          'DELETE FROM $tableName'
        );
        print('Tables cleared');
      });
      return true;
    } catch (err) {
      print("ERROR:DBProvider:73:: $err");
      return false;
    }
  }
  @override
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

  @override
  Future<int> configAppValues(Database db) async {
    return await db.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT OR IGNORE INTO user(id, firstname, lastname, middlename, company, dept, position, '
              'phone, email, birthdate, avatar, banned, last_access) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ',
          [5, '', 'MCFEF Чат-бот', '', '',
            '', '', '', '', '',
            null, 0, null]
      );
    });
  }


  @override
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

  @override
  String toString() {
    return "'Instance of 'DBTable' name: $name\r\n";
  }
}


bool checkIfTableExists(List<DBTable> existingTables, String searchingTableName) {
  final res = existingTables.where((el) =>
  el.name == searchingTableName
  );
  return res.isEmpty ?  false : true;
}




