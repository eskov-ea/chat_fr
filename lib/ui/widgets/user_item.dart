import 'dart:async';
import 'package:chat/bloc/user_bloc/online_users_manager.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/navigation_helpers.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'avatar_widget.dart';

class UserItem extends StatefulWidget {
  const UserItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserModel user;

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {

  final UserOnlineStatusManager _userStatusManagement = UserOnlineStatusManager.instance;
  late final StreamSubscription<Map<int, bool>> _userStatusSubscription;
  bool onlineStatus = false;

  @override
  void initState() {
    super.initState();
    if (_userStatusManagement.onlineUsers.containsKey(widget.user.id)) {
      setState(() {
        onlineStatus = true;
      });
    }
    _userStatusSubscription = _userStatusManagement.status.listen((event) {
      if (event.containsKey(widget.user.id)) {
        setState(() {
          onlineStatus = event[widget.user.id]!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ObjectKey("${widget.user.id}_container_key"),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        onTap:  () async {
          final userIdString = await DataProvider.storage.getUserId();
          final userId = int.parse(userIdString!);
          final dialogData= findDialog(context, userId, widget.user.id);
          openChatScreen(
              context: context,
              userId: userId,
              partnerId: widget.user.id,
              dialogData: dialogData,
              username: widget.user.firstname + " " + widget.user.lastname
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatarWidget(userId: widget.user.id),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.user.lastname + " " + widget.user.firstname,
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
                    width: getWidthMaxWidthGuard(context) * 0.6,
                    child: Text(
                      "${widget.user.company} | ${widget.user.dept}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Container(
                    width: getWidthMaxWidthGuard(context) * 0.6,
                    child: Text(
                      widget.user.position,
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