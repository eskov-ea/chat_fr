import 'dart:typed_data';

import 'package:chat/models/message_model.dart';
import 'package:chat/services/messages/message_helper.dart';
import 'package:chat/services/messages/messages_api_provider.dart';


class MessagesRepository  {
  final MessagesProvider messagesProvider = MessagesProvider();
  final MessageHelper _messageHelper = MessageHelper();

  Future <List<MessageData>> getMessages(userId, dialogId, pageNumber) => messagesProvider.getMessages(userId, dialogId, pageNumber);
  Future <Map<String, dynamic>?> getNewUpdatesOnResume(userId, dialogId, pageNumber) => messagesProvider.getNewUpdatesOnResume();
  Future <bool> deleteMessage({required userId, required messageId}) => messagesProvider.deleteMessage(messageId: messageId);
  Future <void> updateMessageStatuses({required dialogId}) => messagesProvider.updateMessageStatuses(dialogId: dialogId);
  Future <MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) => messagesProvider.loadAttachmentData(attachmentId: attachmentId);
  Future <String> sendMessage({required int dialogId, required String? messageText, required int? parentMessageId, required String? filetype, required Uint8List? bytes, required String? filename, required String? content}) =>
      _messageHelper.sendMessage(bytes: bytes, messageText: messageText, parentMessageId: parentMessageId, dialogId: dialogId, filetype: filetype, filename: filename, content: content);
  Future <String> forwardMessage({required int dialogId, required String? messageText, required String? filetype, required String? preview, required String? filename, required String? content}) =>
      messagesProvider.forwardMessage(filename: filename, dialogId: dialogId, messageText: messageText, filetype: filetype, preview: preview, content: content);
}