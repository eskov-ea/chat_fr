import 'dart:async';
import 'dart:io';

import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_state.dart';
import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
import 'package:chat/bloc/ws_bloc/ws_state.dart';
import 'package:chat/helpers.dart';
import 'package:chat/models/chat_builder_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/messages/messages_repository.dart';
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
    required this.usersCubit,
    required this.partnerName,
    required this.isSelectedMode,
    required this.setSelectedMode,
    required this.selected,
    required this.setSelected,
    required this.openForwardMenu,
  }) : super(key: key);

  final int userId;
  final DialogData dialogData;
  final FocusNode focusNode;
  final String partnerName;
  final Function(String, int, int, String)  setReplyMessage;
  final UsersViewCubit usersCubit;
  final bool isSelectedMode;
  final Function setSelectedMode;
  final List<int> selected;
  final Function(int) setSelected;
  final Function(String, String, MessageAttachmentsData?) openForwardMenu;

  @override
  State<MessagesListStatefullWidget> createState() => _MessagesListStatefullWidgetState();
}

class _MessagesListStatefullWidgetState extends State<MessagesListStatefullWidget> {

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
          else if ( currentState.messages.isEmpty) {
            return const Center(child: Text('Нет сообщений'),);
          } else {
            return Column(
              children: [
                MessagesListWidget(
                    messages: currentState.messages,
                    scrollController: _scrollController,
                    userId: widget.userId,
                    dialogData: widget.dialogData,
                    focusNode: widget.focusNode,
                    users: widget.usersCubit.state.users,
                    partnerName: widget.partnerName,
                    setReplyMessage: widget.setReplyMessage,
                    isSelectedMode: widget.isSelectedMode,
                    setSelectedMode: widget.setSelectedMode,
                    selected: widget.selected,
                    setSelected: widget.setSelected,
                    openForwardMenu: widget.openForwardMenu
                )
              ],
            );
          }
        } else {
          return const Center(child: Text('Загрузка...'),);
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
  final bool isSelectedMode;
  final List<UserContact> users;
  final Function setSelectedMode;
  final Function(String, String, MessageAttachmentsData?) openForwardMenu;
  final List<int> selected;
  final Function(int) setSelected;
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
    super.key
  });

  String getSenderName(List<UserContact> users, senderId){
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
                  status: Helpers.checkPartnerReadMessage(messages[index].status, userId),
                  file: messages[index].file,
                  p2p: dialogData.chatType.p2p,
                  forwardFrom: messages[index].forwarderFromUser,
                  senderName: senderName,
                  parentMessage: messages[index].parentMessage,
                  isError: messages[index].isError,
                  repliedMsgSenderName: messages[index].parentMessage != null ? senderName : null,
                  repliedMsgId: messages[index].parentMessage?.parentMessageId,
                  dialogId: dialogData.dialogId,
                  isErrorHandling: messages[index].isHandling,
                )
              ],
            );
          }
        )
      ),
    );
  }
}
