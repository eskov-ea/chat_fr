import 'dart:typed_data';

import 'messages_api_provider.dart';


const List<String> GraphicTypes = ["png", "jpeg", "jpg", "pdf"];
const List<String> AudioTypes = ["mp3", "mp4"];
const List<String> DocumentTypes = [];


class MessageHelper {
  final MessagesProvider messagesProvider = MessagesProvider();

  Future<String> sendMessage({
    required Uint8List? bytes,
    required String? messageText,
    required String? filename,
    required int? parentMessageId,
    required int dialogId,
    required String? filetype,
    required String? content
  }) {
    if (GraphicTypes.contains(filetype)) {
      /** send message with attached image file */
      return messagesProvider.sendMessageWithFileBase64(dialogId: dialogId, messageText: messageText, filetype: filetype, parentMessageId: parentMessageId, filename: filename, bytes: bytes, content: content);
    } else if (AudioTypes.contains(filetype)) {
      /** send audio message  */
      return messagesProvider.sendAudioMessage(dialogId: dialogId, filetype: filetype, parentMessageId: parentMessageId, filename: filename, messageText: messageText, content: content);
    } else if (filetype != null && content != null) {
      /** we assume that message contains a file and the app does not process this type and we aim to save it to the device's disk */
      return messagesProvider.sendMessageWithFileBase64(dialogId: dialogId, messageText: messageText, filetype: filetype, parentMessageId: parentMessageId, filename: filename, bytes: bytes, content: content);
    } else {
      /** by default we send plain text message */
      return messagesProvider.sendTextMessage(dialogId: dialogId, messageText: messageText, parentMessageId: parentMessageId);
    }
  }
}