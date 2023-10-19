import 'package:chat/models/dialog_model.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/material.dart';
import '../../../models/contact_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/search_widget.dart';

class AddingUserToGroupChatPage extends StatefulWidget {
  const AddingUserToGroupChatPage({
    required this.dialogId,
    required this.usersViewCubit,
    required this.addUserCallback,
    Key? key
  }) : super(key: key);

  final UsersViewCubit usersViewCubit;
  final int dialogId;
  final Function addUserCallback;

  @override
  State<AddingUserToGroupChatPage> createState() => _AddingUserToGroupChatPageState();
}

class _AddingUserToGroupChatPageState extends State<AddingUserToGroupChatPage> {

  List<UserContact> selected = [];
  List<UserContact> users = [];
  //TODO: higt this functionality up to bloc
  final DialogsProvider _dialogsProvider = DialogsProvider();
  addUsersToDialog() async {
    for (var user in selected) {
      final ChatUser chatUser = await _dialogsProvider.joinDialog(user.id, widget.dialogId);
      widget.addUserCallback(chatUser);
    }
  }

  @override
  void initState() {
    users = widget.usersViewCubit.state.users;
    widget.usersViewCubit.stream.listen((event) {
      setState(() {
        users = event.users;
      });
    });
    super.initState();
  }

  void _setSelected(UserContact user) {
    setState(() {
      if (!selected.contains(user)) {
        selected.add(user);
      } else {
        selected.remove(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50,),
          Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: SearchWidget(cubit: widget.usersViewCubit)
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    _setSelected(users[index]);
                  },
                  child: Container(
                    color:  selected.contains(users[index].id)
                      ? Colors.white24
                      : Colors.transparent,
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AvatarWidget(userId: users[index].id, size: 20),
                          const SizedBox(width: 20,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: index == users.length - 1
                                          ? BorderSide(width: 0, color: Colors.transparent)
                                          : BorderSide(width: 1, color: Colors.black26)
                                  )
                              ),
                              child: Text("${users[index].lastname} ${users[index].firstname} ",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          selected.contains(users[index])
                              ? IconButton(
                              onPressed: (){},
                              icon: const Icon(Icons.close)
                          )
                              : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 60,
            color: Colors.blue,
            child: GestureDetector(
              onTap: () {
                addUsersToDialog();
                Navigator.of(context).pop();
              },
              child: const Center(
                  child: Text(
                    "Готово",
                    style: TextStyle(fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
}

