import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/global.dart';
import '../widgets/app_bar.dart';
import '../widgets/call_user_item.dart';
import '../widgets/search_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({Key? key, helper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: kIsWeb
        ? const Center(child: Text("Недоступно в веб-версии"),)
        : BlocBuilder<UsersViewCubit, UsersViewCubitState>(
          builder: (context, state) {
            if ( state is UsersViewCubitLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UsersViewCubitLoadedState) {
              return Column(
                  children: [
                    SearchWidget(cubit: context.read<UsersViewCubit>()),
                    const SizedBox(height: 10,),
                    Expanded(
                        child: ListView.separated(
                            itemCount: state.users.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              return state.users.isNotEmpty
                                  ? CallUserItem(user: state.users[index])
                                  : const Center(
                                child: Text('No contacts yet'),
                              );
                            })
                    ),
                  ],
              );
            }
            return const CircularProgressIndicator();
          }
      ),
    );
  }
}
