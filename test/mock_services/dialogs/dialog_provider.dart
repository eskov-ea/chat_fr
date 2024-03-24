import 'dart:convert';

import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import '../../mock_data/dialogs.dart';

class MockDialogsProvider implements DialogsProvider {
  @override
  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic}) {
    // TODO: implement createDialog
    throw UnimplementedError();
  }

  @override
  Future<void> exitDialog(userId, dialogId) {
    // TODO: implement exitDialog
    throw UnimplementedError();
  }

  @override
  Future<List<DialogData>> getDialogs() {
    return Future(() => jsonDecode(mockDialogsJson)["data"].map((json) => DialogData.fromDBJson(json)).toList());
  }

  @override
  Future<List<DialogData>> getPublicDialogs() {
    // TODO: implement getPublicDialogs
    throw UnimplementedError();
  }

  @override
  Future<ChatUser> joinDialog(userId, dialogId) {
    // TODO: implement joinDialog
    throw UnimplementedError();
  }

}


