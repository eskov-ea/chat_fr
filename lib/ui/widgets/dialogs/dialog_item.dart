import 'package:chat/helpers.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/helpers/navigation_helpers.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/avatar_widget.dart';
import 'package:chat/ui/widgets/dialog_avatar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogItem extends StatelessWidget {
  const DialogItem({
    Key? key,
    required this.dialogData,
    required this.userId,
    required this.checkOnline,
    required this.onlineMembers
  }) : super(key: key);

  final DialogData dialogData;
  final int? userId;
  final Function checkOnline;
  final Map<int, bool> onlineMembers;

  String getChatItemName(DialogData data) {
    if (data.chatType.p2p == 1) {
      for (var i = 0; i < data.usersList.length; i++)  {
        if (data.usersList[i].id != userId) {
          return "${data.usersList[i].lastname} ${data.usersList[i].firstname}";
        }
      }
    } else {
      return data.name;
    }
    return "Dialog";
  }

  List<UserContact> getPartnersData(List<UserContact> data) {
    final List<UserContact> partners = [];
    for (var i = 0; i < data.length; i++)  {
      if (data[i].id != userId) {
        partners.add(data[i]);
      }
    }
    if (partners.isEmpty) partners.add(data[0]);

    return partners;
  }

  WidgetSpan isOnlineWidget (int id) {
    if (checkOnline(id)) {
      return WidgetSpan(
        child: Icon(Icons.circle, color: Colors.green, size: 15,),
      );
    } else {
      return WidgetSpan(child: SizedBox.shrink());
    }
  }

  Widget _setDialogAvatar({required DialogData dialogData, required List<UserContact> partners, required ObjectKey key}) {
    if (dialogData.chatType.name == "Приват" || dialogData.chatType.name == "Приват безопасный") {
      return UserAvatarWidget(userId: partners.first.id, objKey: key);
    } else {
      return DialogAvatar(base64String: dialogData.picture,);
    }
  }


  @override
  Widget build(BuildContext context) {

    final String partnerName = getChatItemName(dialogData);
    final List<UserContact> partners = getPartnersData(dialogData.usersList);
    final objKey = ObjectKey("${userId}_object_key");

    return InkWell(
      key: objKey,
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 100));
        openChatScreen(
            context: context,
            userId: userId,
            partnerId: partners.first.id,
            dialogData: dialogData,
            username: userId == dialogData.usersList.first.id
                ? "${dialogData.usersList.last.lastname} ${dialogData.usersList.last.firstname}"
                : "${dialogData.usersList.first.lastname} ${dialogData.usersList.first.firstname}"
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
                    child: _setDialogAvatar(dialogData: dialogData, partners: partners, key: objKey)
                )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            WidgetSpan(child: SizedBox(width: 5,),),
                            if (dialogData.chatType.p2p == 1 && onlineMembers[partners.first.id] != null)
                              WidgetSpan(
                                child: Icon(Icons.circle, color: Colors.green, size: 15,),
                              )
                          ]
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                    ),
                  ),
                  SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          const SizedBox(width: 5,),
                          Expanded(
                            child: Text(
                              dialogData.lastMessage.message == ""
                                  ? "Файл"
                                  : dialogData.lastMessage.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: LightColors.secondaryText,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
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
                    dialogData.lastMessage.time != null ? getDateDialogModel(dialogData.lastMessage.time!) : "",
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
                      dialogData.chatType.typeId == 3 || dialogData.chatType.typeId == 4
                          ? Align(child: Icon(Icons.lock))
                          : SizedBox.shrink(),
                      SizedBox(width: 10,),
                      ( dialogData.lastMessage.senderId != 0 && dialogData.lastMessage.senderId != userId && Helpers.checkIReadMessage(dialogData.lastMessage.statuses, userId!) != 4)
                          ? Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            ' ',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLigth,
                            ),
                          ),
                        ),
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
}