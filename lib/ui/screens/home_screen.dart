import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_state.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../bloc/calls_bloc/calls_bloc.dart';
import '../../bloc/calls_bloc/calls_state.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../bloc/chats_builder_bloc/chats_builder_state.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_events.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../bloc/user_bloc/user_event.dart';
import '../../bloc/ws_bloc/ws_bloc.dart';
import '../../bloc/ws_bloc/ws_event.dart';
import '../../bloc/ws_bloc/ws_state.dart';
import '../../factories/screen_factory.dart';
import '../../models/message_model.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import '../../services/push_notifications/push_notification_service.dart';
import '../../storage/sqflite_database.dart';
import '../../theme.dart';
import '../../view_models/websocket/websocket_view_cubit.dart';
import '../navigation/main_navigation.dart';
import '../pages/new_message_page.dart';
import '../widgets/icon_buttons.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'running_call_screen.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  final sipChannel = const MethodChannel("com.application.chat/sip");
  final callServiceEventChannel = const EventChannel("event.channel/call_service");
  late final StreamSubscription callServiceBlocSubscription;
  late final StreamSubscription sipEventChannelSubscription;
  late final StreamSubscription userProfileDataSubscription;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  bool _isPushSent = false;
  final DataProvider _dataProvider = DataProvider();
  String? callerName;
  String? myUserName;
  String? os;
  SqfliteDatabase? _db;
  bool isUpdateAvailable = true;
  late final StreamSubscription<ErrorHandlerState> _errorHandlerBlocSubscription;


  Future<bool> isCallRunning () async {
    return await sipChannel.invokeMethod('CHECK_FOR_RUNNING_CALL');
  }

  Future<void> sipRegistration(UserProfileAsteriskSettings settings) async {
    try {
      final String? userId = await _dataProvider.getUserId();
      print("Trying to register to SIP with    $userId@${settings.asteriskHost} and password ${settings.asteriskUserPassword}");
      await sipChannel.invokeMethod('SIP_LOGIN', {
        "username": "$userId",
        "password": settings.asteriskUserPassword,
        "domain": settings.asteriskHost
      });
    } catch (err) {
      print("sipRegistration error  $err");
    }
  }

  void _subscribeToErrorsBlocStream() {
    _errorHandlerBlocSubscription = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.errorHandlerBloc.stream.listen(_onErrorState);
  }

  void _onErrorState(ErrorHandlerState state){
    if (state is ErrorHandlerWithErrorState) {
      final String message = _mapErrorToMessage(state.error);
      final error = state.error as AppErrorException;
      customToastMessage(context, "Error message: $message, error was: ${error.message}, location: ${error.errorLocation}");
    }
  }
  String _mapErrorToMessage(Object error) {
    print("Error happened");
    if (error is! AppErrorException) {
      return 'Неизвестная ошибка, поторите попытку';
    }
    switch (error.type) {
      case AppErrorExceptionType.network:
        return 'Сервер не доступен. Проверте подключение к интернету';
      case AppErrorExceptionType.auth:
        return 'Не получилось загрузить данные, нужна повторная авторизация';
      case AppErrorExceptionType.access:
        return 'Недостаточно прав доступа для получения данных, свяжитесь с администратором!';
      case AppErrorExceptionType.sessionExpired:
        return 'Суссия устарела, обновите КЕШ';
      case AppErrorExceptionType.other:
        return 'Произошла ошибка. Попробуйте еще раз';
      case AppErrorExceptionType.parsing:
        return 'Произошла ошибка при обработки данных. Попробуйте еще раз';
      case AppErrorExceptionType.getData:
        return 'Произошла ошибка при загрузке данных. Попробуйте еще раз';
    }
  }

  void getOs() async {
    os = await _dataProvider.getOs();
  }

  void updateUserProfileData() async {
    BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
  }

  void checkAppVersion(AppSettings settings) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("Current app version is $version  $buildNumber");
    if (packageInfo.version != settings.version) {
      isUpdateAvailable = true;
      if(os == "android") {
        customToastMessage(context, "Доступна новая версия приложения. Вы можете обновить ее в разделе Профиль");
      } else {
        customToastMessage(context, "Доступна новая версия приложения. Свяжитесь с разработчиками, чтобы установить ее");
      }
    }
  }

  void _autoJoinChats(ChatSettings settings) async {
    print('autojoin');
    if (settings.autoJoinChats.isNotEmpty) {
      try {
        bool isJoined = false;
        final String? userId = await _dataProvider.getUserId();
        // final dialogVC = BlocProvider.of<DialogsViewCubit>(context);
        final publicDialogs = await DialogsProvider().getPublicDialogs();
        if (publicDialogs.isNotEmpty) {
          for (var requiredChat in settings.autoJoinChats){
            print('autojoin  ${requiredChat.name}');
            for (var publicDialog in publicDialogs) {
              if (requiredChat.dialogId == publicDialog.dialogId){
                await DialogsProvider()
                    .joinDialog(userId, publicDialog.dialogId);
                isJoined = true;
              }
            }
          }
          if(isJoined == true) refreshAllData(context);
        }
      } catch (err) {
        print("publicDialog err   $err");
        customToastMessage(context, "Не удалось проверить корпоративные группы и каналы");
      }
    }
  }

  Future<void> _onBlocProfileStateChanged(UserProfileState state) async {
    if (state is UserProfileLoadedState) {
      myUserName = "${state.user?.firstname} ${state.user?.lastname}";
      print("asterisk  --> ${state.user!.userProfileSettings!.asteriskUserPassword} ");
      if (kIsWeb) return;
      if (!await isCallRunning()){
        if (state.user != null && state.user?.userProfileSettings != null
            && state.user!.userProfileSettings!.asteriskUserPassword != null
            && state.user!.userProfileSettings!.asteriskHost != null) {
          sipRegistration(state.user!.userProfileSettings!);
        }
        getUserCallLog(state.user!.userProfileSettings!);
      } else {
        customToastMessage(context, "Не удалось получить настройки для Asterisk с сервера. Пожалуйста, сообщите об этой ошибке разработчикам");
      }
      if (state.user?.appSettings != null){
        checkAppVersion(state.user!.appSettings!);
        _autoJoinChats(state.user!.chatSettings!);
      }
    }
  }

  void shouldDownloadData() async {
    if (context.read<ProfileBloc>().state is UserProfileLoggedOutState) {
      print("There was logout");
      BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
      BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.add(DialogsLoadEvent());
      BlocProvider.of<WebsocketViewCubit>(context).wsBloc.add(InitializeSocketEvent());
      BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
    }
  }

  void getUserCallLog(UserProfileAsteriskSettings settings) {
    BlocProvider.of<CallLogsBloc>(context).add(LoadCallLogsEvent(passwd: settings.asteriskUserPassword!));
  }

  Future<void> showId () async {
    final id = await _dataProvider.getDeviceID();
    await MethodChannel("com.application.chat/method").invokeMethod('getDeviceToken');
    print('token:  $id');
  }
  @override
  void initState() {
    shouldDownloadData();
    showId();
    WidgetsBinding.instance?.addObserver(this);
    userProfileDataSubscription =  BlocProvider.of<ProfileBloc>(context).stream.listen(_onBlocProfileStateChanged);
    _subscribeToErrorsBlocStream();
    updateUserProfileData();
    getOs();
    if (!kIsWeb) {
      // _db = getSqfliteDatabase();
      callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen((state) async {
        if (state is IncomingCallState) {
          // final callerUser = BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users.firstWhere((el) => el.id.toString() == state.callerName);
          // callerName = "${callerUser.firstname} ${callerUser.lastname}";
          // FAke data
          callerName = null;
          if (callerName == null) callerName = 'Undefined';
          if (Platform.isIOS) return;
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.incomingCallScreen,
              arguments: CallScreenArguments(
                callerName: callerName ?? state.callerName,
                // callsBloc: BlocProvider.of<CallsBloc>(context),
                // users: BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users
              )
          );
        } else if (state is OutgoingCallServiceState) {
          _isPushSent = false;
          final callerUser = BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users.firstWhere((el) => el.id.toString() == state.callerName);
          callerName = "${callerUser.firstname} ${callerUser.lastname}";
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.outgoingCallScreen,
              arguments: CallScreenArguments(
                callerName: callerName ?? state.callerName,
                // callsBloc: BlocProvider.of<CallsBloc>(context),
                // users: BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users
              )
          );
        } else if(state is ConnectedCallState) {
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.runningCallScreen,
              arguments: CallScreenArguments(
                callerName: callerName ?? "Не удалось определить номер",
              )
          );
        } else if(state is EndedCallServiceState) {
          print("NAVIGATOR   ${ModalRoute.of(context)?.settings.name}");
          Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
          print("CALL_ENDED  ${state.callData.callStatus}");
          BlocProvider.of<CallLogsBloc>(context).add(AddCallToLogEvent(call: state.callData));
        } else if(state is ErrorCallServiceState) {
          final List<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogs;
          int? dialogId;
          final String? userId = await _dataProvider.getUserId();
          if (dialogs != null && dialogs.isNotEmpty) {
            for (var dialog in dialogs) {
              if (dialog.chatType.typeId == 1) {
                for (var user in dialog.usersList) {
                  if (user.id.toString() == state.callerName) {
                    dialogId = dialog.dialogId;
                    print("FIND DIALOG  -->  ${dialog.usersList} , ${dialog.dialogId}");
                    // break;
                  }
                }
              }
            }
          }

          if (_isPushSent == false) {
            _isPushSent = true;
            dialogId ??= await createDialog(context, state.callerName);
            // print("SENDING_PUSH   ${dialogId}");
            _pushNotificationService.sendMissCallPush(
                userId: state.callerName, userName: myUserName);
            print("PUSH CALUSERID   ${state.callerName}");
            _sendMessage(context: context, userId: int.parse(userId!), dialogId: dialogId);
          }
        }
      });
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    var bloc = BlocProvider.of<WsBloc>(context);
    switch(state){
      case AppLifecycleState.resumed:
      // bloc.add(WsEventReconnect());
        if (bloc.state is Connected) {
          print('HOMESCREEN CONNECTED SOCKET STATE');
        } else if (bloc.state is Unconnected) {
          print('HOMESCREEN DISCONNECTED SOCKET STATE');
          bloc.add(InitializeSocketEvent());
        }
        final passwd = BlocProvider.of<ProfileBloc>(context).state.user?.userProfileSettings?.asteriskUserPassword;
        if (passwd == null) return;
        BlocProvider.of<CallLogsBloc>(context).add(UpdateCallLogsEvent(passwd: passwd));
        break;
      case AppLifecycleState.paused:
    }
  }

  int _selectedTab = 0;
  final _screenFactory = ScreenFactory();

  void onSelectTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
  }
  @override
  void dispose() {
    callServiceBlocSubscription.cancel();
    if ( _db != null) _db!.closeDb();
    _errorHandlerBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _screenFactory.makeMessagesPage(),
          _screenFactory.makeCallsPage(),
          _screenFactory.makeContactsPage(),
          _screenFactory.makeProfilePage(isUpdateAvailable),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: null,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bubble_left_bubble_right_fill),
            label: 'Сообщения',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.phone_fill),
            label: 'Звонки',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2_fill),
            label: 'Участники',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            label: 'Профиль',
          ),
        ],
        onTap: onSelectTab,
      ),
    );
  }



}

