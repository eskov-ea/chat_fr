import 'dart:async';
import 'dart:io';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_event.dart';
import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/factories/screen_factory.dart';
import 'package:chat/models/app_notification_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/message_sender_helper.dart';
import 'package:chat/services/push_notifications/push_notification_service.dart';
import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/widgets/active_call_widget.dart';
import 'package:chat/ui/widgets/app_notification_widget.dart';
import 'package:chat/ui/widgets/call_connecting_audio_player.dart';
import 'package:chat/ui/widgets/session_expires_widget.dart';
import 'package:chat/ui/widgets/web_container_wrapper.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'running_call_screen.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {


  final permissionMethodChannel = const MethodChannel("com.application.chat/permission_method_channel");
  late final StreamSubscription callServiceBlocSubscription;
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
  int? userId;
  late final CallConnectingAudioPlayer callPlayer;
  late final StreamSubscription<ErrorHandlerState> _errorHandlerBlocSubscription;
  String? currentVersion;
  final _websocketRepo = WebsocketRepository.instance;

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
    try {
      userId ??= await _dataProvider.getUserId();
      if (userId == null) throw AppErrorException((AppErrorExceptionType.other));
      SipRepository.instance.connect(settings, userId!, displayName);
    } catch (err) {
      ClientErrorHandler.informErrorHappened(context, "Произошла ошибка при подключению к SIP-сервису, звонки недоступны. Попробуйте перезапустить приложение, при повторном возникновении ошибок - свяжитесь с разработчиками.");
    }
  }

  void _subscribeToErrorsBlocStream() {
    _errorHandlerBlocSubscription = BlocProvider.of<ErrorHandlerBloc>(context).stream.listen(_onErrorState);
  }

  void _onErrorState(ErrorHandlerState state) {
    if (state is ErrorHandlerWithAppErrorState) {
    print("ErrorHandlerState  $state  ${state.error}");
      if (state.error.type == AppErrorExceptionType.auth) {
        SessionExpiredModalWidget(context);
      } else {
        final String message = mapErrorToMessage(state.error);
        customToastMessage(context: context, message: "Error message: $message");
      }
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
            //TODO: refacrot messageBloc
            // BlocProvider.of<ChatsBuilderBloc>(context).add(RefreshChatsBuilderEvent());
          }
        }
      } catch (err) {
        customToastMessage(context: context, message: "Не удалось проверить корпоративные группы и каналы. Проверим в следующий раз.");
      }
    }
  }

  Future<void> _onBlocProfileStateChanged(UserProfileState state) async {
    if (state is UserProfileLoadedState) {
      myUserName = "${state.user?.lastname} ${state.user?.firstname}";
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
      // BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
    }
  }

  void initialLoadData() async {
    BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
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
            arguments: CallScreenArguments(userId: userId.toString()));
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


  void _onCallStateChanged(CallState state) async {

    print("callServiceBlocSubscription   $state");
    if (state is IncomingCallState) {
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
      try {
        Navigator.of(context).popUntil((route) =>
        route.settings.name == MainNavigationRouteNames.homeScreen);
      } catch (err) {
        Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.loaderWidget);
      }
      BlocProvider.of<CallLogsBloc>(context).add(AddCallToLogEvent(call: state.callData));
      if (isOutgoingCall && (state.callData.callStatus != 0 || state.callData.callStatus != 5)) {
        print('Sending push::::');

        _pushNotificationService.sendMissCallPush(
            userId: state.callData.fromCaller.substring(1, state.callData.toCaller.length), userName: myUserName);
      }
      setState(() {
        isActiveCall = false;
        isIncomingCall = false;
        isOutgoingCall = false;
        callerName = null;
      });
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
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
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
    userProfileDataSubscription =  BlocProvider.of<ProfileBloc>(context).stream.listen(_onBlocProfileStateChanged);
    _subscribeToErrorsBlocStream();
    updateUserProfileData();
    if (!kIsWeb) {
      callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen(_onCallStateChanged);
    }

    super.initState();

    BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocGetUpdatesOnResume());
    customToastMessage(context: context, message: 'Обновляем данные');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch(state){
      case AppLifecycleState.resumed:
        BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocGetUpdatesOnResume());
        customToastMessage(context: context, message: 'Обновляем данные');
        _websocketRepo.reconnect();
      case AppLifecycleState.paused:
        DBProvider.db.setLastUpdateTime();
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
                    : const SizedBox.shrink(),
                !kIsWeb && isOutgoingCall
                    ? ActiveCallStatusWidget(message: "Исходящий вызов", screenCallback: _openCallScreen,)
                    : const SizedBox.shrink(),
                !kIsWeb && isActiveCall
                    ? RunningCallStatusWidget(screenCallback: _openCallScreen)
                    : const SizedBox.shrink(),
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
