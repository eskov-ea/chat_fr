import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/ui/widgets/avatar_widget.dart';
import 'package:chat/ui/widgets/search_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddingUserToGroupChatPage extends StatefulWidget {
  const AddingUserToGroupChatPage({
    required this.dialogId,
    Key? key
  }) : super(key: key);

  final int dialogId;

  @override
  State<AddingUserToGroupChatPage> createState() => _AddingUserToGroupChatPageState();
}

class _AddingUserToGroupChatPageState extends State<AddingUserToGroupChatPage> {

  List<UserModel> selected = [];
  final DialogsProvider _dialogsProvider = DialogsProvider();

  addUsersToDialog() async {
    PopupManager.showLoadingPopup(context);
    try {
      for (var user in selected) {
        final ChatUser chatUser = await _dialogsProvider.joinDialog(user.id, widget.dialogId);
        BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocUserJoinChatEvent(chatUser: chatUser));
      }
      PopupManager.closePopup(context);
      Navigator.of(context).maybePop();
    } catch (err) {
      PopupManager.closePopup(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: 'Произошла ошибка добавления участников в групповой чат. Попробуйте еще раз.');
    }
  }

  void _setSelected(UserModel user) {
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
      body: SafeArea(
        child: BlocBuilder<UsersViewCubit, UsersViewCubitState>(
          builder: (context, state) {
            if (state is UsersViewCubitLoadedState) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  const SearchWidget(),
                  const SizedBox(height: 10),
                  selected.isNotEmpty ? Container(
                    height: 30,
                    padding: const EdgeInsets.only(left: 24),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selected.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 30,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                              color: Colors.grey.shade400
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              Text(
                                selected[index].lastname
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: 20,
                                child: IconButton(
                                  onPressed: () {
                                    selected.remove(selected[index]);
                                    setState(() {});
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.close, color: Colors.white, size: 20,)
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        );
                      }
                    ),
                  ) : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          color: Colors.grey.shade200
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Выберите участников для вступления',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      child: ListView.separated(
                          itemCount: state.users.length,
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Divider(
                                thickness: 1.0,
                                color: Colors.grey.shade300,
                                height: 1,
                              ),
                            );
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              child: Ink(
                                height: 50,
                                decoration: BoxDecoration(
                                  color:  selected.contains(state.users[index])
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: (){
                                    _setSelected(state.users[index]);
                                  },
                                  splashColor: Colors.white54,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: UserAvatarWidget(userId: state.users[index].id, size: 20)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text("${state.users[index].lastname} ${state.users[index].firstname} ",
                                            style: TextStyle(fontSize: 19, height: 1.0),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        // child: selected.contains(state.users[index])
                                        //     ?
                                        //     : const SizedBox.shrink(),
                                        child: Transform.rotate(
                                          angle: selected.contains(state.users[index]) ? 15 : 0,
                                          child: IconButton(
                                            splashColor: Colors.white24,
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.zero,
                                            onPressed: (){
                                              _setSelected(state.users[index]);
                                            },
                                            icon: Icon(
                                                Icons.add,
                                                color: selected.contains(state.users[index]) ? Colors.blue.shade300 : Colors.grey.shade400,
                                                size: 30
                                            )
                                          ),
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                        color:  selected.isNotEmpty
                            ? Colors.greenAccent.shade200
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    child: GestureDetector(
                      onTap: () {
                        addUsersToDialog();
                      },
                      child: const Center(
                          child: Text(
                            "Добавить",
                            style: TextStyle(fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 10.0,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              );
            }
          }
        ),
      )
    );
  }
}

