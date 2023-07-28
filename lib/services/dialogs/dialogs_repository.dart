import '../../models/dialog_model.dart';
import 'dialogs_api_provider.dart';


abstract class IDialogRepository {
  Future<List<DialogData>> getDialogs();
  Future<List<DialogData>> getPublicDialogs();
  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic});
  Future<ChatUser> joinDialog({required int userId, required int dialogId});
  Future<void> exitDialog({required int userId, required int dialogId});
}

class DialogRepository implements IDialogRepository {
  final DialogsProvider _dialogsProvider = DialogsProvider();

  Future<List<DialogData>> getDialogs() => _dialogsProvider.getDialogs();
  Future<List<DialogData>> getPublicDialogs() => _dialogsProvider.getPublicDialogs();
  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic}) => _dialogsProvider.createDialog(chatType: chatType, users: users, chatName: chatName, chatDescription: chatDescription, isPublic: isPublic);
  Future<ChatUser> joinDialog({required int userId, required int dialogId}) => _dialogsProvider.joinDialog(userId, dialogId);
  Future<void> exitDialog({required int userId, required int dialogId}) => _dialogsProvider.exitDialog(userId, dialogId);
}