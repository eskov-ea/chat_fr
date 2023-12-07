import 'dart:async';
import 'dart:ui';
import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
import 'package:chat/helpers.dart';
import 'package:chat/models/chat_builder_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/theme.dart';
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
import '../../services/messages/messages_api_provider.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/user/users_view_cubit_state.dart';
import '../widgets/action_bar.dart';
import '../widgets/chat_screen_call_button.dart';
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

  bool isOnline = false;
  bool isTyping = false;
  late final StreamSubscription usersViewCubitStateSubscription;

  @override
  void initState() {

    setState(() {
      isOnline = BlocProvider.of<UsersViewCubit>(context).state.onlineUsersDictionary[widget.partnerId] != null;
    });
    usersViewCubitStateSubscription = BlocProvider.of<UsersViewCubit>(context).stream.listen((state) {
      setState(() {
        isOnline = state.onlineUsersDictionary[widget.partnerId] != null ? true : false;
        isTyping = state.clientEvent[widget.dialogData?.dialogId] != null && state.clientEvent[widget.dialogData?.dialogId]?.event == "typing";
      });
    });
    focusNode.addListener(() {
      if(focusNode.hasFocus) {
        _sendTypingEvent();
      } else {
        _sendFinishTypingEvent();
      }
    });
   super.initState();
  }
  void _sendTypingEvent() async {
    while (BlocProvider.of<WsBloc>(context).presenceChannel == null) {
      await Future.delayed(const Duration(seconds: 3));
    }
    BlocProvider.of<WsBloc>(context).presenceChannel!.trigger(eventName: "client-user-event",
        data: {"dialogId" : widget.dialogData?.dialogId, "event" : "typing", "fromUser" : widget.userId, "toUser": widget.partnerId});
  }

  void _sendFinishTypingEvent() async {
    while (BlocProvider.of<WsBloc>(context).presenceChannel == null) {
      await Future.delayed(const Duration(seconds: 3));
    }
    BlocProvider.of<WsBloc>(context).presenceChannel!.trigger(eventName: "client-user-event",
        data: {"dialogId" : widget.dialogData?.dialogId, "event" : "finish_typing", "fromUser" : widget.userId, "toUser": widget.partnerId});
  }



  final focusNode = FocusNode();
  String? replyMessage;
  bool isRecording = false;
  String? senderReplyName;
  int? replyedMessageId;
  ParentMessage? replyedParentMsg;
  bool isSelectedMode = false;
  List<int> selected = [];

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

  void setSelectedMode(bool value){
    setState(() {
      isSelectedMode = value;
      if (!value) selected = [];
    });
  }

  void deleteMessages() async {
    try {
      final bool response =
          await MessagesProvider().deleteMessage(messageId: selected);
      if (response) {
        BlocProvider.of<ChatsBuilderBloc>(context).add(
            ChatsBuilderDeleteMessagesEvent(
                messagesId: selected, dialogId: widget.dialogData!.dialogId));
      } else {
        customToastMessage(context: context, message: 'Не получилось удалить сообщения. Попробуйте еще раз');
      }
    } catch (err) {
      customToastMessage(context: context, message: 'Не получилось удалить сообщения. Попробуйте еще раз');
    }
  }

  void setSelected(id) {
    setState(() {
      if (isSelectedMode) {
        if (!selected.contains(id)) {
          selected.add(id);
        } else {
          selected.remove(id);
        }
        if (selected.isEmpty) setSelectedMode(false);
      }
      print(selected);
    });
  }

  Widget getDialogName(DialogData? dialog, String username) {
    if (widget.dialogData?.chatType.p2p == 1 || widget.dialogData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            username,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700)
          ),
          if(isOnline) Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12),
              SizedBox(width: 10,),
              Text(
                isTyping ? "Набирает сообщение..." : "Online",
                style: TextStyle(color: Colors.black, fontSize: 14)
              )
            ],
          )
        ],
      );
    }
    return Text(
      dialog!.name,
      style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700)
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    usersViewCubitStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void setDialogData (widget, dialogData) {
      setState(() {
        widget.dialogData = dialogData;
      });
    }

    return Scaffold(
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
              openUserProfileInfoPage(context: context, user: findPartnerUserProfile(widget.usersCubit, widget.partnerId), partnerId: widget.partnerId);
            } else {
              openGroupChatInfoPage(context: context, usersCubit: widget.usersCubit, dialogData: widget.dialogData, userId: null, dialogCubit: widget.dialogCubit, username: widget.username, partnerId: widget.partnerId, );
            }
          },
          child: getDialogName(widget.dialogData, widget.username),
        ),
        actions: [
          if (isSelectedMode) GestureDetector(
            onTap: (){
              setSelectedMode(false);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: Text('Отменить',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          if (!isSelectedMode && !kIsWeb && ( widget.dialogData == null || widget.dialogData!.chatType.p2p == 1)) Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CallButton(partnerId: widget.partnerId)
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.backgroundLight,
        child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/chat_background.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: widget.dialogData?.dialogId != null
                              ? _MessageList(
                            userId: widget.userId,
                            dialogData: widget.dialogData!,
                            focusNode: focusNode,
                            setReplyMessage: setReplyMessage,
                            usersCubit: widget.usersCubit,
                            partnerName: widget.username,
                            setSelectedMode: setSelectedMode,
                            isSelectedMode: isSelectedMode,
                            selected: selected,
                            setSelected: setSelected
                          )
                              : const Center(child: Text('Нет сообщений'),)
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
                  isUserAllowedToWrite(widget.dialogData, widget.userId)
                    ? ActionBar(userId: widget.userId, partnerId: widget.partnerId, dialogId: widget.dialogData?.dialogId,
                        setDialogData: setDialogData, rootWidget: widget, username: widget.username,
                        focusNode: focusNode, setRecording: setRecording, isRecording: isRecording, dialogData: widget.dialogData,
                        dialogCubit: widget.dialogCubit, cancelReplyMessage: cancelReplyMessage, parentMessage: replyedParentMsg, isSelectedMode: isSelectedMode,
                        selected: selected, deleteMessages: deleteMessages
                      )
                    : ReadOnlyChannelMode(context)
                ],
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
    required this.isSelectedMode,
    required this.setSelectedMode,
    required this.selected,
    required this.setSelected,
  }) : super(key: key);

  final int userId;
  final DialogData dialogData;
  final FocusNode focusNode;
  final String partnerName;
  final  setReplyMessage;
  final UsersViewCubit usersCubit;
  final bool isSelectedMode;
  final Function setSelectedMode;
  final List<int> selected;
  final Function(int) setSelected;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {

  final messagesRepository = MessagesRepository();
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoscroll = true;
  int pageNumber = 1;
  bool isLoadingMessages = false;
  bool isConnectionThrottling = false;
  late final StreamSubscription _newMessagesSubscription;

  @override
  void dispose() {
    _scrollController.removeListener(() { setupScrollListener; });
    _newMessagesSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // In development if we hot restart the app the yielded state in stream are not reachable
    _newMessagesSubscription = BlocProvider.of<WsBloc>(context).stream.listen(_onNewMessageReceived);
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogData.dialogId));
    setupScrollListener(
      scrollController: _scrollController,
      onAtTop: () {
        print("Loaded messages:   onAtTop    $pageNumber");
        loadNextMessages();
      }
    );
  }

  void loadNextMessages() {
    if (!BlocProvider.of<ChatsBuilderBloc>(context).state.isError) {
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderLoadMessagesEvent(
              dialogId: widget.dialogData.dialogId, pageNumber: pageNumber));
      pageNumber++;
    }
  }

  void resetMessagesAndReload() {
    setState(() {
      pageNumber = 1;
      isLoadingMessages = true;
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

  void _onNewMessageReceived(WsBlocState state) {
    if (state is WsStateReceiveNewMessage) {
      if (state.message.dialogId == widget.dialogData.dialogId) {
        BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogData.dialogId));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBuilderBloc, ChatsBuilderState>(
          builder: (context, state) {
            if (state is ChatsBuilderState) {
              print("Finding chats:   ${state.chats}");
              final ChatsData? currentState = findChat(state.chats, widget.dialogData.dialogId);
              if (state.isError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Произошла ошибка при загрузке сообщений"),
                    SizedBox(height: 10, width: MediaQuery.of(context).size.width),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<ChatsBuilderBloc>(context).add(
                            ChatsBuilderLoadMessagesEvent(
                                dialogId: widget.dialogData.dialogId, pageNumber: pageNumber));
                        pageNumber++;
                      },
                      child: Text("Обновить"),
                    )
                  ],
                );
              }
              if (currentState == null) {
                loadNextMessages();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      // Transform.translate(
                      //   offset: isConnectionThrottling ? const Offset(0, 50) : const Offset(0, -150),
                      //   child: const Text("Данные загружаются подозрительно долго, возможно причина в Интернет-подключении",
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(fontSize: 16),
                      //   ),
                      // ),
                      // Transform.translate(
                      //   offset: isConnectionThrottling ? const Offset(0, 80) : const Offset(0, -180),
                      //   child: ElevatedButton(
                      //     onPressed: () { loadNextMessages(); },
                      //     child: const Text("Обновить"),
                      //   ),
                      // )
                    ],
                  ),
                );
              }
              if ( currentState.messages.isEmpty) return const Center(child: Text('Нет сообщений'),);
              return Stack(
                children: [
                  Padding(
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
                            if (index == currentState.messages.length -1 || (index < currentState.messages.length -1 &&
                                currentState.messages[index].messageDate != currentState.messages[index+1].messageDate))
                              SizedBox(
                                height: 8,
                              ),
                            MessageWidget(
                              key: ValueKey<int>(currentState.messages[index].messageId),
                              index: index,
                              senderId: currentState.messages[index].senderId,
                              userId: widget.userId,
                              selected: widget.selected,
                              selectedMode: widget.isSelectedMode,
                              setSelectedMode: widget.setSelectedMode,
                              setSelected: widget.setSelected,
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
                              isError: currentState.messages[index].isError,
                              repliedMsgSenderName: currentState.messages[index].parentMessage != null
                                  ? getSenderName(widget.usersCubit.state.users, currentState.messages[index].parentMessage?.senderId)
                                  : null,
                              repliedMsgId: currentState.messages[index].parentMessage?.parentMessageId,
                              dialogId: widget.dialogData.dialogId,
                            )
                          ],
                        );
                      }),
                  ),

                  // state.isLoadingMessages
                  // ?  Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       CircularProgressIndicator(),
                  //       SizedBox(width: 30,),
                  //       ElevatedButton(
                  //         onPressed: (){},
                  //         child: Text("Обновить")
                  //       )
                  //     ],
                  // )
                  // :   const SizedBox.shrink()
                ]
              );
            // );
          } else {
              return const Center(child: Text('Загрузка...'),);
            }
          },
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
                  Text(senderName,
                    style: TextStyle(
                        color: Color(0xFFC07602)
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    replyMessage,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white70
                    ),
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

Widget ReadOnlyChannelMode(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    height: 30,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(width: 1, color: Color(0xFFCCD9FD)),
      color: const Color(0xFFE7EDFF)
    ),
    child: const Center(
      child: Text("В режиме чтения",
        style: TextStyle(fontSize: 16, color: Color(0xFF575757)),
      ),
    ),
  );
}

bool isUserAllowedToWrite(DialogData? dialogData, int userId) {
  if(dialogData == null) return true;
  if (dialogData.chatType.typeName != "Групповой для чтения") {
    return true;
  } else {
    for(var i=0; i < dialogData.chatUsers.length; ++i) {
      if(dialogData.chatUsers[i].userId == userId &&
          dialogData.chatUsers[i].chatUserRole == 1) {
        return true;
      }
    }
    return false;
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
  final int? userId;
  final int partnerId;
  final DialogData? dialogData;
  final String username;
  DialogsViewCubit dialogCubit;
  UsersViewCubit usersCubit;

  ChatPageArguments({required this.userId, required this.partnerId,
    required this.dialogData, required this.username, required this.dialogCubit, required this.usersCubit});
}

String? getSenderName(usersCubit, senderId){
  if (senderId == 5) return "MCFEF Бот";
  String name = "Вы";
  usersCubit.forEach((user) {
    if (user.id == senderId) {
      name = "${user.lastname} ${user.firstname}";
    }
  });
  return name;
}
