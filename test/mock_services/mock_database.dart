import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/database/db_provider_interface.dart';
import 'package:chat/services/database/tables.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



class MockDBProvider implements IDBProvider {

  @override
  Future<Database> get database async {
    return await initDB();
  }

  @override
  Future<Database> initDB() async {
    return await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
          await createTables(db);
          await db.transaction((txn) async {
            return await txn.rawUpdate(
              'INSERT INTO app_settings(id, first_initialize) VALUES(?, ?)',
              [1, 0]
            );
          });
          configAppValues(db);
    });
  }



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
  Future<void> DeveloperModeClearPersonTable() {
    // TODO: implement DeveloperModeClearPersonTable
    throw UnimplementedError();
  }

  @override
  Future<int> addUserToChat(ChatUser chatUser) {
    // TODO: implement addUserToChat
    throw UnimplementedError();
  }

  @override
  Future<List<Object>> checkExistingTables() {
    // TODO: implement checkExistingTables
    throw UnimplementedError();
  }

  @override
  Future<bool> checkIfDatabaseIsEmpty() {
    // TODO: implement checkIfDatabaseIsEmpty
    throw UnimplementedError();
  }

  @override
  Future<int> checkIfMessageExistWithThisId(int id) {
    // TODO: implement checkIfMessageExistWithThisId
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteAllDataOnLogout() {
    // TODO: implement deleteAllDataOnLogout
    throw UnimplementedError();
  }

  @override
  Future<int> deleteChatUser(ChatUser chatUser) {
    // TODO: implement deleteChatUser
    throw UnimplementedError();
  }

  @override
  Future deleteDBFile() {
    // TODO: implement deleteDBFile
    throw UnimplementedError();
  }

  @override
  Future<int> deleteMessages(List<int> ids) {
    // TODO: implement deleteMessages
    throw UnimplementedError();
  }

  @override
  Future<int> deleteNotSentMessagesOlder5days() {
    // TODO: implement deleteNotSentMessagesOlder5days
    throw UnimplementedError();
  }

  @override
  Future<AppSettings> getAppSettings() {
    // TODO: implement getAppSettings
    throw UnimplementedError();
  }

  @override
  Future<MessageAttachmentData> getAttachmentById(int id) {
    // TODO: implement getAttachmentById
    throw UnimplementedError();
  }

  @override
  Future<List<MessageAttachmentData>> getAttachments() {
    // TODO: implement getAttachments
    throw UnimplementedError();
  }

  @override
  Future<Map<int, List<ChatUser>>> getChatUsers() {
    // TODO: implement getChatUsers
    throw UnimplementedError();
  }

  @override
  Future<List<ChatUser>> getChatUsersByDialogId(int dialogId) {
    // TODO: implement getChatUsersByDialogId
    throw UnimplementedError();
  }

  @override
  Future<String> getDeviceId() {
    // TODO: implement getDeviceId
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getDialogById(int id) {
    // TODO: implement getDialogById
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getDialogs() {
    // TODO: implement getDialogs
    throw UnimplementedError();
  }

  @override
  Future<int?> getLastDialogPage(int dialogId) {
    // TODO: implement getLastDialogPage
    throw UnimplementedError();
  }

  @override
  Future<int> getLastId() {
    // TODO: implement getLastId
    throw UnimplementedError();
  }

  @override
  Future<String> getLastUpdateTime() {
    // TODO: implement getLastUpdateTime
    throw UnimplementedError();
  }

  @override
  Future<MessageData?> getMessageByLocalId(String localId) {
    // TODO: implement getMessageByLocalId
    throw UnimplementedError();
  }

  @override
  Future<String> getMessageInfo() {
    // TODO: implement getMessageInfo
    throw UnimplementedError();
  }

  @override
  Future<List<MessageStatus>> getMessageStatuses() {
    // TODO: implement getMessageStatuses
    throw UnimplementedError();
  }

  @override
  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id) {
    // TODO: implement getMessageStatusesByMessageId
    throw UnimplementedError();
  }

  @override
  Future<Map<int, MessageData>> getMessages() {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Future<List<MessageData>> getMessagesByDialog(int dialogId) {
    // TODO: implement getMessagesByDialog
    throw UnimplementedError();
  }

  @override
  Future<UserProfileData> getProfile() {
    // TODO: implement getProfile
    throw UnimplementedError();
  }

  @override
  Future<String> getSipContacts() {
    // TODO: implement getSipContacts
    throw UnimplementedError();
  }

  @override
  Future<String?> getToken() {
    // TODO: implement getToken
    throw UnimplementedError();
  }

  @override
  Future<int?> getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }

  @override
  Future<Map<int, UserModel>> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  Future<int> initAppSettings() {
    // TODO: implement initAppSettings
    throw UnimplementedError();
  }



  @override
  Future initializeChatTypeValues() {
    // TODO: implement initializeChatTypeValues
    throw UnimplementedError();
  }

  @override
  Future<List<Object>> readChatTypes() {
    // TODO: implement readChatTypes
    throw UnimplementedError();
  }

  @override
  Future saveAttachments(List<MessageAttachmentData> files) {
    // TODO: implement saveAttachments
    throw UnimplementedError();
  }

  @override
  Future<void> saveChatUsers(List<ChatUser> chatUsers) {
    // TODO: implement saveChatUsers
    throw UnimplementedError();
  }

  @override
  Future<void> saveDialogs(List<DialogData> dialogs) {
    // TODO: implement saveDialogs
    throw UnimplementedError();
  }

  @override
  Future<int> saveLocalMessage(MessageData message) {
    // TODO: implement saveLocalMessage
    throw UnimplementedError();
  }

  @override
  Future<int?> saveLocalMessageStatus(MessageStatus? status) {
    // TODO: implement saveLocalMessageStatus
    throw UnimplementedError();
  }

  @override
  Future<Object?> saveMessageStatus(MessageStatus status) {
    // TODO: implement saveMessageStatus
    throw UnimplementedError();
  }

  @override
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses) {
    // TODO: implement saveMessageStatuses
    throw UnimplementedError();
  }

  @override
  Future<List<Object?>> saveMessages(List<MessageData> messages) {
    // TODO: implement saveMessages
    throw UnimplementedError();
  }

  @override
  Future<bool> saveUserProfile(UserProfileData profile) {
    // TODO: implement saveUserProfile
    throw UnimplementedError();
  }

  @override
  Future<void> saveUsers(List<UserModel> users) {
    // TODO: implement saveUsers
    throw UnimplementedError();
  }

  @override
  Future<int> setDeviceId(String deviceId) {
    // TODO: implement setDeviceId
    throw UnimplementedError();
  }

  @override
  Future<int> setLastUpdateTime() {
    // TODO: implement setLastUpdateTime
    throw UnimplementedError();
  }

  @override
  Future<int> setSipContacts(String contacts) {
    // TODO: implement setSipContacts
    throw UnimplementedError();
  }

  @override
  Future<int> setToken(String token) {
    // TODO: implement setToken
    throw UnimplementedError();
  }

  @override
  Future<int> setUserId(int userId) {
    // TODO: implement setUserId
    throw UnimplementedError();
  }

  @override
  Future<int> updateAppSettingsTable({int? dbInitialized, String? deviceId}) {
    // TODO: implement updateAppSettingsTable
    throw UnimplementedError();
  }

  @override
  Future<int> updateBooleanAppSettingByFieldAndValue(String field, int value) {
    // TODO: implement updateBooleanAppSettingByFieldAndValue
    throw UnimplementedError();
  }

  @override
  Future<int> updateDialogLastMessage(MessageData message) {
    // TODO: implement updateDialogLastMessage
    throw UnimplementedError();
  }

  @override
  Future<int> updateDialogLastPage(int dialogId, int page) {
    // TODO: implement updateDialogLastPage
    throw UnimplementedError();
  }

  @override
  Future<int> updateFilePath(int id, String path) {
    // TODO: implement updateFilePath
    throw UnimplementedError();
  }

  @override
  Future<List?> updateLocalMessage(MessageData message) {
    // TODO: implement updateLocalMessage
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageErrorStatusOnResend(String localMessageId) {
    // TODO: implement updateMessageErrorStatusOnResend
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageId(int localMessageId, int messageId) {
    // TODO: implement updateMessageId
    throw UnimplementedError();
  }

  @override
  Future<int> updateMessageWithSendFailed(int localMessageId) {
    // TODO: implement updateMessageWithSendFailed
    throw UnimplementedError();
  }

  @override
  Future updateMessagesThatFailedToBeSent() {
    // TODO: implement updateMessagesThatFailedToBeSent
    throw UnimplementedError();
  }

}