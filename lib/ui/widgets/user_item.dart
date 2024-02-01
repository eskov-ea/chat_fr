import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/global.dart';
import '../../services/helpers/navigation_helpers.dart';
import '../../storage/data_storage.dart';
import 'avatar_widget.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    Key? key,
    required this.user,
    required this.onlineStatus
  }) : super(key: key);

  final UserContact user;
  final bool onlineStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ObjectKey("${user.id}_container_key"),
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
            UserAvatarWidget(userId: user.id),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.lastname + " " + user.firstname,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      if (onlineStatus) SizedBox(width: 10,),
                      if (onlineStatus) Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.circle, color: Colors.green, size: 15,)
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      "${user.company} | ${user.dept}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      softWrap: true,
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

}