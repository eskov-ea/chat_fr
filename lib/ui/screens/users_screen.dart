import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
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

  @override
  Widget build(BuildContext context) {

    final cubit = context.read<UsersViewCubit>();
    void _onRefresh() => cubit.refresh();


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
                        _onRefresh();
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
          } else if (state is UsersViewCubitErrorState) {
            return ClientErrorHandler.makeErrorInfoWidget(state.errorType, _onRefresh);
          } else {
            return ClientErrorHandler.makeErrorInfoWidget(AppErrorExceptionType.other, _onRefresh);
          }
        }
      ),
    );
  }
}
