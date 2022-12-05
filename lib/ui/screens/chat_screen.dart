import 'dart:ui';
import 'package:chat/helpers.dart';
import 'package:chat/models/chat_builder_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ws_bloc/ws_state.dart';
import '../../../services/messages/messages_repository.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../bloc/chats_builder_bloc/chats_builder_state.dart';
import '../../models/contact_model.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/helpers/navigation_helpers.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/user/users_view_cubit_state.dart';
import '../widgets/action_bar.dart';
import '../widgets/message_widget.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';


class ChatScreen extends StatefulWidget {

  static Route route(
          {required userId,
          required partnerId,
          required dialogData,
          required username,
          required dialogCubit,
          required usersCubit
          }) =>
      MaterialPageRoute(
        builder: (context) => ChatScreen(
            dialogData: dialogData,
            userId: userId,
            partnerId: partnerId,
            username: username,
            dialogCubit: dialogCubit,
            usersCubit: usersCubit
        ),
      );

  ChatScreen({
    Key? key,
    required this.dialogCubit,
    required this.usersCubit,
    required this.dialogData,
    required this.username,
    required this.userId,
    required this.partnerId,
  }) : super(key: key);

  DialogsViewCubit dialogCubit;
  UsersViewCubit usersCubit;
  final int userId;
  final int partnerId;
  final String username;
  DialogData? dialogData;


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  void initState() {
    print("usernameusername ${widget.username}");
    super.initState();
  }


  final focusNode = FocusNode();
  String? replyMessage;
  bool isRecording = false;
  String? senderReplyName;
  int? replyedMessageId;
  ParentMessage? replyedParentMsg;

  Function? setReplyMessage(message, senderId, messageId) {
    setState(() {
      replyMessage = message;
      replyedMessageId = messageId;
      senderReplyName = getSenderName(widget.usersCubit.state.users, senderId);
      replyedParentMsg = ParentMessage.toJson(parentMessageText: message, parentMessageId: messageId, senderId: senderId);
    });
  }
  Function? cancelReplyMessage() {
    setState(() {
      replyMessage = null;
      senderReplyName = null;
      replyedMessageId = null;
      replyedParentMsg = null;
    });
  }
  void setRecording(bool value){
    setState(() {
      isRecording = value;
    });
  }


  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void setDialogData (widget, dialogData) {
      setState(() {
        widget.dialogData = dialogData;
      });
    }

    return GestureDetector(
      onTap: (){
        focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          centerTitle: false,
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          leadingWidth: 54,
          leading: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, color: AppColors.secondary, size: 30,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: InkWell(
            onTap: (){
              if (widget.dialogData == null || widget.dialogData?.chatType.p2p == 1) {
                openUserProfileInfoPage(context: context, user: findPartnerUserProfile(widget.usersCubit, widget.partnerId));
              } else {
                openGroupChatInfoPage(context: context, usersCubit: widget.usersCubit, dialogData: widget.dialogData, userId: null, dialogCubit: widget.dialogCubit, username: widget.username, partnerId: widget.partnerId, );
              }
            },
            child: Text(
              widget.dialogData?.chatType.p2p == 1 || widget.dialogData == null
                ? widget.username
                : widget.dialogData!.name,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            if (widget.dialogData == null || widget.dialogData?.chatType.p2p == 1 && !kIsWeb) IconButton(
              icon: const Icon(CupertinoIcons.video_camera, color: AppColors.secondary, size: 38,),
              onPressed: () {},
            ),
            if ((widget.dialogData == null && !kIsWeb) || (widget.dialogData!.chatType.p2p == 1 && !kIsWeb)) Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: const Icon(CupertinoIcons.phone, color: AppColors.secondary, size: 30,),
                onPressed: () {
                  callNumber(context ,widget.partnerId);
                },
              ),
            ),
          ],
        ),
        body: Container(
          color: AppColors.backgroundChatScreen,
          child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            child: widget.dialogData?.dialogId != null
                                ? _MessageList(
                              userId: widget.userId,
                              dialogData: widget.dialogData!,
                              focusNode: focusNode,
                              setReplyMessage: setReplyMessage,
                              usersCubit: widget.usersCubit,
                              partnerName: widget.username,
                            )
                                : const Center(child: Text('No messages yet'),)
                          ),
                          if (isRecording == true ) Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                child: Container(
                                  color: Colors.black12,
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    if (replyMessage != null) _ReplyMessageBar(replyMessage: replyMessage!, cancelReplyMessage: cancelReplyMessage, senderName: senderReplyName!,),
                    ActionBar(userId: widget.userId, partnerId: widget.partnerId, dialogId: widget.dialogData?.dialogId,
                      setDialogData: setDialogData, rootWidget: widget, username: widget.username,
                      focusNode: focusNode, setRecording: setRecording, isRecording: isRecording, replyedMessageId: replyedMessageId, dialogData: widget.dialogData,
                      dialogCubit: widget.dialogCubit, cancelReplyMessage: cancelReplyMessage, parentMessage: replyedParentMsg,),
                  ],
                ),
        ),
      ),
    );
  }
}


class _MessageList extends StatefulWidget {
  const _MessageList({
    Key? key,
    required this.userId,
    required this.dialogData,
    required this.focusNode,
    required this.setReplyMessage,
    required this.usersCubit,
    required this.partnerName,
  }) : super(key: key);

