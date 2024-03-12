import 'dart:convert';
import 'dart:developer';
// import 'dart:html' as html;
import 'dart:io';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/user_bloc/user_bloc.dart';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/dialog_model.dart';
import '../ui/navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'messages/messages_repository.dart';

  AudioPlayer _player = AudioPlayer();
  Duration? TZ;
  const MAX_WIDTH = 700.0;

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
    await sipChannel.invokeMethod(
        "OUTGOING_CALL", {"number": "sip:${SipConfig.getPrefix()}${userId}@${SipConfig.getDomain()}"});
  }

  void declineCall()  {
    print("CALL DECLINE:::  call method");
    sipChannel.invokeMethod("DECLINE_CALL");
  }

  Future<void> acceptCall() async {
    await sipChannel.invokeMethod("ACCEPT_CALL");
  }

  Future<bool> toggleMute() async {
    final result = await sipChannel.invokeMethod("TOGGLE_MUTE");
    return result;
  }

  Future<bool> toggleSpeaker() async {
    final result = await sipChannel.invokeMethod("TOGGLE_SPEAKER");
    return result;
  }

  void logoutHelper(BuildContext context) async {
    final db = DBProvider.db;
    final res = await db.deleteAllDataOnLogout();
    if (res) {
      BlocProvider.of<DialogsViewCubit>(context).deleteAllDialogs();
      BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLogoutEvent());
      WebsocketRepository.instance.disconnect();
      BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersDeleteUsersEvent());
      BlocProvider.of<CallLogsBloc>(context).add(DeleteCallsOnLogoutEvent());
      const sipChannel = MethodChannel("com.application.chat/sip");
      sipChannel.invokeMethod('SIP_LOGOUT');

      BlocProvider.of<AuthViewCubit>(context).logout(context);
    } else {
      customToastMessage(context: context, message: 'Произошла ошибка при выходе из аккаунта, попробуйте еще раз');
    }

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

  customToastMessage({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
    Icon? icon
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: RichText(
              text: TextSpan(
                  children: [
                    TextSpan(text: message),
                    if (icon != null) WidgetSpan(
                      child: icon,
                    ),
                  ]
              )
          ),
          action: action,
        ),
      );
    });
  }

  ///TODO: refactor to use bytes?
  Future<File?> loadFileAndSaveLocally({required String fileName, required attachmentId}) async {
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    final File file = File('$path/$fileName');

    if (await file.exists()) {
      return file;
    } else {
      final fileData = await MessagesRepository().loadAttachmentData(
          attachmentId: attachmentId.toString());
      if (fileData == null) {
        return null; //TODO: implement this method with desired workflow
      }
      final bytes = base64Decode(fileData.content!);
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  Future<String?> loadFileOnWebPlatform({required String fileName, required attachmentId}) async {
    final fileData = await MessagesRepository().loadAttachmentData(
        attachmentId: attachmentId.toString());
    if (fileData == null && fileData?.content == null) {
      return null;
    }
    return fileData!.content!;
  }

  Future<File?> loadAndSaveLocallyUserAvatar({required int? userId}) async {
    if (userId == null) return null;
    try {
      final Directory documentDirectory =
          await getApplicationDocumentsDirectory();
      final String path = documentDirectory.path;
      final File file = File('$path/avatar.$userId.jpg');

      if (await file.exists()) {
        return file;
      } else {
        final UserProfileProvider userProfileProvider = UserProfileProvider();
        final String? data = await userProfileProvider.loadUserAvatar(userId);
        if (data == null) return null;
        final bytes = base64Decode(data);
        await file.writeAsBytes(bytes);
        return file;
      }
  } catch(err, stackTrace) {
      return null;
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

  String getChatItemName(DialogData data, int? userId) {
    if (data.chatType.p2p == 1) {
      for (var i = 0; i < data.chatUsers.length; i++)  {
        if (data.chatUsers[i].userId != userId) {
          return "${data.chatUsers[i].user.lastname} ${data.chatUsers[i].user.firstname}";
        }
      }
    } else {
      return data.name;
    }
    return 'Корпоративный чат';
  }

  webPlatformSaveFile({required bytes, required filename}) async {

    // if(kIsWeb) {
    //   final blob = html.Blob([bytes]);
    //   final url = html.Url.createObjectUrlFromBlob(blob);
    //   final anchor = html.document.createElement('a') as html.AnchorElement
    //     ..href = url
    //     ..style.display = 'none'
    //     ..download = '$filename';
    //   html.document.body?.children.add(anchor);
    //
    //   anchor.click();
    //
    //   html.document.body?.children.remove(anchor);
    //   html.Url.revokeObjectUrl(url);
    // } else {
    //   throw Exception("Should be called on web only");
    // }
  }

  double getWidthMaxWidthGuard(BuildContext context) {
    return MediaQuery.of(context).size.width > MAX_WIDTH ? MAX_WIDTH : MediaQuery.of(context).size.width;
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
    final Iterator<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogsContainer?.dialogs.iterator;
    if (dialogs == null) return null;

    while(dialogs.moveNext()) {
      if (dialogs.current.chatUsers.first.id == userId &&
          dialogs.current.chatUsers.last.id == partnerId &&
          dialogs.current.chatType.p2p == 1 ||
          dialogs.current.chatUsers.first.id == partnerId &&
              dialogs.current.chatUsers.last.id == userId &&
              dialogs.current.chatType.p2p == 1 ) {
        return dialogs.current;
      }
    }
    return null;
  }

  double _computeWidth(double width) {
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


bool isOnline(int id, Map<int, bool> onlineMembers) {
  if (onlineMembers[id] != null) return true;
  return false;
}

String mapErrorToMessage(Object error) {
  print("CATCH ERROR  $error");
  if (error is! AppErrorException) {
    return 'Неизвестная ошибка, поторите попытку';
  }
  switch (error.type) {
    case AppErrorExceptionType.network:
      return 'Сервер не доступен. Проверьте подключение к интернету';
    case AppErrorExceptionType.auth:
      return 'Не получилось загрузить данные, нужна повторная авторизация';
    case AppErrorExceptionType.access:
      return 'Недостаточно прав доступа для получения данных, свяжитесь с администратором!';
    case AppErrorExceptionType.sessionExpired:
      return 'Сессия устарела, обновите КЕШ';
    case AppErrorExceptionType.other:
      return 'Произошла ошибка. Попробуйте еще раз';
    case AppErrorExceptionType.parsing:
      return 'Произошла ошибка при обработки данных. Попробуйте еще раз';
    case AppErrorExceptionType.socket:
      return 'Произошла ошибка при получении данных по сети';
    case AppErrorExceptionType.render:
      return 'Произошла ошибка при создании виджета';
    case AppErrorExceptionType.getData:
      return 'Произошла ошибка при загрузке данных. Попробуйте еще раз';
    case AppErrorExceptionType.secureStorage:
      return 'Произошла ошибка при обращении к хранилищу данных. Попробуйте еще раз';
    case AppErrorExceptionType.requestError:
      return 'При отправке на сервер запрос не прошел валидацию - введены неверные данные';
    case AppErrorExceptionType.db:
      return 'Произошла ошибка при чтении/записи данных в базу данных. Попробуйте еще раз. При возникновении ошибки более 5 раз подряд - попробуйте удалить БД на странице Профиль и перезапустить приложение';
  }
}
