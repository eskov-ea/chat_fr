import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class IDBProvider {


  Future<Database> get database;
  Future<Database> initDB();

  /// CHAT TYPE DB LAYER
  Future initializeChatTypeValues();
  Future<List<Object>> readChatTypes();


  ///   DIALOGS LAYER
  Future<void> saveDialogs(List<DialogData> dialogs);
  Future<List<DialogData>> getDialogs();
  Future<int> updateDialogLastPage(int dialogId, int page);
  Future<int?> getLastDialogPage(int dialogId);
  Future<int> updateDialogLastMessage(MessageData message);
  Future<List<DialogData>> getDialogById(int id);


  ///   MESSAGES LAYER
  Future<List<Object?>> saveMessages(List<MessageData> messages);
  Future<Map<int, MessageData>> getMessages();
  Future<List<MessageData>> getMessagesByDialog(int dialogId);
  Future<String> getMessageInfo();
  Future<int> saveLocalMessage(MessageData message);
  Future<int> updateMessageWithSendFailed(String localMessageId);
  Future<int> updateMessageId(int localMessageId, int messageId);
  Future<MessageData?> getMessageByLocalId(String localId);
  Future<List?> updateLocalMessage(MessageData message);
  Future<int> checkIfMessageExistWithThisId(int id);
  Future updateMessagesThatFailedToBeSent();
  Future<int> updateMessageErrorStatusOnResend(String localMessageId);
  Future<int> deleteMessages(List<int> ids);
  Future<int> getLastId();
  Future<int> deleteNotSentMessagesOlder5days();


  ///   MESSAGE STATUS LAYER
  Future<List<Object?>> saveMessageStatuses(List<MessageStatus> statuses);
  Future<Object?> saveMessageStatus(MessageStatus status);
  Future<List<MessageStatus>> getMessageStatuses();
  Future<int?> saveLocalMessageStatus(MessageStatus? status);
  Future<List<MessageStatus>> getMessageStatusesByMessageId(int id);


  ///   MESSAGE ATTACHMENTS LAYER
  Future saveAttachments(List<MessageAttachmentData> files);
  Future<List<MessageAttachmentData>> getAttachments();
  Future<MessageAttachmentData> getAttachmentById(int id);
  Future<int> updateFilePath(int id, String path);


  ///   USERS LAYER
  Future<void> saveUsers(List<UserModel> users);
  Future<Map<int, UserModel>> getUsers();


  ///   CHAT USERS LAYER
  Future<void> saveChatUsers(List<ChatUser> chatUsers);
  Future<Map<int, List<ChatUser>>> getChatUsers();
  Future<int> deleteChatUser(ChatUser chatUser);
  Future<int> addUserToChat(ChatUser chatUser);
  Future<List<ChatUser>> getChatUsersByDialogId(int dialogId);


  ///   USER PROFILE LAYER
  Future<bool> saveUserProfile(UserProfileData profile);
  Future<UserProfileData> getProfile();


  /// APP STATE DB LAYER
  Future<String> getLastUpdateTime();
  Future<int> setLastUpdateTime();
  Future<String?> getToken();
  Future<int?> getUserId();
  Future<String> getDeviceId();
  Future<int> setToken(String token);
  Future<int> setUserId(int userId);
  Future<String> getSipContacts();
  Future<int> setSipContacts(String contacts);
  Future<int> setDeviceId(String deviceId);
  Future<AppSettings> getAppSettings();
  Future<int> initAppSettings();
  Future<int> updateBooleanAppSettingByFieldAndValue(String field, int value);


  ///   DB DEVELOPER SERVICE
  Future<List<Object>> checkExistingTables();
  Future deleteDBFile();


  ///   HELPER FUNCTIONS
  Future<void> createTables(Database db);
  Future<bool> checkIfDatabaseIsEmpty();
  Future<bool> deleteAllDataOnLogout();
  Future<int> updateAppSettingsTable({int? dbInitialized, String? deviceId});
  Future<int> configAppValues(Database db);
  Future<void> DeveloperModeClearPersonTable();



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




