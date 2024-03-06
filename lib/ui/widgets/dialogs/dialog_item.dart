import 'dart:async';
import 'dart:developer';

import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_event.dart';
import 'package:chat/bloc/user_bloc/online_users_manager.dart';
import 'package:chat/helpers.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/navigation_helpers.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/avatar_widget.dart';
import 'package:chat/ui/widgets/dialog_avatar_widget.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogItem extends StatefulWidget {
  const DialogItem({
    Key? key,
    required this.dialogData,
    required this.userId,
    required this.checkOnline,
    required this.clearSearch,
    required this.users,
    required this.onlineMembers
  }) : super(key: key);

  final DialogData dialogData;
  final int? userId;
  final Function checkOnline;
  final Function clearSearch;
  final Map<int, bool> onlineMembers;
  final List<UserModel> users;

  @override
  State<DialogItem> createState() => _DialogItemState();
}

class _DialogItemState extends State<DialogItem> {

  final UserOnlineStatusManager _userStatusManagement = UserOnlineStatusManager.instance;
  late final StreamSubscription<Map<int, bool>>? _userStatusSubscription;
  bool online = false;

  @override
  void initState() {
    super.initState();
    if (widget.dialogData.chatType.p2p == 1) {
      final List<UserModel> partners = getPartnersData(widget.dialogData.users);
      if (_userStatusManagement.onlineUsers.containsKey(partners.first.id)) {
        setState(() {
          online = true;
        });
      }
      _userStatusSubscription = _userStatusManagement.status.listen((event) {
        if (event.containsKey(partners.first.id)) {
          setState(() {
            online = event[partners.first.id]!;
          });
        }
      });
    } else {
      _userStatusSubscription = null;
    }
  }

  @override
  void dispose() {
    _userStatusSubscription?.cancel();
    super.dispose();
  }

  List<UserModel> getPartnersData(List<int> chatUsers) {
    //TODO: refactor
    final List<UserModel> partners = [];
    for (var i = 0; i < chatUsers.length; i++) {
      final id = chatUsers[i];
      if (id != widget.userId) {
        for(var user in widget.users) {
          if(user.id == id) {
            partners.add(user);
          }
        }
      }
    }
    return partners;
  }

  WidgetSpan isOnlineWidget (int id) {
    if (widget.checkOnline(id)) {
      return WidgetSpan(
        child: Icon(Icons.circle, color: Colors.green, size: 15,),
      );
    } else {
      return WidgetSpan(child: SizedBox.shrink());
    }
  }

  Widget _setDialogAvatar({required DialogData dialogData, required List<UserModel> partners, required ObjectKey key}) {
    if (dialogData.chatType.typeName == "Приват" || dialogData.chatType.typeName == "Приват безопасный") {
      return UserAvatarWidget(userId: partners.first.id, objKey: key);
    } else {
      return DialogAvatar(base64String: dialogData.picture);
    }
  }

  @override
  Widget build(BuildContext context) {

    final String partnerName = getChatItemName(widget.dialogData, widget.userId);
    final List<UserModel> partners = getPartnersData(widget.dialogData.users);
    final objKey = ObjectKey("${widget.userId}_object_key");

    if(partners.isEmpty) return const SizedBox.shrink();
    return InkWell(
      key: objKey,
      onTap: () async {
        print('open dialog:  ${widget.dialogData.dialogId}');
        BlocProvider.of<MessageBloc>(context).add(MessageBlocFlushMessagesEvent());
        await Future.delayed(Duration(milliseconds: 100));
        widget.clearSearch();
        openChatScreen(
            context: context,
            userId: widget.userId,
            partnerId: partners.first.id,
            dialogData: widget.dialogData,
            username: widget.userId == widget.dialogData.chatUsers.first.userId
                ? "${widget.dialogData.chatUsers.last.user.lastname} ${widget.dialogData.chatUsers.last.user.firstname}"
                : "${widget.dialogData.chatUsers.first.user.lastname} ${widget.dialogData.chatUsers.first.user.firstname}"
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Center(
                    child: _setDialogAvatar(dialogData: widget.dialogData, partners: partners, key: objKey)
                )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                    child: RichText(
                      text: TextSpan(
                          text: partnerName,
                          style: const TextStyle(
                              fontSize: 18,
                              letterSpacing: 0.1,
                              wordSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                              color: AppColors.textDark
                          ),
                          children: [
                            const WidgetSpan(child: SizedBox(width: 5),),
                            if (online)
                              const WidgetSpan(
                                child: Icon(Icons.circle, color: Colors.green, size: 15,),
                              )
                          ]
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                    ),
                  ),
                  SizedBox(
                      height: 35,
                      child: Row(
                        children: [
                          const SizedBox(width: 5,),
                          Expanded(
                            child: lastMessageContent(),
                          )
                        ],
                      )
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 11,
                  ),
                  Text(
                    widget.dialogData.lastMessage != null ? getDateDialogModel(widget.dialogData.lastMessage!.rawDate) : "",
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFaded,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      widget.dialogData.chatType.typeId == 3 || widget.dialogData.chatType.typeId == 4
                          ? Align(child: Icon(Icons.lock))
                          : SizedBox.shrink(),
                      SizedBox(width: 10,),
                      ( widget.dialogData.lastMessage != null && widget.dialogData.lastMessage?.senderId != 0 && widget.dialogData.lastMessage?.senderId != widget.userId && Helpers.checkIReadMessage(widget.dialogData.lastMessage?.statuses, widget.userId!, widget.dialogData) != 4)
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              )
                          )
                          : const SizedBox.shrink()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lastMessageContent() {
    if (widget.dialogData.lastMessage == null) {
      return const Text(
        'Нет сообщений',
        style: const TextStyle(
            fontSize: 14,
            color: LightColors.secondaryText,
            fontWeight: FontWeight.w600
        ),
      );
    } else if (widget.dialogData.lastMessage != null && widget.dialogData.lastMessage!.message != "") {
      return Text(
        widget.dialogData.lastMessage!.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 14,
            color: LightColors.secondaryText,
            fontWeight: FontWeight.w600
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset("assets/icons/file.png", width: 21, height: 28, alignment: Alignment.bottomLeft,),
          const SizedBox(width: 5),
          const Text("Вложение", style: TextStyle(
            fontSize: 14,
            color: LightColors.secondaryText,
            fontWeight: FontWeight.w600)
          )
        ]
      );
    }
  }
}