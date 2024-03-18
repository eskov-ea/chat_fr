import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/contact_model.dart';
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

  /// CHAT TYPE DB LAYER
  Future initializeChatTypeValues() async => await ChatTypeDBLayer().initializeChatTypeValues();
  Future<List<Object>> readChatTypes() async => await ChatTypeDBLayer().readChatTypes();


  ///   DIALOGS LAYER
  Future<void> saveDialogs(List<DialogData> dialogs) async => await DialogDBLayer().saveDialog(dialogs);
  Future<List<DialogData>> getDialogs() async => await DialogDBLayer().getDialogs();
  Future<int> updateDialogLastPage(int dialogId, int page) async => DialogDBLayer().updateDialogLastPage(dialogId, page);
  Future<int?> getLastDialogPage(int dialogId) async => DialogDBLayer().getLastDialogPage(dialogId);
  Future<int> updateDialogLastMessage(MessageData message) async => DialogDBLayer().updateDialogLastMessage(message);
  Future<List<DialogData>> getDialogById(int id) async => await DialogDBLayer().getDialogById(id);


  ///   MESSAGES LAYER
  Future<List<Object?>> saveMessages(List<MessageData> messages) async => MessageDBLayer().saveMessages(messages);
  Future<Map<int, MessageData>> getMessages() async => MessageDBLayer().getMessages();
  Future<List<MessageData>> getMessagesByDialog(int dialogId) async => MessageDBLayer().getMessagesByDialog(dialogId);
  Future<String> getMessageInfo() async => MessageDBLayer().getMessageInfo();
  Future<int> saveLocalMessage(MessageData message) async => MessageDBLayer().saveLocalMessage(message);
  Future<int> updateMessageWithSendFailed(int localMessageId) => MessageDBLayer().updateMessageWithSendingFailure(localMessageId);
  Future<int> updateMessageId(int localMessageId, int messageId) async => MessageDBLayer().updateMessageId(localMessageId, messageId);
  Future<MessageData?> getMessageByLocalId(String localId) async => MessageDBLayer().getMessageByLocalId(localId);
  Future<List?> updateLocalMessage(MessageData message) async => MessageDBLayer().updateLocalMessage(message);
  Future<int> checkIfMessageExistWithThisId(int id) async => MessageDBLayer().checkIfMessageExistWithThisId(id);
  Future updateMessagesThatFailedToBeSent() async => MessageDBLayer().updateMessagesThatFailedToBeSent();
  Future<int> updateMessageErrorStatusOnResend(String localMessageId) async => MessageDBLayer().updateMessageErrorStatusOnResend(localMessageId);
  Future<int> deleteMessages(List<int> ids) async => MessageDBLayer().deleteMessages(ids);


  ///   MESSAGE STATUS LAYER
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses) async => MessageStatusDBLayer().saveMessageStatuses(statuses);
  Future<Object?> saveMessageStatus(MessageStatus status) async => MessageStatusDBLayer().saveMessageStatus(status);
  Future<List<MessageStatus>> getMessageStatuses() async => MessageStatusDBLayer().getMessageStatuses();
  Future<int?> saveLocalMessageStatus(MessageStatus? status) async => MessageStatusDBLayer().saveLocalMessageStatus(status);
  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id) async => MessageStatusDBLayer().getMessageStatusesByMessageId(id);


  ///   MESSAGE ATTACHMENTS LAYER
  Future saveAttachments(List<MessageAttachmentData> files) async => AttachmentDBLayer().saveAttachment(files);
  Future<List<MessageAttachmentData>> getAttachments() async => AttachmentDBLayer().getAttachments();
  Future<MessageAttachmentData> getAttachmentById(int id) async => AttachmentDBLayer().getAttachmentById(id);
  Future<int> updateFilePath(int id, String path) async => await AttachmentDBLayer().updateFilePath(id, path);


  ///   USERS LAYER
  Future<void> saveUsers(List<UserModel> users) async => await UsersDBLayer().saveUsers(users);
  Future<Map<int, UserModel>> getUsers() async => await UsersDBLayer().getUsers();


  ///   CHAT USERS LAYER
  Future<void> saveChatUsers(List<ChatUser> chatUsers) async => await ChatUsersDBLayer().saveChatUsers(chatUsers);
  Future<Map<int, List<ChatUser>>> getChatUsers() async => await ChatUsersDBLayer().getChatUsers();
  Future<int> deleteChatUser(ChatUser chatUser) async => await ChatUsersDBLayer().deleteChatUser(chatUser);
  Future<int> addUserToChat(ChatUser chatUser) async => await ChatUsersDBLayer().addUserToChat(chatUser);
  Future<List<ChatUser>> getChatUsersByDialogId(int dialogId) async => await ChatUsersDBLayer().getChatUsersByDialogId(dialogId);


  ///   USER PROFILE LAYER
  Future<bool> saveUserProfile(UserProfileData profile) async => await UserProfileDBLayer().saveUserProfile(profile);
  Future<UserProfileData> getProfile() async => await UserProfileDBLayer().getProfile();


  /// APP STATE DB LAYER
  Future<String> getLastUpdateTime() async => await AppStateDBLayer().getLastUpdateTime();
  Future<int> setLastUpdateTime() async => await AppStateDBLayer().setLastUpdateTime();
  Future<String?> getToken() async => await AppStateDBLayer().getToken();
  Future<int?> getUserId() async => await AppStateDBLayer().getUserId();
  Future<String> getDeviceId() async => await AppStateDBLayer().getDeviceId();
  Future<int> setToken(String token) async => AppStateDBLayer().setToken(token);
  Future<int> setUserId(int userId) async => AppStateDBLayer().setUserId(userId);
  Future<String> getSipContacts() async => AppStateDBLayer().getSipContacts();
  Future<int> setSipContacts(String contacts) async => AppStateDBLayer().setSipContacts(contacts);
  Future<int> setDeviceId(String deviceId) async => AppStateDBLayer().setDeviceId(deviceId);
  Future<AppSettings> getAppSettings() async => AppStateDBLayer().getAppSettings();
  Future<int> initAppSettings() async => AppStateDBLayer().initAppSettings();
  Future<int> updateBooleanAppSettingByFieldAndValue(String field, int value) async => AppStateDBLayer().updateBooleanAppSettingByFieldAndValue(field, value);


  ///   DB DEVELOPER SERVICE
  Future<List<Object>> checkExistingTables() async => await DBDeveloperService().checkExistingTables();
  Future deleteDBFile() async => await DBDeveloperService().deleteDBFile();


  ///   HELPER FUNCTIONS
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




