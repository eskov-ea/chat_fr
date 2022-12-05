import 'dart:async';

import 'package:chat/models/dialog_model.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/contact_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../../theme.dart';
import '../../../view_models/user/users_view_cubit.dart';
import '../../widgets/slidable_widget.dart';
import 'add_user_to_group_chat_page.dart';

class GroupChatInfoPage extends StatefulWidget {
  const GroupChatInfoPage({
    required this.users,
    required this.chatUsers,
    required this.dialogData,
    required this.usersViewCubit,
    required this.dialogsViewCubit,
    Key? key
  }) : super(key: key);

  final List<UserContact> users;
  final List<ChatUser>? chatUsers;
  final DialogData dialogData;
  final UsersViewCubit usersViewCubit;
  final DialogsViewCubit dialogsViewCubit;

  @override
  State<GroupChatInfoPage> createState() => _GroupChatInfoPageState();
}

class _GroupChatInfoPageState extends State<GroupChatInfoPage> {

  List<ChatUser> stateUsers = [];
  //TODO: higt this functionality up to bloc
  final DialogsProvider _dialogsProvider = DialogsProvider();
  StreamSubscription? _dialogStateSubscription;

  @override
  void initState() {
    print("DIALOGSBLOC    ${BlocProvider.of<DialogsViewCubit>(context)}");
    getStateUsers(null);
    _dialogStateSubscription = widget.dialogsViewCubit.dialogsBloc.stream.listen((event) {
      getStateUsers(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _dialogStateSubscription?.cancel();
    super.dispose();
  }

  addUserCallback(user){
    // setState(() {
    //   stateUsers.add(user);
    // });
  }

  getStateUsers(event){
    print("DIALOGSBLOC   ${widget.dialogsViewCubit.dialogsBloc.state.dialogs}");
    stateUsers = [];
    for (var user in widget.dialogData.chatUsers!) {
      if (user.active) {
        stateUsers.add(user);
      }
    }
    setState(() {});
    print("StateUsers  ${stateUsers}");
    print("StateUsers  ${widget.chatUsers}");
  }

  deleteUserFromChat(ChatUser user) {
    setState(() {
      stateUsers.remove(user);
    });
    _dialogsProvider.exitDialog(user.user.id, widget.dialogData.dialogId);
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
                        return SlidableWidget(
                          onDismissed: (SlidableActionEnum action) {
                            deleteUserFromChat(stateUsers![index]);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
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
                                const SizedBox(width: 20,),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: index == widget.users.length - 1
                                          ? BorderSide(width: 0, color: Colors.transparent)
                                          : BorderSide(width: 1, color: Colors.black26)
                                      )
                                    ),
                                    child: Text("${widget.users[index].firstname} ${widget.users[index].lastname}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: 150,
                child: Column(
                  children: [
                    OutlinedButton(
                        onPressed: () async {
                          try {
                            openUsersListToAddToChat(
                              context: context,
                              usersViewCubit: widget.usersViewCubit,
                              dialogId:  widget.dialogData.dialogId,
                              addUserCallback: addUserCallback
                            );
                          } catch (err) {
                            print(err);
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
                    // OutlinedButton(
                    //     onPressed: () async {
                    //       try {
                    //
                    //       } catch (err) {
                    //         print(err);
                    //       }
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       primary: LightColors.profilePageButton,
                    //       minimumSize: const Size.fromHeight(50),
                    //       shape: const RoundedRectangleBorder(
                    //           side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                    //           borderRadius: BorderRadius.only(
                    //               bottomRight: Radius.circular(8),
                    //               bottomLeft: Radius.circular(8),
                    //               topRight: Radius.zero,
                    //               topLeft: Radius.zero
                    //           )
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Удалить участника',
                    //       style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w300),
                    //     )
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

openUsersListToAddToChat({
  required context,
  required usersViewCubit,
  required dialogId,
  required addUserCallback
}){
  Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) =>
          AddingUserToGroupChatPage(
            dialogId: dialogId,
            usersViewCubit: usersViewCubit,
            addUserCallback: addUserCallback
          ))
  );
}