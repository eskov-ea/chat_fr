import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_bloc/user_event.dart';
import '../../services/global.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_item.dart';
import '../widgets/search_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  void _onRefresh(BuildContext context)  {
    BlocProvider.of<UsersViewCubit>(context).usersBloc.add(UsersLoadEvent());
  }

  @override
  Widget build(BuildContext context) {

    final cubit = context.read<UsersViewCubit>();

    return Scaffold(
      appBar: CustomAppBar(context),
      body: BlocBuilder<UsersViewCubit, UsersViewCubitState>(
        builder: (context, state) {
          if ( state is UsersViewCubitLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UsersViewCubitLoadedState) {
            return Column(
              children: [
                SearchWidget(cubit: cubit),
                const SizedBox(height: 10),
                Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _onRefresh(context);
                      },
                      child: ListView.separated(
                          itemCount: state.users.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return state.users.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 0, bottom: 0),
                                  child: Align(
                                    child: UserItem(
                                      user: state.users[index],
                                      onlineStatus: isOnline(state.users[index].id, state.onlineUsersDictionary),
                                    ),
                                  // Text(state.users[index].username),
                                  ),
                                )
                              : const Center(
                                 child: Text('No contacts yet'),
                                );
                          }),
                    )
                ),
              ],
            );
          } else {
            return _errorWidget("Произошла ошибка при загрузке пользователей, попробуйте еще раз");
          }
        }
      ),
    );
  }

  Widget _errorWidget(String errorMessage) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
              onRefresh: () async {
                _onRefresh(context);
              },
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: constraints.maxHeight
                      ),
                      child: Center(
                          child: Text(errorMessage,
                            textAlign: TextAlign.center,
                          )
                      )
                  )
              )
          );
        }
    );
  }
}




// return RefreshIndicator(
// onRefresh: () async {
// print("We refresh here");
// refreshContacts();
// },
// child: Container(
// color: Colors.greenAccent,
// height: MediaQuery.of(context).size.height,
// width: MediaQuery.of(context).size.width,
// child: const Center(
// child: Text(
// 'Произошла ошибка при загрузке пользователей, попробуйте еще раз',
// style: TextStyle(fontSize: 20.0),
// textAlign: TextAlign.center,
// ),
// ),
// ),
// );