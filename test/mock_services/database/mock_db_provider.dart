import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/database/db_provider_interface.dart';
import 'package:chat/services/database/tables.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class MockDBProvider implements IDBProvider {

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

  @override
  Future<Database> initDB() async {
    var db = await openDatabase(inMemoryDatabasePath);
    await createTables(db);
    await db.transaction((txn) async {
      return await txn.rawUpdate(
          'INSERT INTO app_settings(id, first_initialize) VALUES(?, ?)',
          [1, 0]
      );
    });
    configAppValues(db);
    return db;
  }

  @override
  Future<int> initAppSettings() async {
    return await _database!.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT OR IGNORE INTO app_settings(id) VALUES(?); ',
          [1]
      );
    });
  }

  @override
  Future initializeChatTypeValues() async {
    await _database!.transaction((txn) async {
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

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    final Batch batch = _database!.batch();
    for (var user in users) {
      batch.execute(
          'INSERT OR IGNORE INTO user(id, firstname, lastname, middlename, company, dept, position, '
              'phone, email, birthdate, avatar, banned, last_access) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ',
          [user.id, user.firstname, user.lastname, user.middlename, user.company,
            user.dept, user.position, user.phone, user.email, user.birthdate,
            user.avatar, user.banned, user.lastAccess]
      );
    }
    await batch.commit(noResult: true);
    return;
  }

  @override
  Future<bool> saveUserProfile(UserProfileData profile) async {
    final appSettingsSql =
        'UPDATE app_settings SET '
        'autojoin_chats = "${profile.chatSettings?.autoJoinChats.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '')}", '
        'version_android = "${profile.appSettings.versionAndroid}", '
        'version_ios = "${profile.appSettings.versionIos}", '
        'android_download_link = "${profile.appSettings.downloadUrlAndroid}", '
        'ios_download_link = "${profile.appSettings.downloadUrlIos}"'
        'WHERE id = 1 ';
    final sipSettingsSql =
        'INSERT INTO sip_settings(id, user_domain, sip_port, stun_host, stun_port, '
        'sip_user_login, sip_user_password, sip_prefix, sip_host, sip_cert) '
        'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET '
        'user_domain = "${profile.sipSettings.userDomain}", '
        'sip_port = "${profile.sipSettings.asteriskPort}", '
        'stun_host = "${profile.sipSettings.stunHost}", '
        'stun_port = "${profile.sipSettings.stunPort}", '
        'sip_user_login = "${profile.sipSettings.asteriskUserLogin}", '
        'sip_user_password = "${profile.sipSettings.asteriskUserPassword}", '
        'sip_prefix = "${profile.sipSettings.sipPrefix}", '
        'sip_host = "${profile.sipSettings.asteriskHost}", '
        'sip_cert = "${profile.sipSettings.asteriskCert}"';
    return await _database!.transaction((txn) async {
      await txn.rawUpdate(appSettingsSql);
      await txn.rawInsert(
          sipSettingsSql,
          [1, profile.sipSettings.userDomain, profile.sipSettings.asteriskPort, profile.sipSettings.stunHost,
            profile.sipSettings.stunPort, profile.sipSettings.asteriskUserLogin,
            profile.sipSettings.asteriskUserPassword, profile.sipSettings.sipPrefix,
            profile.sipSettings.asteriskHost, profile.sipSettings.asteriskCert]
      );
      return true;
    });
  }

  @override
  Future<int> updateBooleanAppSettingByFieldAndValue(String field, int value) async {
    return await _database!.transaction((txn) async {
      return await txn.rawUpdate(
          'UPDATE app_settings SET "$field" = "$value"; '
      );
    });
  }

  @override
  Future<void> createTables(Database db) async {
    tables.forEach((key, sql) async {
      await db.execute(sql);
      print('Table initialized $key');
    });
  }









  @override
  Future<int> addUserToChat(ChatUser chatUser) {
    throw UnimplementedError();
  }

  @override
  Future<List<Object>> checkExistingTables() {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkIfDatabaseIsEmpty() {
    throw UnimplementedError();
  }

  @override
  Future<int> checkIfMessageExistWithThisId(int id) {
    throw UnimplementedError();
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
  Future<bool> deleteAllDataOnLogout() {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteChatUser(ChatUser chatUser) {
    throw UnimplementedError();
  }

  @override
  Future deleteDBFile() {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteMessages(List<int> ids) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteNotSentMessagesOlder5days() {
    throw UnimplementedError();
  }

  @override
  Future<AppSettings> getAppSettings() {
    throw UnimplementedError();
  }

  @override
  Future<MessageAttachmentData> getAttachmentById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageAttachmentData>> getAttachments() {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, List<ChatUser>>> getChatUsers() {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatUser>> getChatUsersByDialogId(int dialogId) {
    throw UnimplementedError();
  }

  @override
  Future<String> getDeviceId() {
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getDialogById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getDialogs() {
    throw UnimplementedError();
  }

  @override
  Future<int?> getLastDialogPage(int dialogId) {
    throw UnimplementedError();
  }

  @override
  Future<int> getLastId() {
    throw UnimplementedError();
  }

  @override
  Future<String> getLastUpdateTime() {
    throw UnimplementedError();
  }

  @override
  Future<MessageData?> getMessageByLocalId(String localId) {
    throw UnimplementedError();
  }

  @override
  Future<String> getMessageInfo() {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageStatus>> getMessageStatuses() {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, MessageData>> getMessages() {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageData>> getMessagesByDialog(int dialogId) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfileData> getProfile() {
    throw UnimplementedError();
  }

  @override
  Future<String> getSipContacts() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getToken() {
    throw UnimplementedError();
  }

  @override
  Future<int?> getUserId() {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, UserModel>> getUsers() {
    throw UnimplementedError();
  }

  @override
  Future<List<Object>> readChatTypes() {
    throw UnimplementedError();
  }

  @override
  Future saveAttachments(List<MessageAttachmentData> files) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveChatUsers(List<ChatUser> chatUsers) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveDialogs(List<DialogData> dialogs) {
    throw UnimplementedError();
  }

  @override
  Future<int> saveLocalMessage(MessageData message) {
    throw UnimplementedError();
  }

  @override
  Future<int?> saveLocalMessageStatus(MessageStatus? status) {
    throw UnimplementedError();
  }

  @override
  Future<Object?> saveMessageStatus(MessageStatus status) {
    throw UnimplementedError();
  }

  @override
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses) {
    throw UnimplementedError();
  }

  @override
  Future<List<Object?>> saveMessages(List<MessageData> messages) {
    throw UnimplementedError();
  }

  @override
  Future<int> setDeviceId(String deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<int> setLastUpdateTime() {
    throw UnimplementedError();
  }

  @override
  Future<int> setSipContacts(String contacts) {
    throw UnimplementedError();
  }

  @override
  Future<int> setToken(String token) {
    throw UnimplementedError();
  }

  @override
  Future<int> setUserId(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateAppSettingsTable({int? dbInitialized, String? deviceId}) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateDialogLastMessage(MessageData message) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateDialogLastPage(int dialogId, int page) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateFilePath(int id, String path) {
    throw UnimplementedError();
  }

  @override
  Future<List?> updateLocalMessage(MessageData message) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageErrorStatusOnResend(String localMessageId) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageId(int localMessageId, int messageId) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageWithSendFailed(String localMessageId) {
    throw UnimplementedError();
  }

  @override
  Future updateMessagesThatFailedToBeSent() {
    throw UnimplementedError();
  }

  @override
  Future<void> DeveloperModeClearPersonTable() {
    throw UnimplementedError();
  }

}