import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/contact_model.dart';
import '../../models/dialog_model.dart';
import '../../models/user_profile_model.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../../services/helpers/navigation_helpers.dart';
import '../../storage/data_storage.dart';
import '../screens/chat_screen.dart';
import 'avatar.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    Key? key,
    required this.user
  }) : super(key: key);

  final UserContact user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        onTap:  () async {
          final userIdString = await DataProvider().getUserId();
          final userId = int.parse(userIdString!);
          final dialogData= findDialog(context, userId, user.id);
          openChatScreen(
              context: context,
              userId: userId,
              partnerId: user.id,
              dialogData: dialogData,
              username: user.firstname + " " + user.lastname
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: user.image != null
                  ? Avatar.small(url: user.image!)
                  : CircleAvatar(
                radius: 21,
                backgroundColor: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(1), // Border radius
                  child: ClipOval(
                      child: Image.asset('assets/images/no_avatar.png')
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.lastname + " " + user.firstname,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      "${user.company} | ${user.dept}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      user.position,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  DialogData? findDialog(BuildContext context, int userId, int partnerId){
    print('findDialog    $userId, $partnerId');
    // TODO: Another way to find a dialog is to send request to create a dialog.
    // If dialog exist it would return this dialog or create and return dialog.
    final Iterator<DialogData>? dialogs = BlocProvider.of<DialogsViewCubit>(context).dialogsBloc.state.dialogs?.iterator;
    if (dialogs == null) return null;

    while(dialogs.moveNext()) {
    print("current dialog findDialog ${dialogs.current} ");
      if (dialogs.current.usersList.first.id == userId &&
          dialogs.current.usersList.last.id == partnerId ||
          dialogs.current.usersList.first.id == partnerId &&
          dialogs.current.usersList.last.id == userId) {
        return dialogs.current;
      }
    }
    return null;
  }
}