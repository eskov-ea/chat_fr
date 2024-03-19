import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/helpers/message_forwarding_util.dart';
import 'package:chat/services/logger/logger_service.dart';
import '../../models/message_model.dart';
import '../dialogs/dialogs_api_provider.dart';
import '../global.dart';
import '../messages/messages_repository.dart';
import 'package:chat/models/message_model.dart' as parseTime;



// sendForwardMessage({
//   required MessageBloc bloc,
//   required String? messageText,
//   required MessageAttachmentData? attachment,
//   required int dialogId,
//   required int userId
// }) async {
//
//   String? filename;
//   String? filetype;
//   String? base64FileString;
//   MessageData? localMessage;
//   String? path;
//   if (attachment != null) {
//     filename = attachment.name.split('.').first;
//     filetype = attachment.name.split('.').last;
//     final file = await loadFileAndSaveLocally(fileName: attachment.name, attachmentId: attachment.attachmentId);
//     if (file != null) {
//       final bytes = file.readAsBytesSync();
//       base64FileString = base64Encode(bytes);
//     }
//   }
//   try {
// // 1. Create local message
//     localMessage = createLocalMessage(dialogId: dialogId, userId: userId, path: path,
//         messageText: messageText, parentMessage: null, filename: filename, filetype: attachment?.filetype, content: base64FileString, messageId: 12345, attachmentId: null);
// // 2. Add local message to tray
//     //TODO: refacrot messageBloc
//     // bloc.add(
//     //     ChatsBuilderAddMessageEvent(message: localMessage, dialogId: dialogId));
// // 3. Send message
//     final response = await MessagesRepository().forwardMessage(
//         dialogId: dialogId,
//         messageText: messageText,
//         filetype: filetype,
//         filename: filename,
//         preview: attachment?.preview,
//         content: base64FileString
//     );
//     print("FORWARD:: forwardMessage 3 ${response}");
//
// // 4. If no error - update last dialog message
//     final message = MessageData.fromJson(jsonDecode(response)["data"]);
//     //TODO: refacrot messageBloc
//     // bloc.add(
//     //     ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: dialogId, localMessageId: localMessage.messageId)
//     // );
//   } catch (err, stackTrace) {
// // 5. Handle error - update last message with error
//     Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Failed send a message");
//     if (localMessage != null) {
//       //TODO: refacrot messageBloc
//       // bloc.add(ChatsBuilderUpdateMessageWithErrorEvent(messageId: localMessage.messageId, dialog: dialogId));
//     }
//   }
// // 6. Update message statuses
//   //TODO: refacrot messageBloc
//   // bloc.add(MessageBlocUpdateStatusMessagesEvent(dialogId: dialogId));
// }

MessageData createLocalMessage({
  required RepliedMessage? parentMessage,
  required int userId,
  required int messageId,
  required int? attachmentId,
  required int dialogId,
  required String? messageText,
  required String? filename,
  required String? filetype,
  required String? path,
  required String? content
}) {
  MessageAttachmentData? file;
  if (filename != null && filetype != null && content != null && attachmentId != null) {
    file = MessageAttachmentData(
        attachmentId: attachmentId,
        chatMessageId: messageId,
        name: "$filename.$filetype",
        filetype: filetype,
        preview: "",
        createdAt: DateTime.now().toString(),
        path: path,
        content: content
    );
  }

  return MessageData(
    messageId: messageId,
    repliedMessage: parentMessage,
    senderId: userId,
    dialogId: dialogId,
    message: replaceForwardSymbol(messageText ?? ''),
    messageDate: parseTime.getDate(DateTime.now()),
    messageTime: parseTime.getTime(DateTime.now()),
    rawDate: DateTime.now(),
    file: file,
    isError: 0,
    localId: generateUUID(),
    statuses: [],
    forwarderFromUser: getForwardedMessageStatus(messageText ?? ''),
  );
}


createDialog({
  required MessageBloc chatsBuilderBloc,
  required int partnerId
}) async {
    final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [partnerId], chatName: "p2p", chatDescription: null, isPublic: false);
    if (newDialog != null) {
      //TODO: refacrot messageBloc
      // final initLength = chatsBuilderBloc.state.chats.length;
      // whenFinishAddingDialog(Stream<MessagesBlocState> source) async {
      //   chatsBuilderBloc.add(ChatsBuilderLoadMessagesEvent(dialogId: newDialog.dialogId));
      //   await for (var value in source) {
      //     if (value.chats.length > initLength) {
      //       return;
      //     }
      //   }
      // }
      // await whenFinishAddingDialog(chatsBuilderBloc.stream);
      return newDialog.dialogId;
    }
}

void resendErrorMessage({
  required int messageId,
  required int dialogId,
  required int userId,
  required MessageBloc bloc,
  required String? uuid,
  required MessageAttachmentData? file,
  required String messageText,
  required RepliedMessage? parentMessage,
  required int? repliedMessageId
}) async {
  //TODO: refacrot messageBloc
  // bloc.add(ChatsBuilderUpdateMessageWithErrorEvent(messageId: messageId, dialog: dialogId, isHandling: true));
  try {
    await Future.delayed(Duration(seconds: 2));
    final sentMessage = await MessagesRepository().sendMessage(
        dialogId: dialogId,
        uuid: uuid,
        messageText: messageText,
        parentMessageId: repliedMessageId,
        filetype: file?.filetype,
        bytes: file?.content != null ? base64Decode(file!.content!) : null,
        filename: file?.name,
        content: file?.content
    );
    final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
    //TODO: refacrot messageBloc
    // bloc.add(
    //     ChatsBuilderUpdateLocalMessageEvent(
    //         message: message,
    //         dialogId: dialogId,
    //         localMessageId: messageId));
  } catch (err, stackTrace) {
    Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Failed send a message");
    //TODO: refacrot messageBloc
    // bloc.add(
    //     ChatsBuilderUpdateMessageWithErrorEvent(messageId: messageId, dialog: dialogId)
    // );
  }
}

Future<int> UUID() async {
  final lastId = await DBProvider.db.getLastId();
  final r = Random().nextInt(20000000);
  return lastId + r;
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