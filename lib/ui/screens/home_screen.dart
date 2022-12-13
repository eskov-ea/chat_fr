import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_events.dart';
import '../../bloc/profile_bloc/profile_state.dart';
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
import '../navigation/main_navigation.dart';
import '../pages/new_message_page.dart';
import '../widgets/icon_buttons.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/models/message_model.dart' as parseTime;
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
  String? os;
  SqfliteDatabase? _db;
  bool isUpdateAvailable = true;


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
      print("ERROR");
      print(err);
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

  void _onBlocProfileStateChanged(UserProfileState state){
    if (state is UserProfileLoadedState) {
      print("asterisk  --> ${state.user!.userProfileSettings!.asteriskUserPassword} ");
      if (kIsWeb) return;
      if (state.user != null && state.user?.userProfileSettings != null
          && state.user!.userProfileSettings!.asteriskUserPassword != null
          && state.user!.userProfileSettings!.asteriskHost != null  ) {
        sipRegistration(state.user!.userProfileSettings!);
      } else {
        customToastMessage(context, "Не удалось получить настройки для Asterisk с сервера. Пожалуйста, сообщите об этой ошибке разработчикам");
      }
      if (state.user?.appSettings != null){
        checkAppVersion(state.user!.appSettings!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    userProfileDataSubscription =  BlocProvider.of<ProfileBloc>(context).stream.listen(_onBlocProfileStateChanged);
    updateUserProfileData();
    getOs();
    if (!kIsWeb) {
      _db = getSqfliteDatabase();
      callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen((state) async {
        if (state is IncomingCallState) {
          final callerUser = BlocProvider.of<UsersViewCubit>(context).usersBloc.state.users.firstWhere((el) => el.id.toString() == state.callerName);
          callerName = "${callerUser.firstname} ${callerUser.lastname}";
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
                userId: state.callerName, userName: callerName);
            print("CALUSERID   ${state.callerName}");
            _sendMessage(context: context, userId: int.parse(userId!), dialogId: dialogId);
          }
        }
      });
    }
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
        ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: dialogId!, messageId: localMessage.messageId)
    );
    BlocProvider.of<DialogsViewCubit>(context).updateLastDialogMessage(localMessage);
  } catch (err) {
    print(err);
  }
  BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
}

createDialog(context, partnerId) async {
    final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [partnerId], chatName: "p2p", chatDescription: null);
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