import 'dart:async';
import 'dart:io';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/helpers.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/dialog_avatar_widget.dart';
import 'package:chat/ui/widgets/dialogs/dialog_item.dart';
import 'package:chat/ui/widgets/dialogs/dialog_search_widget.dart';
import 'package:chat/ui/widgets/dialogs/dialogs_skeleton.dart';
import 'package:chat/ui/widgets/search_widget.dart';
import 'package:chat/ui/widgets/unauthenticated_widget.dart';
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
  final _controller = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    presenceOnlineInfoChannelSubscription = BlocProvider.of<UsersViewCubit>(context).stream.listen((state) {
      setState(() {
        onlineMembers = state.onlineUsersDictionary;
        counter++;
      });
    });
    _readUserId().then((v) {
      userId = v;
    });
    super.initState();
  }

  Future<int?> _readUserId() async {
    final userIdFromStorage = await DataProvider().getUserId();
    return userIdFromStorage == null ? null : int.parse(userIdFromStorage);
  }

  void clearSearch() {
    searchController.text = "";
    BlocProvider.of<DialogsViewCubit>(context).search(searchController.text);
  }

  bool isMemberOnline(int id) {
    return onlineMembers[id] != null ? true : false;
  }

  void refreshAllData(){
    BlocProvider.of<DialogsViewCubit>(context).refreshAllDialogs();
    BlocProvider.of<ChatsBuilderBloc>(context).add(RefreshChatsBuilderEvent());
  }

  void searchDialog(String val) {
    BlocProvider.of<DialogsViewCubit>(context).search(val);
  }

  @override
  void dispose() {
    presenceOnlineInfoChannelSubscription.cancel();
    super.dispose();
  }

  Widget _mapStateToWidget(BuildContext context, DialogsViewCubitState state) {
    if (state is DialogsLoadedViewCubitState && userId != null) {
      if (!state.isFirstInitialized || state.isLoading) {
        return DialogsShimmer();
      }
      if (state.isError) {
        return ClientErrorHandler.makeErrorInfoWidget(state.errorType!, refreshAllData);
      }
      if (!state.isAuthenticated) {
        return const UnauthenticatedWidget();
      }
      if (state.dialogs.isEmpty) {
        return Center(
            key: UniqueKey(),
            child: Column(
              children: [
                CustomSearchWidget(controller: searchController, searchCallback: searchDialog, focusNode: focusNode),
                const Divider(height: 1, thickness: 1, color: Colors.black12),
                const Expanded(
                  child: Center(
                    child: Text("Нет диалогов")
                  )
                )
              ]
            )
        );
      } else{
        return Column(
          children: [
            CustomSearchWidget(controller: searchController, searchCallback: searchDialog, focusNode: focusNode),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            Expanded(
              child: RefreshIndicator(
                key: UniqueKey(),
                onRefresh: () async {
                  refreshAllData();
                },
                child: Scrollbar(
                  controller: _controller,
                  thumbVisibility: false,
                  thickness: 5,
                  trackVisibility: false,
                  radius: const Radius.circular(7),
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: CustomScrollView(
                    // controller: _controller,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                          !_isDialogActive(state.dialogs[index], userId!) ||
                              state.dialogs[index].chatType.typeId == 3 && !(state.dialogs[index].messageCount > 0)
                              ? const SizedBox.shrink()
                              : Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                            child: Align(
                              child: DialogItem(
                                clearSearch: clearSearch,
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
                ),
              ),
            ),
          ]
        );
      }
    } else {
      return DialogsShimmer();
    }
  }

  Widget DialogsShimmer() {
    return Container(
      key: UniqueKey(),
      child: Column(
        children: [
          CustomSearchWidget(controller: searchController, searchCallback: searchDialog, focusNode: focusNode),
          const Expanded(
              child: Shimmer(
                  child: ShimmerLoading(
                      child: DialogsSkeletonWidget()
                  )
              )
          )
        ],
      ) ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: BlocBuilder<DialogsViewCubit, DialogsViewCubitState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            switchOutCurve: const Threshold(0),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            duration: Duration(milliseconds: Platform.isIOS ? 100 : 200),
            child: _mapStateToWidget(context, state)
          );
        }),
    );
  }
}

// void dismissSlidableItem(BuildContext context, int index, SlidableActionEnum action) {
//   switch (action) {
//     case SlidableActionEnum.pin:
//       Utils.showSnackBar(context, 'Chat has been pined');
//       break;
//     case SlidableActionEnum.delete:
//       Utils.showSnackBar(context, 'Chat has been deleted');
//       break;
//   }
// }

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





