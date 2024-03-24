import '../../models/dialog_model.dart';
import 'dialogs_api_provider.dart';


class DialogsRepository {
  final DialogsProvider provider;

  const DialogsRepository({required this.provider});

  Future<List<DialogData>> getDialogs() => provider.getDialogs();
  Future<List<DialogData>> getPublicDialogs() => provider.getPublicDialogs();
  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic}) => provider.createDialog(chatType: chatType, users: users, chatName: chatName, chatDescription: chatDescription, isPublic: isPublic);
  Future<ChatUser> joinDialog({required int userId, required int dialogId}) => provider.joinDialog(userId, dialogId);
  Future<void> exitDialog({required int userId, required int dialogId}) => provider.exitDialog(userId, dialogId);
}