import 'dart:convert';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import '../messages/mock_object.dart';
import '../users/mock_objects.dart';
import 'mock_dialogs_objects.dart';


final DialogData newReceivedDialog = DialogData.fromJson(jsonDecode(mockReceivedDialog));
final List<DialogData> dialogs = mockDialogsJson.map((el) {
  return DialogData.fromJson(jsonDecode(el));
}).toList();
final List<DialogData> dialogsWithNewUser = mockDialogsWithNewChatUserJson.map((el) {
  return DialogData.fromJson(jsonDecode(el));
}).toList();
final List<DialogData> dialogsWithRemovedUser = mockDialogsWithRemovedChatUserJson.map((el) {
  return DialogData.fromJson(jsonDecode(el));
}).toList();
final List<DialogData> dialogsWithUpdatedLastMessage = dialogsWithUpdatedLastMessageJson.map((el) {
  return DialogData.fromJson(jsonDecode(el));
}).toList();
final List<DialogData> dialogsWithUpdatedMessageStatuses = mockDialogsWithUpdatedStatusOnlyJson.map((el) {
  return DialogData.fromJson(jsonDecode(el));
}).toList();
final List<MessageStatus> newMessageStatuses = MessageStatus.fromJson(jsonDecode(newStatus));

final ChatUser chatUser = ChatUser.fromJson(jsonDecode(mockChatUser));


class MockDialogsRepository  implements DialogRepository{
  @override
  Future<List<DialogData>> getDialogs() async {
    await Future.delayed(Duration(seconds: 1));
    return mockDialogsJson.map((el) {
      return DialogData.fromJson(jsonDecode(el));
    }).toList();
  }

  @override
  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic}) {
    // TODO: implement createDialog
    throw UnimplementedError();
  }

  @override
  Future<void> exitDialog({required int userId, required int dialogId}) {
    // TODO: implement exitDialog
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getPublicDialogs() {
    // TODO: implement getPublicDialogs
    throw UnimplementedError();
  }

  @override
  Future<ChatUser> joinDialog({required int userId, required int dialogId}) {
    // TODO: implement joinDialog
    throw UnimplementedError();
  }

}