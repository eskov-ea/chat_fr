import 'dart:async';
import 'package:chat/helpers.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit_state.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/dialog_model.dart';
import '../../../utils.dart';
import '../../models/contact_model.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/helpers/navigation_helpers.dart';
import '../widgets/app_bar.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/shimmer.dart';
import '../widgets/slidable_widget.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';


class MessagesPage extends StatefulWidget {
  const MessagesPage({ Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  Map<int, bool> onlineMembers = {};
  late final StreamSubscription presenceOnlineInfoChannelSubscription;
  int? userId;
  int  counter = 0;


  @override
  void initState() {
    _readUserId();
    presenceOnlineInfoChannelSubscription = BlocProvider.of<UsersViewCubit>(context).stream.listen((state) {
      setState(() {
        onlineMembers = state.onlineUsersDictionary;
        counter++;
      });
      print("onlineMembers    ${onlineMembers}");
    });
    super.initState();
  }

  void _readUserId() async {
    final userIdFromStorage = await DataProvider().getUserId();
    setState(() {
      userId = userIdFromStorage == null ? null : int.parse(userIdFromStorage);
    });
  }

  bool isMemberOnline(int id) {
    return onlineMembers[id] != null ? true : false;
  }

  @override
  void dispose() {
    presenceOnlineInfoChannelSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: BlocBuilder<DialogsViewCubit, DialogsViewCubitState>(
        builder: (context, state) {
          if (state is DialogsLoadedViewCubitState && userId != null) {
            if (state.isError) return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Произошла ошибка при загрузке диалогов"),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: (){refreshAllData(context);},
                    child: Text("Обновить")
                  )
                ],
              ),
            );
            if (state.dialogs.isEmpty) {
              return const Center(child: Text("Нет диалогов"),);
            } else{
              return RefreshIndicator(
                onRefresh: () async {
                  print("we refresh it here");
                  refreshAllData(context);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                            !_isDialogActive(state.dialogs[index], userId!) ||
                            state.dialogs[index].chatType.typeId == 3 && !(state.dialogs[index].messageCount > 0)
                            ? SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 0),
                                child: Align(
                                  child: _DialogItem(
                                    userId: userId,
                                    checkOnline: isMemberOnline,
                                    onlineMembers: onlineMembers,
                                    dialogData: DialogData(
                                      userData: state.dialogs[index].userData,
                                      dialogId: state.dialogs[index].dialogId,
                                      usersList: state.dialogs[index].usersList,
                                      chatType: state.dialogs[index].chatType,
                                      lastMessage: state.dialogs[index].lastMessage,
                                      name: state.dialogs[index].name,
                                      description: state.dialogs[index].description,
                                      chatUsers: state.dialogs[index].chatUsers,
                                      messageCount: state.dialogs[index].messageCount,
                                      createdAt: state.dialogs[index].createdAt
                                    ),
                                  ),
                                ),
                              ),
                        childCount: state.dialogs.length,
                      ),
                    )
                  ],
                ),
              );
            }
          }
          else {
            _readUserId();
            return const Shimmer(child: ShimmerLoading(child: DialogsSkeletonWidget()));
          }
        }),
    );
  }
}


class _DialogItem extends StatelessWidget {
   _DialogItem({
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
          return "${data.usersList[i].firstname} ${data.usersList[i].lastname}";
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


  @override
  Widget build(BuildContext context) {

    final String partnerName = getChatItemName(dialogData);
    final List<UserContact> partners = getPartnersData(dialogData.usersList);

    return InkWell(
      onTap: () async {
       await Future.delayed(Duration(milliseconds: 100));
        openChatScreen(
            context: context,
            userId: userId,
            partnerId: partners.first.id,
            dialogData: dialogData,
            username: userId == dialogData.usersList.first.id
                ? "${dialogData.usersList.last.firstname} ${dialogData.usersList.last.lastname}"
                : "${dialogData.usersList.first.firstname} ${dialogData.usersList.first.lastname}"
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
                child: dialogData.chatType.p2p == 1
                    ? AvatarWidget(userId: partners.first.id)
                    : AvatarWidget(userId: null)
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

class DialogsSkeletonWidget extends StatelessWidget {
  const DialogsSkeletonWidget({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, itemCount) =>
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: Color(0xDFDFDF),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: 16,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                            )
                          ],
                        )
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                    )
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

void dismissSlidableItem(
    BuildContext context, int index, SlidableActionEnum action) {
  // setState(() {
  //   items.removeAt(index);
  // });

  switch (action) {
    case SlidableActionEnum.pin:
      Utils.showSnackBar(context, 'Chat has been pined');
      break;
    case SlidableActionEnum.delete:
      Utils.showSnackBar(context, 'Chat has been deleted');
      break;
  }
}

bool isMessageReadByMe (List<MessageStatuses>? statuses, int userId) {
  if (statuses == null) return true;
  for (var statusObj in statuses) {
    if (statusObj.userId == userId && statusObj.statusId == 4) {
      return false;
    }
  }
  return true;
}

bool _isDialogActive(DialogData dialog, int userId) {
  bool isUserActive = false;
  for(var user in dialog.chatUsers!) {
    if (user.userId == userId && user.active == true) {
      isUserActive = true;
      return isUserActive;
    }
  }

  return isUserActive;
}





