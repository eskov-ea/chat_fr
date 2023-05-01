import 'package:chat/ui/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../../../models/contact_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../../services/global.dart';
import '../../../view_models/user/users_view_cubit.dart';
import '../../navigation/main_navigation.dart';

class GroupChatPreviewPage extends StatefulWidget {
  const GroupChatPreviewPage({
    required this.chatType,
    required this.usersList,
    required this.isSecret,
    required this.bloc, Key? key
  }) : super(key: key);

  final List usersList;
  final UsersViewCubit bloc;
  final int chatType;
  final bool isSecret;

  @override
  State<GroupChatPreviewPage> createState() => _GroupChatPreviewPageState();
}

class _GroupChatPreviewPageState extends State<GroupChatPreviewPage> {
  final List<UserContact> groupUsersList = [];
  final TextEditingController _textNameFieldController = TextEditingController();
  final TextEditingController _textDescriptionFieldController = TextEditingController();
  final DialogsProvider _dialogsProvider = DialogsProvider();
  int currentChatType = 0;
  bool isPublic = false;

  @override
  void initState() {
    _makeGroupUsersList();

    if (widget.isSecret) {
      currentChatType = 4;
      // currentChatType = groupUsersList.length > 1 ? 4 : 3;
    } else {
      currentChatType = widget.chatType;
    }
    super.initState();
  }

  void _makeGroupUsersList() {
    for (var userId in widget.usersList) {
      for (var user in widget.bloc.usersBloc.state.users) {
        if (userId == user.id) groupUsersList.add(user);
      }
    }
  }

  void removeUserFromGroupList(index) {
    groupUsersList.removeAt(index);
    if (groupUsersList.isEmpty) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  void changeIsPublic(bool) {
    setState(() {
      isPublic = bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        leadingWidth: 100,
        // title: const Text('New message'),
      ),
      body: currentChatType != 3
      ? SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SingleChildScrollView(
                  child: Container(
                alignment: Alignment.center,
                height: 280,
                padding: EdgeInsets.only(left: 5, right: 5, top: 40),
                child: Center(
                  child: _groupUsersList(groupUsersList, removeUserFromGroupList),
                ),
              )),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: TextFormField(
                    controller: _textNameFieldController,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: "  Введите название группы"
                    ),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 100,
                  child: TextFormField(
                    // expands: true,
                    minLines: 3,
                    maxLines: 10,
                    controller: _textDescriptionFieldController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: "Введите описание группы"
                    ),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
              currentChatType == 2 || currentChatType == 5
              ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: Stack(
                  children: [
                    Checkbox(
                      value: isPublic, onChanged: changeIsPublic,
                      checkColor: Colors.blueAccent,
                      activeColor: Colors.white,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 50),
                      child: Text("Публичный чат, любой пользователь может найти и присоединиться",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              )
              : SizedBox.shrink(),
              SizedBox(height: 30,),
              OutlinedButton(
                  onPressed: () async {
                    //TODO: optimize
                    print("GROUPLIST  -->  $groupUsersList");
                    print("GROUPLIST  -->  $currentChatType");
                    loadingInProgressModalWidget(context, "Загрузка");
                    final newGroup = await _dialogsProvider.createDialog(chatType: currentChatType, users: widget.usersList, chatName: _textNameFieldController.text, chatDescription: _textDescriptionFieldController.text, isPublic: isPublic);
                    if (newGroup != null) {
                      Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.homeScreen
                      );
                    } else {
                      Navigator.of(context).pop();
                      customToastMessage(context, "Произошла ошибка. Попробуйте еще раз");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.black54,
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                  ),
                  child: const Text(
                    'Начать групповой чат',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  )),
            ],
          ),
        ),
      )
      : Center(
        child: OutlinedButton(
            onPressed: () async {
              customToastMessage(context, "Секретный p2p чат пока не настроен");
              // print("GROUPLIST  -->  $groupUsersList");
              // print("GROUPLIST  -->  $currentChatType");
              // loadingInProgressModalWidget(context, "Загрузка");
              // final newGroup = await _dialogsProvider.createDialog(chatType: currentChatType, users: widget.usersList, chatName: _textNameFieldController.text, chatDescription: _textDescriptionFieldController.text, isPublic: isPublic);
              // if (newGroup != null) {
              //   Navigator.of(context).pushNamed(
              //       MainNavigationRouteNames.homeScreen
              //   );
              // } else {
              //   Navigator.of(context).pop();
              //   customToastMessage(context, "Произошла ошибка. Попробуйте еще раз");
              // }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
              shape: const RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.black54,
                      width: 2,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
            ),
            child: const Text(
              'Начать секретный чат',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }
}

Widget _groupUsersList(
    List<UserContact> groupUsersList, removeUserFromGroupList) {
  return GridView.count(
    crossAxisCount: 2,
    childAspectRatio: (1 / .25),
    children: List.generate(groupUsersList.length, (index) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: Container(
          color: Colors.black12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "${groupUsersList[index].firstname} ${groupUsersList[index].lastname}"),
              IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.centerRight,
                onPressed: () {
                  removeUserFromGroupList(index);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.black54,
              ))
            ],
          ),
        ),
      );
    }),
  );
}


