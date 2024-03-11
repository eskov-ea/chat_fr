import 'dart:async';
import 'dart:collection';
import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_event.dart';
import 'package:chat/bloc/messge_bloc/message_state.dart';
import 'package:chat/helpers.dart';
import 'package:chat/models/chat_builder_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/ui/widgets/action_bar/forward_message_alert_dialog.dart';
import 'package:chat/ui/widgets/message/message_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MessagesListStatefullWidget extends StatefulWidget {
  const MessagesListStatefullWidget({
    Key? key,
    required this.userId,
    required this.dialogData,
    required this.focusNode,
    required this.setReplyMessage,
    required this.users,
    required this.partnerName,
    required this.isSelectedMode,
    required this.setSelectedMode,
    required this.selected,
    required this.setSelected,
    required this.openForwardMenu,
    required this.deleteMessage,
    required this.scrollController,
  }) : super(key: key);

  final int userId;
  final DialogData dialogData;
  final FocusNode focusNode;
  final String partnerName;
  final Function(String, int, int, String)  setReplyMessage;
  final List<UserModel> users;
  final bool isSelectedMode;
  final Function setSelectedMode;
  final List<SelectedMessage> selected;
  final Function(SelectedMessage) setSelected;
  final Function(List<SelectedMessage>) openForwardMenu;
  final Function(List<int>) deleteMessage;
  final ScrollController scrollController;

  @override
  State<MessagesListStatefullWidget> createState() => _MessagesListStatefullWidgetState();
}

class _MessagesListStatefullWidgetState extends State<MessagesListStatefullWidget> {

  final messagesRepository = MessagesRepository();
  bool _shouldAutoscroll = true;
  bool isLoadingMessages = false;
  bool isConnectionThrottling = false;
  late final StreamSubscription _newMessagesSubscription;

  @override
  void dispose() {
    widget.scrollController.removeListener(() { setupScrollListener; });
    // _newMessagesSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //TODO: refacrot messageBloc
    setupScrollListener(
        scrollController: widget.scrollController,
        onAtTop: () {
          loadNextMessages();
        }
    );
  }

  void loadNextMessages() {
    //TODO: refacrot messageBloc
    BlocProvider.of<MessageBloc>(context).add(MessageBlocLoadNextPortionMessagesEvent(
      dialogId: widget.dialogData.dialogId
    ));
  }

  void resetMessagesAndReload() {
    setState(() {
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

  // void _onNewMessageReceived(WsBlocState state) {
  //   if (state is WsStateReceiveNewMessage) {
  //     if (state.message.dialogId == widget.dialogData.dialogId) {
  //       BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogData.dialogId));
  //     }
  //   }
  // }

  ChatsData? findChat(List<ChatsData> chats, int dialogId) {
    final it = chats.iterator;
    while(it.moveNext()) {
      if (it.current.chatId == dialogId) {
        return it.current;
      }
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessagesBlocState>(
      builder: (context, state) {

        BlocProvider.of<MessageBloc>(context).add(MessageBlocSendReadMessagesStatusEvent(dialogId: widget.dialogData.dialogId));

        if (state is MessageBlocInitializeInProgressState) {
          return const Center(child: CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeCap: StrokeCap.round,
            strokeWidth: 8.0,
          ));
        } else if (state is MessageBlocInitializationFailedState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Произошла ошибка при загрузке сообщений"),
              SizedBox(height: 10, width: MediaQuery.of(context).size.width),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<MessageBloc>(context).add(
                    MessageBlocReadMessagesFromDBEvent(dialogId: widget.dialogData.dialogId, page: widget.dialogData.lastPage!)
                  );
                },
                child: Text("Обновить"),
              )
            ],
          );
        } else if (state is MessageBlocInitializationSuccessState) {
          if (state.messages.isEmpty) {
            return const Center(child: Text('Нет сообщений'),);
          } else {
            return Column(
              children: [
                MessagesListWidget(
                    messages: state.messages,
                    scrollController: widget.scrollController,
                    userId: widget.userId,
                    dialogData: widget.dialogData,
                    focusNode: widget.focusNode,
                    users: widget.users,
                    partnerName: widget.partnerName,
                    setReplyMessage: widget.setReplyMessage,
                    isSelectedMode: widget.isSelectedMode,
                    setSelectedMode: widget.setSelectedMode,
                    selected: widget.selected,
                    setSelected: widget.setSelected,
                    openForwardMenu: widget.openForwardMenu,
                    deleteMessage: widget.deleteMessage
                )
              ],
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeCap: StrokeCap.round,
            strokeWidth: 8.0,
          ));
        }
      },
    );
  }
}


