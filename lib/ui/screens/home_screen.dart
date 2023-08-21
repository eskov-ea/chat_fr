import 'dart:async';
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
import '../widgets/session_expires_widget.dart';
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
  bool isActiveCall = false;
  bool isIncomingCall = false;
  bool isUpdateAvailable = true;
  late final StreamSubscription<ErrorHandlerState> _errorHandlerBlocSubscription;


  Future<bool> isCallRunning () async {
    return await sipChannel.invokeMethod('CHECK_FOR_RUNNING_CALL');
  }

  Future<void> sipRegistration(UserProfileAsteriskSettings settings, String? displayName) async {
    SipConfig.sipDomain = settings.userDomain;
    SipConfig.sipPrefix = settings.sipPrefix;
    try {
      final String? userId = await _dataProvider.getUserId();
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
      print("sipRegistration error  $err");
    }
  }

  void _subscribeToErrorsBlocStream() {
    _errorHandlerBlocSubscription = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.errorHandlerBloc.stream.listen(_onErrorState);
  }

  void _onErrorState(ErrorHandlerState state){
    print("ErrorHandlerState log ${state}");
    if (state is ErrorHandlerWithErrorState) {
      if (state.error.type == AppErrorExceptionType.auth) {
        SessionExpiredModalWidget(context);
      } else {
        final String message = _mapErrorToMessage(state.error);
        customToastMessage(context, "Error message: $message");
      }
    }
  }
  String _mapErrorToMessage(Object error) {
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
    if (settings.autoJoinChats.isNotEmpty) {
      try {
        bool isJoined = false;
        final String? userId = await _dataProvider.getUserId();
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
          sipRegistration(state.user!.userProfileSettings!, myUserName);
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

  void initialLoadData() async {
    BlocProvider.of<ProfileBloc>(context).add(ProfileBlocLoadingEvent());
    BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.add(DialogsLoadEvent());
    BlocProvider.of<WebsocketViewCubit>(context).wsBloc.add(InitializeSocketEvent());
    BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
  }

  void getUserCallLog(UserProfileAsteriskSettings settings) {
    BlocProvider.of<CallLogsBloc>(context).add(LoadCallLogsEvent(passwd: settings.asteriskUserPassword!));
  }

  void _openIncomingCallScreen() {
    if (Platform.isIOS) return;
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.incomingCallScreen,
        arguments: CallScreenArguments(
            callerName: callerName ?? "Не удалось определить номер"
        )
    );
  }
  void _returnToConnectedCallScreen() {
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.runningCallScreen,
        arguments: CallScreenArguments(
          callerName: callerName ?? "Не удалось определить номер",
        )
    );
  }


  @override
  void initState() {
    initialLoadData();
    WidgetsBinding.instance?.addObserver(this);
    userProfileDataSubscription =  BlocProvider.of<ProfileBloc>(context).stream.listen(_onBlocProfileStateChanged);
    _subscribeToErrorsBlocStream();
    updateUserProfileData();
    getOs();
    if (!kIsWeb) {
      callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen((state) async {
        print("CALL_SERVICE_STATE   $state");
        if (state is UnconnectedCallServiceState) {
          customToastMessage(context, "Произошла ошибка при подключении к SIP-серверу");
        } else if (state is IncomingCallState) {
          if(ModalRoute.of(context)?.settings.name == MainNavigationRouteNames.incomingCallScreen) return;
          try {
            final callerUser = BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users.firstWhere((el) => "${SipConfig.getPrefix()}${el.id}" == state.callerName);
            callerName = "${callerUser.firstname} ${callerUser.lastname}";
          } catch (err) {
            callerName = "${state.callerName}";
          }
          setState(() {
            isIncomingCall = true;
          });
          _openIncomingCallScreen();
        } else if (state is OutgoingCallServiceState) {
          print("NAVIGATOR outg   ${ModalRoute.of(context)?.settings.name}");
          if(ModalRoute.of(context)?.settings.name == MainNavigationRouteNames.outgoingCallScreen) return;
          _isPushSent = false;
          print("Route name:  ${ModalRoute.of(context)?.settings.name}");
          try {
            final callerUser = BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users.firstWhere((el) => "${SipConfig.getPrefix()}${el.id}" == state.callerName);
            callerName = "${callerUser.firstname} ${callerUser.lastname}";
          } catch (err) {
            print("OutgoingCallServiceState Error:   $err");
          }
          setState(() {
            isActiveCall = true;
          });
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.outgoingCallScreen,
              arguments: CallScreenArguments(
                callerName: callerName ?? state.callerName
              )
          );
        } else if(state is ConnectedCallState) {
          setState(() {
            isActiveCall = true;
            isIncomingCall = false;
          });
          Navigator.of(context).popAndPushNamed(
              MainNavigationRouteNames.runningCallScreen,
              arguments: CallScreenArguments(
                callerName: callerName ?? "Не удалось определить номер",
              )
          );
        } else if(state is EndedCallServiceState) {
          print("NAVIGATOR end   ${ModalRoute.of(context)?.settings.name}");
          setState(() {
            isActiveCall = false;
            isIncomingCall = false;
            callerName = null;
          });
          BlocProvider.of<CallLogsBloc>(context).add(AddCallToLogEvent(call: state.callData));
          Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
        } else if(state is ErrorCallServiceState) {
          Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
          final List<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogs;
          int? dialogId;
          String caller = '';
          final String? userId = await _dataProvider.getUserId();
          if (dialogs != null && dialogs.isNotEmpty) {
            caller = state.callerName.substring(1, state.callerName.length);
            for (var dialog in dialogs) {
              if (dialog.chatType.typeId == 1) {
                for (var user in dialog.usersList) {
                  if (user.id.toString() == caller) {
                    dialogId = dialog.dialogId;
                    break;
                  }
                }
              }
            }
          }

          if (_isPushSent == false) {
            _isPushSent = true;
            final chatsBuilderBloc = BlocProvider.of<ChatsBuilderBloc>(context);
            dialogId ??= await createDialog(chatsBuilderBloc: chatsBuilderBloc, partnerId: int.parse(state.callerName));
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
        } else if (state is EndCallWithNoLogServiceState) {
          setState(() {
            isActiveCall = false;
            isIncomingCall = false;
            callerName = null;
          });
          Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
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
    userProfileDataSubscription.cancel();
    _errorHandlerBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            isIncomingCall
              ? IncomingCallStatusWidget(screenCallback: _openIncomingCallScreen,)
              : SizedBox.shrink(),
            isActiveCall
              ? ActiveCallStatusWidget(screenCallback: _returnToConnectedCallScreen)
              : SizedBox.shrink(),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _screenFactory.makeMessagesPage(),
                  _screenFactory.makeCallsPage(),
                  _screenFactory.makeContactsPage(),
                  _screenFactory.makeProfilePage(isUpdateAvailable),
                ],
              ),
            )
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
      ),
    );
  }
}
