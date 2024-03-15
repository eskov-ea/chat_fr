import 'dart:async';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/dialogs_bloc/group_dialog_members_streamer.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/contact_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../../theme.dart';
import '../../../view_models/user/users_view_cubit.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/slidable_widget.dart';
import 'add_user_to_group_chat_page.dart';

class GroupChatInfoPage extends StatefulWidget {
  const GroupChatInfoPage({
    required this.userId,
    required this.chatUsers,
    required this.dialogData,
    required this.users,
    required this.dialogsViewCubit,
    Key? key
  }) : super(key: key);

  //TODO: refactor db
  final int? userId;
  final List<int>? chatUsers;
  final DialogData dialogData;
  final List<UserModel> users;
  final DialogsViewCubit dialogsViewCubit;

  @override
  State<GroupChatInfoPage> createState() => _GroupChatInfoPageState();
}

class _GroupChatInfoPageState extends State<GroupChatInfoPage> {

  List<ChatUser> stateUsers = [];
  //TODO: higt this functionality up to bloc
  final DialogsProvider _dialogsProvider = DialogsProvider();
  StreamSubscription? _groupChatEventSubscription;
  bool isDeleteUserMode = false;
  bool isAdmin = false;
  String? userId;
  Map<int, UserModel> _users = {};

  @override
  void initState() {
    if (BlocProvider.of<UsersViewCubit>(context).state is UsersViewCubitLoadedState) {
      _users = (BlocProvider.of<UsersViewCubit>(context).state as UsersViewCubitLoadedState).usersDictionary;
    }

    getInitialUsers();
    _groupChatEventSubscription = GroupDialogsMemberStateStreamer.instance.stream.listen((ChatUserEvent event) {
      print('adding user:   ${event.event} ${event.chatUser}');
      if (event.event == "exit") {
        setState(() {
          stateUsers.remove(event.chatUser);
        });
      } else if (event.event == "join") {
        setState(() {
          stateUsers.add(event.chatUser);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _groupChatEventSubscription?.cancel();
    super.dispose();
  }



  getInitialUsers() async {
    stateUsers = await DBProvider.db.getChatUsersByDialogId(widget.dialogData.dialogId);
    isAdmin = stateUsers.firstWhere((user) => user.userId == widget.userId).chatUserRole == 1;
    setState(() {});
  }

  deleteUserFromChat(ChatUser user) async {
    if (!isAdmin) {
      return customToastMessage(context: context, message: 'Только администратор может удалить пользователя из чата');
    }
    if (user.userId.toString() == userId) {
      return customToastMessage(context: context, message: 'Вы не можете удалиться из чата, тк вы его создатель');
    }

    try {
      PopupManager.showLoadingPopup(context);
      await _dialogsProvider.exitDialog(user.userId, widget.dialogData.dialogId);
      BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocUserExitChatEvent(chatUser: user));
      PopupManager.closePopup(context);
    } catch (err) {
      PopupManager.closePopup(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: 'Произошла ошибка при удалении участника чата. Попробуйте еще раз');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: false,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(CupertinoIcons.back, color: AppColors.secondary, size: 30,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: const Text("О группе",
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(4), // Border radius
                  child: ClipOval(
                      child: false
                          ? Image.network("")
                          : Image.asset('assets/images/no_avatar.png')
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text(widget.dialogData.name,
                style: TextStyle(fontSize: 24),
              ),
              Text("Описание: ${widget.dialogData.description ?? "групповой чат"}",
               textAlign: TextAlign.center,
               style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.only(left: 20, bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("${stateUsers.length} участника",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,),
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: LightColors.profilePageButton,
                    borderRadius:  BorderRadius.all(Radius.circular(8)),
                  ),
                  height: 200,
                  child: ListView.builder(
                      itemCount: stateUsers.length,
                      itemBuilder: (context, index) {
                        final itemName = stateUsers[index].userId == widget.userId ? "Вы" : "${_users[stateUsers[index].userId]?.lastname} ${_users[stateUsers[index].userId]?.firstname}";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              UserAvatarWidget(userId: stateUsers[index].userId, size: 20),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(itemName,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              stateUsers[index].chatUserRole == 1
                                  ? Icon(Icons.star)
                                  : SizedBox.shrink(),
                              isDeleteUserMode
                                  ? IconButton(
                                      icon: Icon( Icons.remove_circle, color: Colors.red,),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            isDismissible: false,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.black54,
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              content: Container(
                                                height: 180,
                                                color: Colors.white,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Удалить $itemName из списка участников?',
                                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    OutlinedButton(
                                                      onPressed: (){
                                                        deleteUserFromChat(stateUsers[index]);
                                                        setState(() {
                                                          isDeleteUserMode = false;
                                                        });
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: SizedBox(
                                                        width: 70,
                                                        child: Text('Удалить',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.red, fontSize: 16),))
                                                    ),
                                                    OutlinedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: SizedBox(
                                                        width: 70,
                                                        child: Text('Назад',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.black, fontSize: 16),),
                                                      )
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ));
                                      },
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        );
                      }
                  ),
                ),
              ),
              isAdmin
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: 150,
                child: Column(
                  children: [
                    OutlinedButton(
                        onPressed: () async {
                          try {
                            openUsersListToAddToChat(
                              context: context,
                              dialogId:  widget.dialogData.dialogId
                            );
                          } catch (err) {
                            ClientErrorHandler.informErrorHappened(context, "Произошла непредвиденная ошибка. Попробуйте еще раз.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: LightColors.profilePageButton,
                          minimumSize: const Size.fromHeight(50),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.zero
                              )
                          ),
                        ),
                        child: const Text(
                          'Добавить участника',
                          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w300),
                        )
                    ),
                    OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            isDeleteUserMode = !isDeleteUserMode;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: LightColors.profilePageButton,
                          minimumSize: const Size.fromHeight(50),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  topRight: Radius.zero,
                                  topLeft: Radius.zero
                              )
                          ),
                        ),
                        child: Text(
                          isDeleteUserMode ? 'Готово' : 'Удалить участника',
                          style: TextStyle(color: isDeleteUserMode ? Colors.black54 : Colors.red, fontSize: 20, fontWeight: FontWeight.w300),
                        )
                      ),
                  ],
                ),
              )
              : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: OutlinedButton(
                  onPressed: () async {
                    deleteUserFromChat(stateUsers.firstWhere((user) => user.userId.toString() == userId));
                    Navigator.popUntil(context, (route) => route.settings.name == '/home_screen');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: LightColors.profilePageButton,
                    minimumSize: const Size.fromHeight(50),
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.zero,
                            topLeft: Radius.zero
                        )
                    ),
                  ),
                  child: Text('Выйти из группы',
                    style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w300),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

openUsersListToAddToChat({
  required context,
  required dialogId
}){
  Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) =>
          AddingUserToGroupChatPage(
            dialogId: dialogId
          )
      )
  );
}