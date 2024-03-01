import 'dart:async';
import 'dart:io';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_event.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_state.dart';
import 'package:chat/models/app_notification_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/ui/widgets/app_notification_widget.dart';
import 'package:chat/ui/widgets/web_container_wrapper.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/calls_bloc/calls_bloc.dart';
import '../../bloc/calls_bloc/calls_state.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_events.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../bloc/user_bloc/user_event.dart';
import '../../bloc/ws_bloc/ws_bloc.dart';
import '../../bloc/ws_bloc/ws_event.dart';
import '../../factories/screen_factory.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../../services/global.dart';
import '../../services/helpers/message_sender_helper.dart';
import '../../services/push_notifications/push_notification_service.dart';
import '../../theme.dart';
import '../../view_models/websocket/websocket_view_cubit.dart';
import '../navigation/main_navigation.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import '../widgets/active_call_widget.dart';
import '../widgets/call_connecting_audio_player.dart';
import '../widgets/session_expires_widget.dart';
import 'running_call_screen.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  final sipChannel = const MethodChannel("com.application.chat/sip");
  final permissionMethodChannel = const MethodChannel("com.application.chat/permission_method_channel");
  final callServiceEventChannel = const EventChannel("event.channel/call_service");
  late final StreamSubscription callServiceBlocSubscription;
  late final StreamSubscription sipEventChannelSubscription;
  late final StreamSubscription userProfileDataSubscription;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  bool _isPushSent = false;
  final DataProvider _dataProvider = DataProvider.storage;
  String? callerName;
  String? myUserName;
  String? os;
  bool isActiveCall = false;
  bool isIncomingCall = false;
  bool isOutgoingCall = false;
  bool isUpdateAvailable = false;
  bool isCallBeenAnswered = false;
  String? userId;
  late final CallConnectingAudioPlayer callPlayer;
  late final StreamSubscription<ErrorHandlerState> _errorHandlerBlocSubscription;
  String? currentVersion;

  AppNotificationModel? notification;
  bool isNotificationActive = false;
  void updateNotification(AppNotificationModel n) async {
    if (isNotificationActive) {
      await cancelNotification();
    }
    setState(() {
      notification = n;
      isNotificationActive = true;
    });
    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      cancelNotification();
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        isNotificationActive = false;
      });
    });
  }
  Future<void> cancelNotification () async {
    setState(() {
      notification = null;
    });
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      isNotificationActive = false;
    });
  }

  Future<bool> isCallRunning () async {
    if (!kIsWeb){
      return await sipChannel.invokeMethod('CHECK_FOR_RUNNING_CALL');
    } else {
      return false;
    }
  }

  Future<void> sipRegistration(UserProfileAsteriskSettings settings, String? displayName) async {
    if (kIsWeb) return;
    SipConfig.sipDomain = settings.userDomain;
    SipConfig.sipPrefix = settings.sipPrefix;
    try {
      print("Trying to register to SIP with    ${SipConfig.getPrefix()}$userId@${settings.asteriskHost} and password ${settings.asteriskUserPassword} and domain  ${settings.userDomain}");
      await sipChannel.invokeMethod('SIP_LOGIN', {
        "username": "${SipConfig.getPrefix()}$userId",
        "display_name": displayName,
        "password": settings.asteriskUserPassword,
        "domain": settings.userDomain,
        "stun_domain": settings.stunHost,
        "stun_port": settings.stunPort,
        "host": settings.asteriskHost,
        "cert": settings.asteriskCert
      });
    } catch (err) {
      ClientErrorHandler.informErrorHappened(context, "Произошла ошибка при подключению к SIP-сервису, звонки недоступны. Попробуйте перезапустить приложение, при повторном возникновении ошибок - свяжитесь с разработчиками.");
    }
  }

  void _subscribeToErrorsBlocStream() {
    _errorHandlerBlocSubscription = BlocProvider.of<ErrorHandlerBloc>(context).stream.listen(_onErrorState);
  }

  void _onErrorState(ErrorHandlerState state){
    if (state is ErrorHandlerWithAppErrorState) {
    print("ErrorHandlerState  $state  ${state.error}");
      if (state.error.type == AppErrorExceptionType.auth) {
        SessionExpiredModalWidget(context);
      } else {
        final String message = _mapErrorToMessage(state.error);
        customToastMessage(context: context, message: "Error message: $message");
      }
    }
  }

  String _mapErrorToMessage(Object error) {
    print("CATCH ERROR  $error");
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
    }
  }


  void updateUserProfileData() async {
    BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
  }

  void checkAppVersion(AppSettings settings) async {
    if (kIsWeb) return;
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        currentVersion = packageInfo.version;
      });
      final String? availableVersion = Platform.isAndroid ? settings.versionAndroid : Platform.isIOS ? settings.versionIos : null;
      if(availableVersion == null) return;
      final List<String> currentVersionArray = currentVersion!.split(".");
      final List<String> availableVersionArray = availableVersion.split(".");
      for(var i=0; i<currentVersionArray.length; ++i) {
        if(int.parse(currentVersionArray[i]) < int.parse(availableVersionArray[i])) {
          isUpdateAvailable = true;
          if(!Platform.isIOS) {
            customToastMessage(context: context, message: "Доступна новая версия приложения. Вы можете обновить ее в разделе Профиль");
          } else {
            SnackBarAction? action;
            if (await canLaunchUrl(Uri.parse('https://apps.apple.com/us/app/mcfef-int/id6452551074'))) {
              action = SnackBarAction(
                label: 'Обновить',
                onPressed: () async {
                  await launchUrl(Uri.parse('https://apps.apple.com/us/app/mcfef-int/id6452551074'));
                },
              );
            }
            customToastMessage(context: context, message: "Доступна новая версия приложения. Свяжитесь с разработчиками, чтобы установить ее", action: action);
          }
          return;
        }
      }
    } catch(_) {
      return;
    }
  }

  void _autoJoinChats(ChatSettings settings) async {
    if (settings.autoJoinChats.isNotEmpty) {
      try {
        bool isJoined = false;
        // final String? userId = await _dataProvider.getUserId();
        final publicDialogs = await DialogsProvider().getPublicDialogs();
        if (publicDialogs.isNotEmpty) {
          for (var requiredChat in settings.autoJoinChats){
            for (var publicDialog in publicDialogs) {
              if (requiredChat.dialogId == publicDialog.dialogId){
                await DialogsProvider()
                    .joinDialog(userId, publicDialog.dialogId);
                isJoined = true;
              }
            }
          }
          if(isJoined == true) {
            BlocProvider.of<DialogsViewCubit>(context).refreshAllDialogs();
            BlocProvider.of<ChatsBuilderBloc>(context).add(RefreshChatsBuilderEvent());
          }
        }
      } catch (err) {
        customToastMessage(context: context, message: "Не удалось проверить корпоративные группы и каналы. Проверим в следующий раз.");
      }
    }
  }

  Future<void> _onBlocProfileStateChanged(UserProfileState state) async {
    if (state is UserProfileLoadedState) {
      myUserName = "${state.user?.firstname} ${state.user?.lastname}";
      if (kIsWeb) return;
      if (!await isCallRunning()){
        if (state.user != null && state.user?.userProfileSettings != null
            && state.user!.userProfileSettings!.asteriskUserPassword != null
            && state.user!.userProfileSettings!.asteriskHost != null) {
          sipRegistration(state.user!.userProfileSettings!, myUserName);
        }
        getUserCallLog(state.user!.userProfileSettings!);
      }
      if (state.user?.appSettings != null){
        checkAppVersion(state.user!.appSettings!);
        _autoJoinChats(state.user!.chatSettings!);
      } else {
        customToastMessage(context: context, message: "Не удалось получить настройки для Asterisk с сервера. Пожалуйста, сообщите об этой ошибке разработчикам");
      }
    }
  }

  void shouldDownloadData() async {
    if (context.read<ProfileBloc>().state is UserProfileLoggedOutState) {
      BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
      BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.add(DialogsLoadEvent());
      BlocProvider.of<WebsocketViewCubit>(context).wsBloc.add(InitializeSocketEvent());
      // BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
    }
  }

  void initialLoadData() async {
    BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
    // BlocProvider.of<DialogsViewCubit>(context).loadDialogs();
    BlocProvider.of<WebsocketViewCubit>(context).wsBloc.add(InitializeSocketEvent());
    // BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
  }

  void getUserCallLog(UserProfileAsteriskSettings settings) {
    BlocProvider.of<CallLogsBloc>(context).add(LoadCallLogsEvent(passwd: settings.asteriskUserPassword!));
  }

  void _openCallScreen() {
    if (kIsWeb) return;
    try {
      final CallState state = BlocProvider.of<CallsBloc>(context).state;
      if (Platform.isIOS && state is! IncomingCallState || !Platform.isIOS) {
        Navigator.of(context).pushNamed(
            MainNavigationRouteNames.runningCallScreen,
            arguments: CallScreenArguments(userId: userId));
      }
    } catch(_) {
      setState(() {
        isActiveCall = false;
        isIncomingCall = false;
        isOutgoingCall = false;
        callerName = null;
      });
    }
  }

  void _sendMissCallNotification({required int? dialogId, required String caller, required String? userId}) async {
    print("SEND MISCALL MESSAGE  $dialogId   //   $caller   //   $userId");
    _isPushSent = true;
    final chatsBuilderBloc = BlocProvider.of<ChatsBuilderBloc>(context);
    dialogId ??= await createDialog(chatsBuilderBloc: chatsBuilderBloc, partnerId: int.parse(caller));
    _pushNotificationService.sendMissCallPush(
        userId: caller, userName: myUserName);
    sendMessageUnix(
      userId: int.parse(userId!),
      dialogId: dialogId!,
      bloc: chatsBuilderBloc,
      messageText: "Пропущенный звонок",
      file: null,
      parentMessage: null,
    );
  }


  @override
  void initState() {
    // Future.delayed(Duration(milliseconds: 2500)).then((value) {
    //   updateNotification(AppNotificationModel(key: GlobalKey(),fromName: "fromName", message: "message", type: AppNotificationType.message, callback: (){}));
    // });
    // Future.delayed(Duration(milliseconds: 3000)).then((value) {
    //   updateNotification(AppNotificationModel(key: GlobalKey(), fromName: "fromName", message: "message", type: AppNotificationType.message, callback: (){}));
    // });
    _dataProvider.getUserId().then((v) {
      userId = v;
    });
    CallConnectingAudioPlayer.player.then((v) {
      callPlayer = v;
    });
    initialLoadData();
    if (!kIsWeb && Platform.isAndroid) {
      permissionMethodChannel.invokeMethod("CHECK_APP_PERMISSION");
    }
    WidgetsBinding.instance?.addObserver(this);
    userProfileDataSubscription =  BlocProvider.of<ProfileBloc>(context).stream.listen(_onBlocProfileStateChanged);
    _subscribeToErrorsBlocStream();
    updateUserProfileData();
    if (!kIsWeb) {
      callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen((state) async {
        print("callServiceBlocSubscription   $state");
        if (state is UnconnectedCallServiceState) {
          customToastMessage(context: context, message: "Произошла ошибка при подключении к SIP-серверу",
              icon: const Icon(Icons.error, color: Color(0xFFC7112A), size: 14));
        } else if (state is ConnectedCallServiceState) {
          customToastMessage(context: context, message: "Подключение к SIP-серверу",
              icon: const Icon(Icons.done_outline, color: Color(0xFF11C751), size: 14));
        } else if (state is IncomingCallState) {
          if(ModalRoute.of(context)?.settings.name == MainNavigationRouteNames.incomingCallScreen) return;
          setState(() {
            isIncomingCall = true;
          });
          _openCallScreen();
        } else if (state is OutgoingCallState) {
          if(ModalRoute.of(context)?.settings.name == MainNavigationRouteNames.outgoingCallScreen) return;
          callPlayer.startPlayConnectingSound();
          _isPushSent = false;
          _openCallScreen();
          setState(() {
            isOutgoingCall = true;
          });
        } else if(state is ConnectedCallState) {
          callPlayer.stopPlayConnectingSound();
          setState(() {
            isCallBeenAnswered = true;
            isActiveCall = true;
            isIncomingCall = false;
            isOutgoingCall = false;
          });
        } else if(state is EndedCallState) {
          callPlayer.stopPlayConnectingSound();
          setState(() {
            isActiveCall = false;
            isIncomingCall = false;
            isOutgoingCall = false;
            callerName = null;
          });
          try {
            Navigator.of(context).popUntil((route) =>
                route.settings.name == MainNavigationRouteNames.homeScreen);
          } catch (err) {
            Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.loaderWidget);
          }
          BlocProvider.of<CallLogsBloc>(context).add(AddCallToLogEvent(call: state.callData));
          if (_isPushSent == false && !isCallBeenAnswered && isOutgoingCall) {
            int? dialogId;
            String caller = '';
            final List<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogsContainer?.dialogs;
            if (dialogs != null && dialogs.isNotEmpty) {
              caller = state.callData.toCaller.substring(1, state.callData.toCaller.length);
              for (var dialog in dialogs) {
                if (dialog.chatType.typeId == 1) {
                  for (var userId in dialog.users) {
                    if (userId.toString() == caller) {
                      dialogId = dialog.dialogId;
                      break;
                    }
                  }
                }
              }
            }
            _sendMissCallNotification(dialogId: dialogId, caller: caller, userId: userId);
          }
        } else if (state is StreamRunningCallState) {
          callPlayer.stopPlayConnectingSound();
        } else if (state is ErrorCallState) {
          callPlayer.stopPlayConnectingSound();
        } else if (state is OutgoingRingingCallState) {
          callPlayer.stopPlayConnectingSound();
        } else if (state is EndCallWithNoLogState) {
          callPlayer.stopPlayConnectingSound();
          Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
          setState(() {
            isActiveCall = false;
            isIncomingCall = false;
            isOutgoingCall = false;
            callerName = null;
          });
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
        bloc.add(WsEventReconnect());
        final passwd = BlocProvider.of<ProfileBloc>(context).state.user?.userProfileSettings?.asteriskUserPassword;
        if (passwd == null) return;
        BlocProvider.of<CallLogsBloc>(context).add(UpdateCallLogsEvent(passwd: passwd));
        break;
      case AppLifecycleState.paused:

      default:
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
    WidgetsBinding.instance?.removeObserver(this);
    callServiceBlocSubscription.cancel();
    userProfileDataSubscription.cancel();
    _errorHandlerBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebContainerWrapper(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                !kIsWeb && isIncomingCall && Platform.isAndroid
                    ? ActiveCallStatusWidget(message: "Входящий вызов", screenCallback: _openCallScreen,)
                    : SizedBox.shrink(),
                !kIsWeb && isOutgoingCall
                    ? ActiveCallStatusWidget(message: "Исходящий вызов", screenCallback: _openCallScreen,)
                    : SizedBox.shrink(),
                !kIsWeb && isActiveCall
                    ? RunningCallStatusWidget(screenCallback: _openCallScreen)
                    : SizedBox.shrink(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _screenFactory.makeMessagesPage(),
                      _screenFactory.makeCallsPage(),
                      _screenFactory.makeContactsPage(),
                      _screenFactory.makeProfilePage(isUpdateAvailable, currentVersion),
                      // _screenFactory.makePassScreen(),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),


      bottomNavigationBar: Row(
        children: [
          if (MediaQuery.of(context).size.width > 700) const Spacer(),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 700 ? 700 : MediaQuery.of(context).size.width
            ),
            child: BottomNavigationBar(
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
          ),
          if (MediaQuery.of(context).size.width > 700) const Spacer(),
        ],
      ),
    );
  }
}