class MessagesListWidget extends StatelessWidget {
  final List<MessageData> messages;
  final ScrollController scrollController;
  final int userId;
  final DialogData dialogData;
  final FocusNode focusNode;
  final String partnerName;
  final Function(String, int, int, String)  setReplyMessage;
  final Function(List<int>)  deleteMessage;
  final bool isSelectedMode;
  final List<UserModel> users;
  final Function setSelectedMode;
  final Function(List<SelectedMessage>) openForwardMenu;
  final List<SelectedMessage> selected;
  final Function(SelectedMessage) setSelected;
  const MessagesListWidget({
    required this.messages,
    required this.scrollController,
    required this.userId,
    required this.dialogData,
    required this.focusNode,
    required this.partnerName,
    required this.setReplyMessage,
    required this.isSelectedMode,
    required this.setSelectedMode,
    required this.selected,
    required this.setSelected,
    required this.users,
    required this.openForwardMenu,
    required this.deleteMessage,
    super.key
  });

  String getSenderName(List<UserModel> users, senderId){
    if (senderId == 5) return "MCFEF Бот";
    String name = "Вы";
    //TODO: FOR EACh refactor users list to map
    users.forEach((user) {
      if (user.id == senderId) {
        name = "${user.lastname} ${user.firstname}";
      }
    });
    return name;
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            controller: scrollController,
            itemCount: messages.length,
            reverse: true,
            itemBuilder: (context, index) {

              final senderName = getSenderName(users, messages[index].senderId);

              return Column(
                children: [
                  if (index == messages.length - 1 ||
                      (index < messages.length - 1 &&
                          messages[index].messageDate !=
                              messages[index + 1].messageDate))
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          messages[index].messageDate,
                        ),
                      ),
                    ),
                  if (index == messages.length - 1 ||
                      (index < messages.length - 1 &&
                          messages[index].messageDate !=
                              messages[index + 1].messageDate))
                    SizedBox(
                      height: 8,
                    ),
                  MessageWidget(
                    key: ValueKey<int>(messages[index].messageId),
                    index: index,
                    senderId: messages[index].senderId,
                    userId: userId,
                    selected: selected,
                    selectedMode: isSelectedMode,
                    setSelectedMode: setSelectedMode,
                    setSelected: setSelected,
                    openForwardMenu: openForwardMenu,
                    messageId: messages[index].messageId,
                    message: messages[index].message,
                    messageDate: messages[index].messageDate,
                    messageTime: messages[index].messageTime,
                    focusNode: focusNode,
                    setReplyMessage: setReplyMessage,
                    status: Helpers.checkPartnerReadMessage(messages[index].statuses, userId),
                    file: messages[index].file,
                    p2p: dialogData.chatType.p2p,
                    forwardFrom: messages[index].forwarderFromUser,
                    senderName: senderName,
                    parentMessage: messages[index].repliedMessage,
                    isError: messages[index].isError,
                    repliedMsgSenderName: messages[index].repliedMessage != null ? getSenderName(users, messages[index].repliedMessage!.senderId) : null,
                    repliedMsgId: messages[index].repliedMessage?.parentMessageId,
                    dialogId: dialogData.dialogId,
                    deleteMessage: deleteMessage
                  )
                ],
              );
            }
          ),
        )
      ),
    );
  }
}
