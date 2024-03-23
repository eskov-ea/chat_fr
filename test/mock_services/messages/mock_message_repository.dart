import 'dart:convert';
import 'dart:typed_data';
import 'package:chat/models/chat_builder_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'mock_object.dart';


MessageData newMessage = MessageData.fromJson(jsonDecode(newMessageJson));
MessageData localMessage = MessageData.fromJson(jsonDecode(localMessageJson));
MessageData updatedLocalMessage = MessageData.fromJson(jsonDecode(updatedLocalMessageJson));
List<MessageStatus> newMessageStatus = MessageStatus.fromJson(jsonDecode(newStatus));

Map<String, bool> initialMessageDictionary() {
  final Map<String, bool> messagesDictionary = {};
  final List<MessageData> messages = MessageListJson.map((el) {
    return MessageData.fromJson(jsonDecode(el));
  }).toList();
  for (var message in messages) {
    messagesDictionary["${message.messageId}"] = true;
  }
  return messagesDictionary;
}

List<ChatsData> initialChats(){
  final List<ChatsData> chats = [];
  final List<MessageData> messages = MessageListJson.map((el) {
    return MessageData.fromJson(jsonDecode(el));
  }).toList();
  chats.add(ChatsData.makeChatsData(180, messages));
  return chats;
}

List<ChatsData> initialChatsWithNewStatus(List<ChatsData> chats, List<MessageStatus> statuses){
  for( var status in statuses) {
    for(var chat in chats) {
      if(chat.chatId == status.dialogId) {
        for(var message in chat.messages) {
          if(message.messageId == status.messageId) {
            message.statuses.add(status);
          }
        }
      }
    }
  }
  return chats;
}

List<ChatsData> initialChatsWithNewMessage(List<ChatsData> chats, MessageData message) {
  for (var chat in chats) {
    if(chat.chatId == message.dialogId) {
      chat.messages.insert(0, message);
    }
  }
  return chats;
}
Map<String, bool> initialMessageDictionaryWithNewMessage(Map<String, bool> dictionary, MessageData message) {
  dictionary[message.messageId.toString()] = true;
  return dictionary;
}

class MockMessageRepository implements MessagesRepository {
  @override
  MessagesProvider messagesProvider = MockMessageProvider();

  @override
  Future<int?> createDialogAndSendMessage({required userId, required partnerId, required message}) {
    // TODO: implement createDialogSendMessage
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteMessage({required userId, required messageId}) {
    // TODO: implement deleteMessage
    throw UnimplementedError();
  }

  @override
  Future<List<MessageData>> getMessages(userId, dialogId, pageNumber) {
    return messagesProvider.getMessages(userId, dialogId, pageNumber);
  }

  @override
  Future<Map<String, dynamic>?> getNewUpdatesOnResume(userId, dialogId, pageNumber) {
    // TODO: implement getNewMessagesOnResume
    throw UnimplementedError();
  }

  @override
  Future<MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) {
    // TODO: implement loadAttachmentData
    throw UnimplementedError();
  }

  

  @override
  Future<String> sendMessageWithFileBase64({required dialogId, required messageText, required file, required filetype, required parentMessageId}) {
    // TODO: implement sendMessageWithFile
    throw UnimplementedError();
  }

  @override
  Future<void> updateMessageStatuses({required dialogId}) {
    // TODO: implement updateMessageStatuses
    throw UnimplementedError();
  }

  @override
  Future<int?> createDialog({required userId, required partnerId, required message}) {
    // TODO: implement createDialog
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessage({required int dialogId, required String? messageText, required int? parentMessageId, required String? filetype, required Uint8List? bytes, required String? filename, required String? content}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

}

class MockMessageProvider implements MessagesProvider {
  @override
  Future<int?> createDialogAndSendMessage({required userId, required partnerId, required message}) {
    // TODO: implement createDialogAndSendMessage
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteMessage({required List<int> messageId}) {
    // TODO: implement deleteMessage
    throw UnimplementedError();
  }

  @override
  Future<List<MessageData>> getMessages(userId, dialogId, pageNumber) async {
    await Future.delayed(Duration(seconds: 1));
    return MessageListJson.map((el) {
      return MessageData.fromJson(jsonDecode(el));
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getNewUpdatesOnResume() {
    // TODO: implement getNewUpdatesOnResume
    throw UnimplementedError();
  }

  @override
  Future<MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) {
    // TODO: implement loadAttachmentData
    throw UnimplementedError();
  }

  @override
  Future<String?> sendMessage({required dialogId, required messageText, required parentMessageId}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<void> updateMessageStatuses({required int dialogId}) {
    // TODO: implement updateMessageStatuses
    throw UnimplementedError();
  }

  @override
  Future<int?> createDialog({required userId, required partnerId, required message}) {
    // TODO: implement createDialog
    throw UnimplementedError();
  }

  @override
  Future<String> sendAudioMessage({required String? filename, required int dialogId, required String? messageText, required String? filetype, required int? parentMessageId, required String? content}) {
    // TODO: implement sendAudioMessage
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessageWithFileBase64({required String? filename, required int dialogId, required String? messageText, required String? filetype, required int? parentMessageId, required Uint8List? bytes, required String? content}) {
    // TODO: implement sendMessageWithFileBase64
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessageWithFileBase64ForWeb({required String base64, required int dialogId, required String filetype, required int? parentMessageId, required Uint8List? bytes}) {
    // TODO: implement sendMessageWithFileBase64ForWeb
    throw UnimplementedError();
  }

  @override
  Future<String> sendTextMessage({required dialogId, required messageText, required parentMessageId}) {
    // TODO: implement sendTextMessage
    throw UnimplementedError();
  }

}