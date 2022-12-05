import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_item.dart';
import '../widgets/search_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UsersViewCubit>();
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(context),
        body: BlocBuilder<UsersViewCubit, UsersViewCubitState>(
          builder: (context, state) {
            if ( state is UsersViewCubitLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UsersViewCubitLoadedState) {
              return GestureDetector(
                child: Column(
                  children: [
                    SearchWidget(cubit: cubit),
                    const SizedBox(height: 10,),
                    Expanded(
                        child: ListView.separated(
                            itemCount: state.users.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              return state.users.isNotEmpty
                                  ? Container(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 0, bottom: 0),
                                child: Align(
                                  child: UserItem(user: state.users[index]),
                                  // Text(state.users[index].username),
                                ),
                              )
                                  : const Center(
                                child: Text('No contacts yet'),
                              );
                            })
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: Text(
                'Error fetching users',
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }
        ),
      ),
    );
  }
}
