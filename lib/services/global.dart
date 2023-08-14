import 'dart:convert';
import 'dart:io';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../models/dialog_model.dart';
import '../ui/navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'messages/messages_repository.dart';

  AudioPlayer _player = AudioPlayer();
  Duration? TZ;

  class SipConfig {
    static String? sipDomain = null;
    static String? sipPrefix = null;

    static final String defaultSipPrefix = "7";
    static final String defaultSipDomain = "sip.mcfef.com";


    static String getDomain() =>  sipDomain ?? defaultSipDomain;
    static String getPrefix() =>  sipPrefix ?? defaultSipPrefix;
  }

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
        "OUTGOING_CALL", {"number": "sip:${SipConfig.getPrefix()}${userId}@${SipConfig.getDomain()}"});
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

  Duration getTZ() {
    if (TZ != null) return TZ!;
    TZ = DateTime.now().timeZoneOffset;
    return TZ!;
  }

// SqfliteDatabase? _db;
// SqfliteDatabase getSqfliteDatabase() {
//   if (_db != null) return _db!;
//   _db = SqfliteDatabase();
//   _db!.initDb();
//   return _db!;
// }

  String getAudioMessageDuration(int seconds) {
    var minutes = "${(seconds / 60).floor()}";
    var secondsS = seconds % 60 >= 10
        ? "${(seconds % 60).floor()}"
        : "0${(seconds % 60).floor()}";
    return minutes + " : " + secondsS;
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
            SizedBox(
              width: 30,
              height: 30,
              child: const CircularProgressIndicator()
            ),
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

  loadFileAndSaveLocally({required String fileName, required attachmentId}) async {
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    final File file = File('$path/$fileName');
    print("Documents directory is    $path");
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

  Future<File?> loadAndSaveLocallyUserAvatar({required int? userId}) async {
    if (userId == null) return null;
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    final File file = File('$path/avatar.$userId.jpg');

    if (await file.exists()) {
      print("Image status: read from disk");
      return file;
    } else {
      final UserProfileProvider userProfileProvider = UserProfileProvider();
      final String? data = await userProfileProvider.loadUserAvatar(userId!);
      if (data == null) return null;
      final bytes = base64Decode(data);
      await file.writeAsBytes(bytes);
      print("Image status: fetch from the Internet");
      return file;
    }
  }

  Future<File?> isLocalFileExist({required String fileName}) async {
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    final File file = File('$path/$fileName');
    print("isLocalFileExist   $path    //   $fileName");
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  webPlatformSaveFile({required bytes, required filename}) async {

    if(kIsWeb) {
      // final blob = html.Blob([bytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.document.createElement('a') as html.AnchorElement
      //   ..href = url
      //   ..style.display = 'none'
      //   ..download = '$filename';
      // html.document.body?.children.add(anchor);
      //
      // anchor.click();
      //
      // html.document.body?.children.remove(anchor);
      // html.Url.revokeObjectUrl(url);
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

  double _computeWidth(double width) {
    print("Width is:  $width");
    if (width < 500) {
      return width;
    } else {
      return 500 + ( width -500 ) * 0.5;
    }
  }

  double _computeTopPadding(double height) {
    if (height <= 900) {
      return 60;
    } else {
      return 60 + ( height -900 ) * 0.35;
    }
  }

  Widget CustomSizeContainer(Widget child, BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: _computeTopPadding(MediaQuery.of(context).size.height)),
        width: _computeWidth(MediaQuery.of(context).size.width),
        child: child,
      ),
    );
  }

  String dateFormater(DateTime rawDate) {
    final now = DateTime.now();
    final lastMidnight = DateTime(now.year, now.month,  now.day);
    final lastMonday = DateTime(now.year, now.month,  now.day - (now.weekday - 1));
    final diffTime = lastMidnight.millisecondsSinceEpoch - rawDate.millisecondsSinceEpoch;
    final todayDayRange = (now.millisecondsSinceEpoch - lastMidnight.millisecondsSinceEpoch) / 1000/60/60/24;
    final todayWeekRange = (now.millisecondsSinceEpoch - lastMonday.millisecondsSinceEpoch) / 1000/60/60/24;

  // get days since last midnight
  final days = diffTime / 1000 / 60 / 60 / 24;
  if (days <= todayDayRange) {
    return DateFormat.Hm().format(rawDate.add(getTZ()));
    // return DateFormat.Hm().format(rawDate.add(getTZ()));
  } else if ( days >= todayDayRange && days < 1) {
    return "Вчера";
  } else if ( days >= 1 && days < todayWeekRange) {
    return _toRussianWeekday(rawDate.weekday);
  } else {
    final date = DateFormat.yMd().format(rawDate).replaceAll(new RegExp('/'), '.');
    final splittedDate = date.split('.');
    final tmp = splittedDate[1];
    splittedDate[1] = splittedDate[0];
    splittedDate[0] = tmp;
    for (var i = 0; i < splittedDate.length; i++) {
      if (int.parse(splittedDate[i]) <= 9 ) {
        splittedDate[i] = "0${splittedDate[i]}";
      }
    }
    return splittedDate.join(".");
  }
}

String _toRussianWeekday (int day) {
  switch(day) {
    case 1: return "Воскресенье";
    case 2: return "Понедельник";
    case 3: return "Вторник";
    case 4: return "Среда";
    case 5: return "Четверг";
    case 6: return "Пятница";
    case 7: return "Суббота";
    default: return day.toString();

  }
}

bool isOnline(int id, Map<int, bool> onlineMembers) {
  if (onlineMembers[id] != null) return true;
  return false;
}
