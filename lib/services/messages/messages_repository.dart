import 'package:chat/models/message_model.dart';
import 'package:chat/services/messages/messages_api_provider.dart';

class MessagesRepository  {
  MessagesProvider messagesProvider = MessagesProvider();

  Future <List<MessageData>> getMessages(userId, dialogId, pageNumber) => messagesProvider.getMessages(userId, dialogId, pageNumber);
  Future <Map<String, dynamic>?> getNewUpdatesOnResume(userId, dialogId, pageNumber) => messagesProvider.getNewUpdatesOnResume();
  Future <String?> sendMessage({required dialogId, required messageText, required parentMessageId}) => messagesProvider.sendMessage(dialogId: dialogId, messageText: messageText, parentMessageId: parentMessageId);
  Future <String> sendMessageWithFileBase64({required dialogId, required messageText, required file, required filetype, required parentMessageId}) => messagesProvider.sendMessageWithFileBase64(dialogId: dialogId, messageText: messageText, filePath: file, filetype: filetype, parentMessageId: parentMessageId);
  Future <bool> deleteMessage({required userId, required messageId}) => messagesProvider.deleteMessage(messageId: messageId);
  Future <void> updateMessageStatuses({required dialogId}) => messagesProvider.updateMessageStatuses(dialogId: dialogId);
  Future <int?> createDialogAndSendMessage({required userId, required partnerId, required message}) => messagesProvider.createDialogAndSendMessage(userId: userId, partnerId: partnerId, message: message);
  Future <MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) => messagesProvider.loadAttachmentData(attachmentId: attachmentId);

  // Future <String> sendMessageWithImageFile({required dialogId, required messageText, required file, required filetype, required parentMessageId}) => messagesProvider.sendMessageWithImageFileBase64(dialogId: dialogId, messageText: messageText, file: file, filetype: filetype, parentMessageId: parentMessageId);
}