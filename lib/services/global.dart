import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/storage/sqflite_database.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../bloc/ws_bloc/ws_bloc.dart';
import '../bloc/ws_bloc/ws_event.dart';
import '../models/dialog_model.dart';
import '../models/message_model.dart';
import '../ui/navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'package:chat/models/message_model.dart' as parseTime;
import '../view_models/chats_builder_view/chat_view_cubit.dart';
import 'messages/messages_repository.dart';
import 'package:universal_html/html.dart' as html;

AudioPlayer _player = AudioPlayer();

Future<void> playAudio(
    {required AudioPlayer player, required AudioSource source}) async {
  if (_player != null && _player.playing) {
    await _player.stop();
  }
  _player = player;
  player.setAudioSource(source);
  return player.play();
}

Future<void> pauseAudio() async {
  if (_player != null && _player.playing) {
    return _player.pause();
  }
}

const String noAppToOpenFileMessage =
    "Нет приложения, чтобы отрыть данный файл. Установите приложение и попробуйте снова";

const sipChannel = MethodChannel("com.application.chat/sip");
Future<void> callNumber(BuildContext context, String userId) async {
  print("OUTGOING CALL NUMBER");
  await sipChannel.invokeMethod(
      "OUTGOING_CALL", {"number": "sip:${userId}@aster.mcfef.com"});
}

Future<void> declineCall() async {
  await sipChannel.invokeMethod("DECLINE_CALL");
}

Future<void> acceptCall() async {
  await sipChannel.invokeMethod("ACCEPT_CALL");
}

Future<bool> toggleMute() async {
  final result = await sipChannel.invokeMethod("TOGGLE_MUTE");
  print("TOOGLE_RESULT     $result");
  return result;
}

Future<bool> toggleSpeaker() async {
  final result = await sipChannel.invokeMethod("TOGGLE_SPEAKER");
  print("TOOGLE_RESULT     $result");
  return result;
}

void logoutHelper(BuildContext context) {
  BlocProvider.of<AuthViewCubit>(context).logout(context);
  Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.auth);
}

Duration? TZ;
Duration getTZ() {
  if (TZ != null) return TZ!;
  TZ = DateTime.now().timeZoneOffset;
  return TZ!;
}

SqfliteDatabase? _db;
SqfliteDatabase getSqfliteDatabase() {
  if (_db != null) return _db!;
  _db = SqfliteDatabase();
  _db!.initDb();
  return _db!;
}

String getAudioMessageDuration(int seconds) {
  var minutes = "${(seconds / 60).floor()}";
  var secondsS = seconds % 60 >= 10
      ? "${(seconds % 60).floor()}"
      : "0${(seconds % 60).floor()}";
  return minutes + " : " + secondsS;
}

sendMessageWithPayload(
    {required BuildContext context,
    required String? messageText,
    required String filetype,
    required int? dialogId,
    required File file,
    required parentMessageId}) async {
  if (dialogId == null) {}
  showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.black54,
      context: context,
      builder: (BuildContext context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(
                height: 30,
              ),
              Text(
                "Отправка",
                style: TextStyle(color: Colors.white, fontSize: 24),
              )
            ],
          ));
  try {
    //TODO: implement local message beind added first
    // TODO: if response status code is 200 else ..
    print("parentMessageId  $parentMessageId");
    final sentMessage = await MessagesRepository().sendMessageWithFile(
        dialogId: dialogId,
        messageText: messageText,
        file: file,
        filetype: filetype,
        parentMessageId: parentMessageId);
    final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
    BlocProvider.of<ChatsBuilderBloc>(context)
        .add(ChatsBuilderAddMessageEvent(message: message, dialog: dialogId!));
  } catch (err) {
    print(err);
  }
  BlocProvider.of<ChatsBuilderBloc>(context)
      .add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
  // TODO: Can be refactored to named route
  Navigator.pop(context);
  Navigator.pop(context);
  Navigator.pop(context);
}

loadingInProgressModalWidget(BuildContext context, String message) {
  showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.black54,
      context: context,
      builder: (BuildContext context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 30,
              ),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              )
            ],
          ));
}

customToastMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

MessageData createLocalMessage({
  required replyedMessageId,
  required parentMessage,
  required userId,
  required dialogId,
  required messageText,
}) =>
    MessageData(
      messageId: Random().nextInt(100000),
      parentMessageId: replyedMessageId,
      parentMessage: parentMessage,
      senderId: userId,
      dialogId: dialogId,
      message: messageText,
      messageDate: parseTime.getDate(DateTime.now()),
      messageTime: parseTime.getTime(DateTime.now()),
      rawDate: DateTime.now(),
      file: null,
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

loadFileAndSaveLocally({required String fileName, required attachmentId}) async {
  final Directory documentDirectory = await getApplicationDocumentsDirectory();
  final String path = documentDirectory.path;
  final File file = File('$path/$fileName');

  if (await file.exists()) {
    print("file exists");
    return file;
  } else {
    print("file not exists");
    final fileData = await MessagesRepository().loadAttachmentData(
        attachmentId: attachmentId.toString());
    if (fileData == null)
      return null; //TODO: implement this method with desired workflow
    final bytes = base64Decode(fileData.content!);
    await file.writeAsBytes(bytes);
    return file;
  }
}

Future<File?> isLocalFileExist({required String fileName}) async {
  final Directory documentDirectory = await getApplicationDocumentsDirectory();
  final String path = documentDirectory.path;
  final File file = File('$path/$fileName');

  if (await file.exists()) {
    return file;
  }
  return null;
}

webPlatformSaveFile({required bytes, required filename}) async {

  if(kIsWeb) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = '$filename';
    html.document.body?.children.add(anchor);

    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else {
    throw Exception("Should be called on web only");
  }
}

refreshAllData(BuildContext context){
  BlocProvider.of<DialogsViewCubit>(context).refreshAllDialogs();
  BlocProvider.of<ChatsBuilderBloc>(context).add(RefreshChatsBuilderEvent());
  // BlocProvider.of<WsBloc>(context).add(WsEventDisconnect());
}

getMonthRussianName(int month){
  switch(month){
    case 1:
      return "января";
    case 2:
      return "февраля";
    case 3:
      return "марта";
    case 4:
      return "апреля";
    case 5:
      return "мая";
    case 6:
      return "июня";
    case 7:
      return "июля";
    case 8:
      return "августа";
    case 9:
      return "сентября";
    case 10:
      return "октября";
    case 11:
      return "ноября";
    case 12:
      return "декабря";
  }
}

DialogData? findDialog(BuildContext context, int userId, int partnerId){
  print('findDialog    $userId, $partnerId');
  // TODO: Another way to find a dialog is to send request to create a dialog.
  // If dialog exists it would return this dialog or create a new one and return it.
  final Iterator<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogs?.iterator;
  if (dialogs == null) return null;

  while(dialogs.moveNext()) {
    print("current dialog findDialog ${dialogs.current} ");
    if (dialogs.current.usersList.first.id == userId &&
        dialogs.current.usersList.last.id == partnerId &&
        dialogs.current.chatType.p2p == 1 ||
        dialogs.current.usersList.first.id == partnerId &&
            dialogs.current.usersList.last.id == userId &&
            dialogs.current.chatType.p2p == 1 ) {
      return dialogs.current;
    }
  }
  return null;
}