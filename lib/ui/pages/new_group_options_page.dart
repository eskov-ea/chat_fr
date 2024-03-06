import 'dart:async';

import 'package:chat/services/global.dart';
import 'package:chat/ui/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/user_item.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';

import 'group_chat/group_chat_preview_page.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({required this.bloc, Key? key}) : super(key: key);

  final UsersViewCubit bloc;


  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {

  late final StreamSubscription userViewCubitStateSubscription;
  bool selectedMode = false;
  List selected = [];
  bool isSecret = false;

  // 2 - групповой чат; 3 - р2р приватный чат; 4 - групповой приватный чат; 5 - групповой чат в режиме чтения;
  late int chatType;

  void _setSelected(id) {
    print(id);
    setState(() {
      if (selectedMode) {
        if (!selected.contains(id)) {
          selected.add(id);
        } else {
          selected.remove(id);
        }
      }
      print(selected);
    });
  }

  @override
  void initState() {
    userViewCubitStateSubscription = widget.bloc.stream.listen((state) {
      if (state is UsersViewCubitLoadedState) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    userViewCubitStateSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final UsersViewCubit _bloc = widget.bloc;
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    child: Text(
                      selectedMode ? 'Назад' : 'Отменить',
                      style: TextStyle(color: Colors.white, fontSize: 20),),
                    onPressed: () {
                      if (selectedMode) {
                        setState(() {
                          selectedMode = false;
                        });
                      } else {
                        Navigator.pop(context);
                        _bloc.resetSearchQuery();
                      }
                    },
                  );
                },
              ),
              leadingWidth: 150,
              // title: const Text('New message'),
              actions: [
                if (selectedMode && selected.isEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 20)
                    ),
                    onPressed: (){},
                    child: const Text('Дальше', style: TextStyle(color: Colors.white12),),
                  ),
                if (selectedMode && selected.isNotEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 20)
                    ),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              GroupChatPreviewPage(
                                usersList: selected,
                                bloc: widget.bloc,
                                chatType: chatType,
                                isSecret: isSecret,
                              )));
                      // setState(() {
                        // selectedMode = false;
                      // });
                    },
                    child: const Text('Дальше'),
                  ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: SearchWidget(cubit: widget.bloc)
                ),
                if (!selectedMode)
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedMode = true;
                          chatType = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_add, color: Colors.black54),
                          SizedBox(width: 15,),
                          Text(
                            'Новый групповой чат',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 20),
                          )
                        ],
                      )
                  ),
                if (!selectedMode)
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedMode = true;
                          chatType = 3;
                          isSecret = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: Colors.black54,),
                          SizedBox(width: 15,),
                          const Text(
                          'Новый секретный чат',
                          style: TextStyle(color: Colors.black54, fontSize: 20),
                          )
                        ],
                      )
                  ),
                if (!selectedMode)
                  OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedMode = true;
                          chatType = 5;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.volume_up, color: Colors.black54,),
                          SizedBox(width: 15,),
                          const Text(
                            'Новый канал',
                            style: TextStyle(color: Colors.black54, fontSize: 20),
                          ),
                        ]
                      )),
                Expanded(
                  child: _UsersList(_bloc),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _UsersList(UsersViewCubit bloc) {
    if (bloc.state is UsersViewCubitLoadedState) {
      return ListView.builder(
          itemCount: bloc.usersBloc.state.users.length,
          itemBuilder: (context, index) {
            return bloc.usersBloc.state.users.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        if (selectedMode)
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            width: 40,
                            child: Checkbox(
                              checkColor: Colors.white,
                              activeColor: Color(0xFF5F8CFF),
                              value: selected.contains(bloc.usersBloc.state.users[index].id),
                              onChanged: (_) {
                                _setSelected(bloc.usersBloc.state.users[index].id);
                              },
                            ),
                          ),
                        Expanded(child: UserItem(user: bloc.usersBloc.state.users[index])
                        ),

                      ],
                    ),
                )
                : const Center(
                    child: Text('Нет участников'),
                  );
          });
    } else {
      return const Text('Участники не найдены');
    }
  }
}