  final int userId;
  final DialogData dialogData;
  final FocusNode focusNode;
  final String partnerName;
  final  setReplyMessage;
  final UsersViewCubit usersCubit;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {

  final messagesRepository = MessagesRepository();
  List selected = [];
  bool selectedMode = false;
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoscroll = true;
  int pageNumber = 1;
  bool isLoading = false;

  @override
  void dispose() {
    _scrollController.removeListener(() { setupScrollListener; });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogData.dialogId));
    setupScrollListener(
      scrollController: _scrollController,
      onAtTop: () {
        loadNextMessages();
      }
    );
  }

  void loadNextMessages() {
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderLoadMessagesEvent(dialogId: widget.dialogData.dialogId, pageNumber: pageNumber));
    pageNumber++;
  }
  void _setSelected(id) {
    setState(() {
      if (selectedMode) {
        if (!selected.contains(id)) {
          selected.add(id);
        } else {
          selected.remove(id);
        }
        if (selected.isEmpty) selectedMode = false;
      }
      print(selected);
    });
  }

  void setupScrollListener(
      {required ScrollController scrollController,
        Function? onAtTop}) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        // Reach the top of the list
        if (scrollController.position.pixels != 0) {
          onAtTop?.call();
        }
      }
    });
  }


  void _setSelectedMode() {
    if (!selectedMode) selectedMode = true;
  }

  void onMessagesStateChange(BuildContext context, WsBlocState state) {
    if (state is WsStateReceiveNewMessage) {
      // if (_shouldAutoscroll == true) _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBuilderBloc, ChatsBuilderState>(
          builder: (context, state) {
            if (state is ChatsBuilderState) {
              final ChatsData? currentState = findChat(state.chats, widget.dialogData.dialogId);
              print("Current state   ${state.chats},   ${state.chats.length}");
              print("Current chat   $currentState,  ${currentState?.messages.length}");
              if (currentState == null) {
                BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderLoadMessagesEvent(dialogId: widget.dialogData.dialogId, pageNumber: pageNumber));
                pageNumber++;
                return const Center(child: CircularProgressIndicator(),);
              }
              if ( currentState.messages.isEmpty) return const Center(child: Text('No messages yet'),);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: currentState.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          if (index == currentState.messages.length -1 || (index < currentState.messages.length -1 &&
                              currentState.messages[index].messageDate != currentState.messages[index+1].messageDate))
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white54,
                                borderRadius:  BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text(
                                    currentState.messages[index].messageDate,
                                ),
                              ),
                            ),
                          MessageWidget(
                            index: index,
                            senderId: currentState.messages[index].senderId,
                            userId: widget.userId,
                            selected: selected,
                            selectedMode: selectedMode,
                            setSelectedMode: _setSelectedMode,
                            setSelected: _setSelected,
                            messageId: currentState.messages[index].messageId,
                            message: currentState.messages[index].message,
                            messageDate: currentState.messages[index].messageDate,
                            messageTime: currentState.messages[index].messageTime,
                            focusNode: widget.focusNode,
                            setReplyMessage: widget.setReplyMessage,
                            status: Helpers.checkPartnerReadMessage(currentState.messages[index].status, widget.userId),
                            file: currentState.messages[index].file,
                            p2p: widget.dialogData.chatType.p2p,
                            senderName: getSenderName(widget.usersCubit.state.users, currentState.messages[index].senderId),
                            parentMessage: currentState.messages[index].parentMessage,
                            repliedMsgSenderName: currentState.messages[index].parentMessage != null
                                  ? getSenderName(widget.usersCubit.state.users, currentState.messages[index].parentMessage?.senderId)
                                  : null
                          )
                        ],
                      );
                    }),
              );
            // );
          } else {
              return const Center(child: Text('Loading...'),);
            }
          },
    );
  }
}

class _DateLable extends StatelessWidget {
  const _DateLable({
    Key? key,
    required this.lable,
  }) : super(key: key);

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
            child: Text(
              lable,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Avatar.small(
          url: "messageData.profilePicture",
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "messageData.senderData.senderName",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              const Text(
                'Online now',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}


class _ReplyMessageBar extends StatelessWidget {
  const _ReplyMessageBar({
    required this.replyMessage,
    required this.senderName,
    required this.cancelReplyMessage,
    Key? key
  }) : super(key: key);

  final String replyMessage;
  final String senderName;
  final cancelReplyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff343434),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0)
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 25),
            child: Icon(Icons.subdirectory_arrow_left),
          ),
          Container(
            color: Colors.blueAccent,
            width: 3,
            height: 30,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8 ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(senderName),
                  const SizedBox(height: 5,),
                  Text(
                    replyMessage,
                    maxLines: 1,
                  ),
                ]
              ),
            ),
          ),
          IconButton(
            onPressed: (){
              cancelReplyMessage();
            },
            icon: const Icon(Icons.close)
          )
        ],
      ),
    );
  }
}

ChatsData? findChat(List<ChatsData> chats, int dialogId) {
  final it = chats.iterator;
  while(it.moveNext()) {
    if (it.current.chatId == dialogId) {
      return it.current;
    }
  }
  return null;
}

UserContact? findPartnerUserProfile(UsersViewCubit usersCubit, int partnerId) {
  if (usersCubit.state is UsersViewCubitLoadedState) {
    final state =  usersCubit.state as UsersViewCubitLoadedState;
    final user = state.users.firstWhere((element) => element.id == partnerId);
    print(user);
    return user;
  }
  return null;
}


class ChatPageArguments {
  final int userId;
  final int partnerId;
  final DialogData? dialogData;
  final String username;
  DialogsViewCubit dialogCubit;
  UsersViewCubit usersCubit;

  ChatPageArguments({required this.userId, required this.partnerId,
    required this.dialogData, required this.username, required this.dialogCubit, required this.usersCubit});
}

String? getSenderName(usersCubit, senderId){
  String name = "Вы";
  usersCubit.forEach((user) {
    if (user.id == senderId) {
      name = "${user.lastname} ${user.firstname}";
    }
  });
  return name;
}