class _OptionsIcon extends StatelessWidget {
  const _OptionsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var _bloc = BlocProvider.of<UsersViewCubit>(context);
    return IconBackground(
      icon: Icons.launch,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => NewMessagePage(bloc: _bloc),
        );
      },
    );
  }

}

//TODO: refactor to one global function
_sendMessage({required context, required userId, required dialogId}) async {
  try {
    final messageText = "Пропущенный звонок";
    final localMessage = createLocalMessage(replyedMessageId: null, parentMessage: null, userId: userId, dialogId: dialogId, messageText: messageText);
    print("localMessage  $localMessage");
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderAddMessageEvent(message: localMessage, dialog: dialogId!)
    );
    // TODO: if response status code is 200 else ..
    final sentMessage = await MessagesRepository().sendMessage(dialogId: dialogId!, messageText: messageText, parentMessageId: null);
    print("sentMessage  $sentMessage");
    final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: dialogId!, localMessageId: localMessage.messageId)
    );
    BlocProvider.of<DialogsViewCubit>(context).updateLastDialogMessage(localMessage);
  } catch (err) {
    print("_sendMessage error $err");
  }
  BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
}

createDialog(context, partnerId) async {
    final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [partnerId], chatName: "p2p", chatDescription: null, isPublic: false);
    print("SENDING_PUSH   ${newDialog?.dialogId}");
    if (newDialog != null) {
      final chatsBuilderBloc = BlocProvider.of<ChatsBuilderBloc>(context);
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