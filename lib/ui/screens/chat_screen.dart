import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/action_bar/forward_message_alert_dialog.dart';
import 'package:chat/ui/widgets/message/mesasges_list.dart';
import 'package:chat/ui/widgets/message/reply_message_bar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../models/contact_model.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/helpers/navigation_helpers.dart';
import '../../services/messages/messages_api_provider.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/user/users_view_cubit_state.dart';
import '../widgets/action_bar/action_bar.dart';
import '../widgets/chat_screen_call_button.dart';
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

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {

  bool isOnline = false;
  bool isTyping = false;
  late AnimationController _animationController;
  late Animation animation;
  late final StreamSubscription usersViewCubitStateSubscription;
  String? forwardingText;
  String? forwardingTextAuthor;
  MessageAttachmentsData? forwardingFile;


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

    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400)
    )..addListener(() {
      setState(() {});
    });

    animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn)
    );

   super.initState();
  }

  void closeForwardMenu() {
    forwardingText = null;
    forwardingTextAuthor = null;
    forwardingFile = null;
    setState(() {});
    _animationController.reverse();
  }
  void openForwardMenu(String text, String author, MessageAttachmentsData? file) {
    forwardingText = text;
    forwardingTextAuthor = author;
    forwardingFile = file;
    setState(() {});
    _animationController.forward();
  }

  void _sendTypingEvent() async {
    if (widget.dialogData?.dialogId != null) {
      while (BlocProvider.of<WsBloc>(context).presenceChannel == null) {
        await Future.delayed(const Duration(seconds: 3));
      }
      BlocProvider.of<WsBloc>(context).presenceChannel!.trigger(eventName: "client-user-event",
          data: {"dialogId" : widget.dialogData?.dialogId, "event" : "typing", "fromUser" : widget.userId, "toUser": widget.partnerId});
    }

  }

  void _sendFinishTypingEvent() async {
    if (widget.dialogData?.dialogId != null) {
      while (BlocProvider.of<WsBloc>(context).presenceChannel == null) {
        await Future.delayed(const Duration(seconds: 3));
      }
      BlocProvider.of<WsBloc>(context).presenceChannel!.trigger(eventName: "client-user-event",
          data: {"dialogId" : widget.dialogData?.dialogId, "event" : "finish_typing", "fromUser" : widget.userId, "toUser": widget.partnerId});
    }
  }



  final focusNode = FocusNode();
  String? replyMessage;
  bool isRecording = false;
  String? senderReplyName;
  int? replyedMessageId;
  ParentMessage? replyedParentMsg;
  bool isSelectedMode = false;
  List<int> selected = [];


  void setReplyMessage(String message, int senderId, int messageId, String senderName) {
    setState(() {
      replyMessage = message;
      replyedMessageId = messageId;
      senderReplyName = senderName;
      replyedParentMsg = ParentMessage.toJson(parentMessageText: message, parentMessageId: messageId, senderId: senderId);
    });
  }

  void cancelReplyMessage() {
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
    _animationController.dispose();
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColors.backgroundLight,
        child: Stack(
          children: [
            Column(
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
                              ? MessagesListStatefullWidget(
                              userId: widget.userId,
                              dialogData: widget.dialogData!,
                              focusNode: focusNode,
                              setReplyMessage: setReplyMessage,
                              usersCubit: widget.usersCubit,
                              partnerName: widget.username,
                              setSelectedMode: setSelectedMode,
                              isSelectedMode: isSelectedMode,
                              selected: selected,
                              setSelected: setSelected,
                              openForwardMenu: openForwardMenu
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
                if (replyMessage != null) ReplyMessageBar(replyMessage: replyMessage!, cancelReplyMessage: cancelReplyMessage, senderName: senderReplyName!),
                isUserAllowedToWrite(widget.dialogData, widget.userId)
                    ? ActionBar(userId: widget.userId, partnerId: widget.partnerId, dialogId: widget.dialogData?.dialogId,
                    setDialogData: setDialogData, rootWidget: widget, username: widget.username,
                    focusNode: focusNode, setRecording: setRecording, isRecording: isRecording, dialogData: widget.dialogData,
                    dialogCubit: widget.dialogCubit, cancelReplyMessage: cancelReplyMessage, parentMessage: replyedParentMsg, isSelectedMode: isSelectedMode,
                    selected: selected, deleteMessages: deleteMessages
                )
                    : ReadOnlyChannelMode(context),
              ],
            ),
            ForwardMessageAlertDialog(userId: widget.userId, animationController: _animationController, animation: animation, close: closeForwardMenu,
              forwardingText: forwardingText, forwardingTextAuthor: forwardingTextAuthor, forwardingFile: forwardingFile,
            )
          ]
        )
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

UserContact? findPartnerUserProfile(UsersViewCubit usersCubit, int partnerId) {
  UserContact? user;
  if (usersCubit.state is UsersViewCubitLoadedState) {
    final state =  usersCubit.state as UsersViewCubitLoadedState;
    for (final u in state.users) {
      if (u.id == partnerId) {
        user = u;
        return user;
      }
    }
  }
  return user;
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


