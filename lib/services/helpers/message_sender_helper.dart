import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../bloc/chats_builder_bloc/chats_builder_state.dart';
import '../../models/message_model.dart';
import '../../view_models/dialogs_page/dialogs_view_cubit.dart';
import '../dialogs/dialogs_api_provider.dart';
import '../global.dart';
import '../messages/messages_repository.dart';
import 'package:chat/models/message_model.dart' as parseTime;


sendMessageUnix({
  required ChatsBuilderBloc bloc,
  required String? messageText,
  required File? file,
  required int dialogId,
  required int userId,
  required ParentMessage? parentMessage
}) async {

// 0. Process file if it is
  Uint8List? bytes;
  String? filename;
  String? filetype;
  String? base64FileString;
  MessageData? localMessage;
  try {
    if (file != null) {
    bytes = file.readAsBytesSync();
    filename = file.path.split('/').last.split('.').first;
    filetype = file.path.split('.').last;
    base64FileString = base64Encode(bytes);
    print("saving file is  ${file.path}  $filename  /  $filetype");
  }
// 1. Create local message
    localMessage = createLocalMessage(replyedMessageId: parentMessage?.parentMessageId, dialogId: dialogId, userId: userId,
      messageText: messageText, parentMessage: parentMessage, filename: filename, filetype: filetype, content: base64FileString);
// 2. Add local message to tray
    bloc.add(
      ChatsBuilderAddMessageEvent(message: localMessage, dialogId: dialogId));
// 3. Send message
      final response = await MessagesRepository().sendMessage(
        dialogId: dialogId,
        messageText: messageText,
        parentMessageId: parentMessage?.parentMessageId,
        filetype: filetype,
        bytes: bytes,
        filename: filename,
        content: base64FileString
      );
// 4. If no error - update last dialog message
    final message = MessageData.fromJson(jsonDecode(response)["data"]);
    bloc.add(
      ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: dialogId, localMessageId: localMessage.messageId)
    );
  } catch (err) {
// 5. Handle error - update last message with error
    if (localMessage != null) {
      print("ChatsBuilderUpdateMessageWithErrorEvent");
      bloc.add(ChatsBuilderUpdateMessageWithErrorEvent(message: localMessage, dialog: dialogId));
    }
  }
// 6. Update message statuses
  bloc.add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId));
}

MessageData createLocalMessage({
  required replyedMessageId,
  required parentMessage,
  required userId,
  required dialogId,
  required messageText,
  required String? filename,
  required String? filetype,
  required String? content
}) {
  MessageAttachmentsData? file;
  final r = Random().nextInt(100000);
  final int _id = int.parse("000$r");
  if (filename != null && filetype != null && content != null) {
    file = MessageAttachmentsData(
        attachmentId: _id,
        chatMessageId: _id,
        name: "$filename.$filetype",
        filetype: filetype,
        preview: "",
        content: content
    );
  }

  return MessageData(
    messageId: _id,
    parentMessageId: replyedMessageId,
    parentMessage: parentMessage,
    senderId: userId,
    dialogId: dialogId,
    message: messageText,
    messageDate: parseTime.getDate(DateTime.now()),
    messageTime: parseTime.getTime(DateTime.now()),
    rawDate: DateTime.now(),
    file: file,
    isError: false,
    status: [
      MessageStatuses(
          id: 0,
          userId: userId,
          statusId: 0,
          messageId: 0,
          dialogId: dialogId!,
          createdAt: DateTime.now().toString())
    ],
  );
}


// messageSenderSendMissCallMessage({
//   required BuildContext context,
//   required int userId,
//   required int? dialogId,
//
// }) async {
//   try {
//       final messageText = "Пропущенный звонок";
//       final localMessage = createLocalMessage(replyedMessageId: null, parentMessage: null, userId: userId, dialogId: dialogId, messageText: messageText);
//       print("localMessage  $localMessage");
//       BlocProvider.of<ChatsBuilderBloc>(context).add(
//           ChatsBuilderAddMessageEvent(message: localMessage, dialog: dialogId!)
//       );
//       // TODO: if response status code is 200 else ..
//       final sentMessage = await MessagesRepository().sendMessage(dialogId: dialogId!, messageText: messageText, parentMessageId: null, filetype: null, filePath: null);
//       print("sentMessage  $sentMessage");
//       if (sentMessage == null) {
//         customToastMessage(context, "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
//         return;
//       }
//       final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
//       BlocProvider.of<ChatsBuilderBloc>(context).add(
//           ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: dialogId!, localMessageId: localMessage.messageId)
//       );
//       BlocProvider.of<DialogsViewCubit>(context).updateLastDialogMessage(localMessage);
//     } catch (err) {
//       print("_sendMessage error $err");
//     }
//     BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
// }
//
createDialog({
  required ChatsBuilderBloc chatsBuilderBloc,
  required int partnerId
}) async {
    final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [partnerId], chatName: "p2p", chatDescription: null, isPublic: false);
    print("SENDING_PUSH   ${newDialog?.dialogId}");
    if (newDialog != null) {
      final initLength = chatsBuilderBloc.state.chats.length;
      whenFinishAddingDialog(Stream<ChatsBuilderState> source) async {
        chatsBuilderBloc.add(ChatsBuilderLoadMessagesEvent(dialogId: newDialog.dialogId));
        await for (var value in source) {
          if (value.chats.length > initLength) {
            return;
          }
        }
      }
      await whenFinishAddingDialog(chatsBuilderBloc.stream);
      return newDialog.dialogId;
    }
}

void resendErroredMessage({
  required int messageId,
  required int dialogId,
  required int userId,
  required BuildContext context,
  required String messageText,
  required ParentMessage? parentMessage,
  required int? repliedMessageId
}) async {
  final localMessage = createLocalMessage(
      dialogId: dialogId,
      messageText: messageText,
      parentMessage: parentMessage,
      replyedMessageId: repliedMessageId,
      userId: userId, filename: null, filetype: null, content: null
  );
  BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderDeleteLocalMessageEvent(dialogId: dialogId, messageId: messageId));
  Navigator.of(context).pop();
  try {
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderAddMessageEvent(message: localMessage, dialogId: dialogId));
    // TODO: if response status code is 200 else ..
    final sentMessage = await MessagesRepository().sendMessage(
        dialogId: dialogId,
        messageText: messageText,
        parentMessageId: repliedMessageId,
        filetype: null,
        bytes: null,
        filename: null,
        content: null
    );
    print("sentMessage response  $sentMessage");
    if (sentMessage == null) {
      customToastMessage(context: context, message: "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
      return;
    }
    final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderUpdateLocalMessageEvent(
            message: message,
            dialogId: dialogId,
            localMessageId: localMessage.messageId));
    BlocProvider.of<DialogsViewCubit>(context)
        .updateLastDialogMessage(localMessage);
    print("RESULT IS  $sentMessage ${BlocProvider.of<ChatsBuilderBloc>(context)}");
  } catch (err) {
    print("ERRRRRRRRROR  $err ");
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderUpdateMessageWithErrorEvent(message: localMessage, dialog: dialogId)
    );
  }
}



