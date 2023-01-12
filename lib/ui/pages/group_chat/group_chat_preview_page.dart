import 'package:chat/ui/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../../../models/contact_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../../services/global.dart';
import '../../../view_models/user/users_view_cubit.dart';
import '../../navigation/main_navigation.dart';

class GroupChatPreviewPage extends StatefulWidget {
  const GroupChatPreviewPage({
    required this.usersList,
    required this.bloc, Key? key
  }) : super(key: key);

  final List usersList;
  final UsersViewCubit bloc;

  @override
  State<GroupChatPreviewPage> createState() => _GroupChatPreviewPageState();
}

class _GroupChatPreviewPageState extends State<GroupChatPreviewPage> {
  final List<UserContact> groupUsersList = [];
  final TextEditingController _textFieldController = TextEditingController();
  final DialogsProvider _dialogsProvider = DialogsProvider();

  @override
  void initState() {
    _makeGroupUsersList();
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
      body: Column(
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.center,
            height: 300,
            padding: EdgeInsets.only(left: 5, right: 5, top: 40),
            child: Center(
              child: _groupUsersList(groupUsersList, removeUserFromGroupList),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width * 0.7, 50)),
              child: TextFormField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                  labelText: "Введите название группы"
                ),
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    decoration: TextDecoration.none),
              ),
            ),
          ),
          OutlinedButton(
              onPressed: () async {
                print("GROUPLIST  -->  $groupUsersList");
                loadingInProgressModalWidget(context, "Загрузка");
                final newGroup = await _dialogsProvider.createDialog(chatType: 2, users: widget.usersList, chatName: _textFieldController.text, chatDescription: null, isPublic: false);
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
                minimumSize: const Size.fromHeight(60),
                shape: const RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.black54,
                        width: 2,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
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


