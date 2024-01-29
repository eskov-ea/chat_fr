import 'dart:async';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/helpers.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/dialog_avatar_widget.dart';
import 'package:chat/ui/widgets/dialogs/dialog_item.dart';
import 'package:chat/ui/widgets/dialogs/dialogs_skeleton.dart';
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

  void refreshAllData(){
    BlocProvider.of<DialogsViewCubit>(context).refreshAllDialogs();
    BlocProvider.of<ChatsBuilderBloc>(context).add(RefreshChatsBuilderEvent());
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
            if (state.isError) {
              return ClientErrorHandler.makeErrorInfoWidget(state.errorType!, refreshAllData);
            }
            if (state.dialogs.isEmpty) {
              return const Center(child: Text("Нет диалогов"),);
            } else{
              return RefreshIndicator(
                onRefresh: () async {
                  refreshAllData();
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
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                                child: Align(
                                  child: DialogItem(
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
                                      picture: state.dialogs[index].picture,
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
            return RefreshIndicator(
              onRefresh: () async {
                refreshAllData();
              },
              child: Container(
                child: const Shimmer(
                  child: ShimmerLoading(
                    child: DialogsSkeletonWidget()
                  )
                ),
              )
            );
          }
        }),
    );
  }
}

void dismissSlidableItem(BuildContext context, int index, SlidableActionEnum action) {
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





