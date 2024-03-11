import 'dart:async';
import 'dart:ui';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_event.dart';
import 'package:chat/bloc/user_bloc/online_users_manager.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/navigation_helpers.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/action_bar/action_bar.dart';
import 'package:chat/ui/widgets/action_bar/forward_message_alert_dialog.dart';
import 'package:chat/ui/widgets/chat_screen_call_button.dart';
import 'package:chat/ui/widgets/message/mesasges_list.dart';
import 'package:chat/ui/widgets/message/reply_message_bar_widget.dart';
import 'package:chat/ui/widgets/web_container_wrapper.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';


class ChatScreen extends StatefulWidget {

  static Route route(
          {required userId,
          required partnerId,
          required dialogData,
          required username,
          required dialogCubit,
          required users
          }) =>
      MaterialPageRoute(
        builder: (context) => ChatScreen(
            dialogData: dialogData,
            userId: userId,
            partnerId: partnerId,
            username: username,
            dialogCubit: dialogCubit,
            users: users
        ),
      );

  ChatScreen({
    Key? key,
    required this.dialogCubit,
    required this.users,
    required this.dialogData,
    required this.username,
    required this.userId,
    required this.partnerId,
  }) : super(key: key);

  DialogsViewCubit dialogCubit;
  final List<UserModel> users;
  final int userId;
  final int partnerId;
  final String username;
  DialogData? dialogData;


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  bool isOnline = false;
  bool isTyping = false;
  late AnimationController _forwardMenuAnimationController;
  late Animation _forwardMenuAnimation;
  late AnimationController _selectedMessagesOptionsMenuAnimationController;
  late Animation _selectedMessagesOptionsMenuAnimation;
  List<SelectedMessage>? forwardingMessages;
  final focusNode = FocusNode();
  String? replyMessage;
  bool isRecording = false;
  String? senderReplyName;
  int? replyedMessageId;
  RepliedMessage? replyedParentMsg;
  bool isSelectedMode = false;
  List<SelectedMessage> selected = [];
  final ScrollController scrollController = ScrollController();
  final _userStatusManager = UserOnlineStatusManager.instance;
  late final StreamSubscription<Map<int, bool>> usersStatusEventSubscription;
  late final StreamSubscription<ClientUserEvent> usersClientEventSubscription;

  int currentPage = 1;


  @override
  void initState() {

    if (widget.dialogData != null) {
      BlocProvider.of<MessageBloc>(context).add(MessageBlocLoadMessagesEvent(dialogId: widget.dialogData!.dialogId));
    }
    setState(() {
      isOnline = _userStatusManager.onlineUsers[widget.partnerId] == true;
    });
    usersClientEventSubscription = _userStatusManager.event.listen((event) {
      if (event.dialogId == widget.dialogData?.dialogId) {
        setState(() {
          isTyping = event.toUser == widget.userId && event.event == 'typing';
        });
      }
    });
    usersStatusEventSubscription = _userStatusManager.status.listen((event) {
      final status = event[widget.userId];
      if (status != null && isOnline != status) {
        setState(() {
          isOnline = status;
        });
      }
    });
    focusNode.addListener(() {
      if(focusNode.hasFocus) {
        _sendTypingEvent();
      } else {
        _sendFinishTypingEvent();
      }
    });

    _forwardMenuAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400)
    )..addListener(() {
      setState(() {});
    });
    _selectedMessagesOptionsMenuAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400)
    )..addListener(() {
      setState(() {});
    });

    _forwardMenuAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _forwardMenuAnimationController, curve: Curves.fastOutSlowIn)
    );
    _selectedMessagesOptionsMenuAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _forwardMenuAnimationController, curve: Curves.fastOutSlowIn)
    );

   super.initState();
  }

  void closeForwardMenu() {
    forwardingMessages = null;
    setState(() {});
    _forwardMenuAnimationController.reverse();
  }
  void openForwardMenu(List<SelectedMessage> messages) {
    forwardingMessages = messages;
    setState(() {});
    _forwardMenuAnimationController.forward();
  }

  void _sendTypingEvent() async {
    if (widget.dialogData?.dialogId != null) {
      final event = ClientUserEvent(fromUser: widget.userId, toUser: widget.partnerId, dialogId: widget.dialogData!.dialogId, event: "typing");
      _userStatusManager.sendEvent(event);
    }

  }

  void _sendFinishTypingEvent() async {
    if (widget.dialogData?.dialogId != null) {
      final event = ClientUserEvent(fromUser: widget.userId, toUser: widget.partnerId, dialogId: widget.dialogData!.dialogId, event: "finish_typing");
      _userStatusManager.sendEvent(event);
    }
  }


  void setReplyMessage(String message, int senderId, int messageId, String senderName) {
    setState(() {
      replyMessage = message;
      replyedMessageId = messageId;
      senderReplyName = senderName;
      replyedParentMsg = RepliedMessage.toJson(parentMessageText: message, parentMessageId: messageId, senderId: senderId);
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
    isSelectedMode = value;
    setState(() {});
    if (value == true) {
      _selectedMessagesOptionsMenuAnimationController.forward();
    } else {
      _selectedMessagesOptionsMenuAnimationController.reverse();
    }
  }

  void deleteMessages() async {
    try {
      isSelectedMode = false;
      setState(() {});
      List<int> ids = [];
      for (final message in selected) {
        ids.add(message.id);
      }
      final bool response = await MessagesProvider().deleteMessage(messageId: ids);
      if (response) {
        //TODO: refacrot messageBloc
        // BlocProvider.of<MessageBloc>(context).add(
        //     ChatsBuilderDeleteMessagesEvent(
        //         messagesId: ids, dialogId: widget.dialogData!.dialogId));
      } else {
        customToastMessage(context: context, message: 'Не получилось удалить сообщения. Попробуйте еще раз');
      }
      closeSelectedOptionsMenu();
    } catch (err) {
      closeSelectedOptionsMenu();
      customToastMessage(context: context, message: 'Не получилось удалить сообщения. Попробуйте еще раз');
    }
  }

  void deleteMessage(int id) async {
    print("Trying delete message $selected");
    try {
      final bool response = await MessagesProvider().deleteMessage(messageId: [id]);
      if (response) {
        //TODO: refacrot messageBloc
        // BlocProvider.of<MessageBloc>(context).add(
        //     ChatsBuilderDeleteMessagesEvent(
        //         messagesId: [id], dialogId: widget.dialogData!.dialogId));
      } else {
        customToastMessage(context: context, message: 'Не получилось удалить сообщения. Попробуйте еще раз');
      }
    } catch (err) {
      customToastMessage(context: context, message: 'Ошибка. Не получилось удалить сообщения. Попробуйте еще раз');
    }
  }

  void setSelected(SelectedMessage message) {
    if (isSelectedMode) {
      setState(() {
        if (!selected.any((m) => m.id == message.id)) {
          selected.add(message);
        } else {
          selected.remove(message);
        }
        if (selected.isEmpty) setSelectedMode(false);
      });
    }
  }

  void closeSelectedOptionsMenu() {
    setState(() {
      selected = [];
      isSelectedMode = false;
    });
    _selectedMessagesOptionsMenuAnimationController.reverse();
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
    _forwardMenuAnimationController.dispose();
    usersStatusEventSubscription.cancel();
    usersStatusEventSubscription.cancel();
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
      appBar: _appBar(),
      body: WebContainerWrapper(
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
                                users: widget.users,
                                partnerName: widget.username,
                                setSelectedMode: setSelectedMode,
                                isSelectedMode: isSelectedMode,
                                selected: selected,
                                setSelected: setSelected,
                                openForwardMenu: openForwardMenu,
                                deleteMessage: deleteMessage,
                                scrollController: scrollController
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
                      selected: selected, deleteMessages: deleteMessages, animation: _selectedMessagesOptionsMenuAnimation, animationController: _selectedMessagesOptionsMenuAnimationController,
                      openForwardMessageMenu: openForwardMenu)
                  : ReadOnlyChannelMode(context),
                ],
              ),
              ForwardMessageAlertDialog(userId: widget.userId, animationController: _forwardMenuAnimationController, animation: _forwardMenuAnimation, close: closeForwardMenu,
                forwardingMessages: forwardingMessages, closeSelectedOptionsMenu: closeSelectedOptionsMenu,
              )
            ]
          )
        ),
    );
  }

  PreferredSize _appBar() {
    return PreferredSize(
      preferredSize: Size(getWidthMaxWidthGuard(context), 56),
      child: AppBar(
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
              Navigator.of(context).maybePop();
            },
          ),
        ),
        title: InkWell(
          onTap: (){
            final usersCubit = BlocProvider.of<UsersViewCubit>(context);
            if (widget.dialogData == null || widget.dialogData?.chatType.p2p == 1) {
              openUserProfileInfoPage(context: context, user: findPartnerUserProfile(usersCubit, widget.partnerId), partnerId: widget.partnerId);
            } else {
              openGroupChatInfoPage(context: context, users: widget.users, dialogData: widget.dialogData, userId: null, dialogCubit: widget.dialogCubit, username: widget.username, partnerId: widget.partnerId, );
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
    for(var i=0; i < dialogData.users.length; ++i) {
      //TODO: refactor db
      // if(dialogData.chatUsers[i] == userId &&
      //     dialogData.chatUsers[i].chatUserRole == 1) {
      //   return true;
      // }
    }
    return false;
  }
}

UserModel? findPartnerUserProfile(UsersViewCubit usersCubit, int partnerId) {
  UserModel? user;
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
  List<UserModel> users;

  ChatPageArguments({required this.userId, required this.partnerId,
    required this.dialogData, required this.username, required this.dialogCubit, required this.users});
}


class SelectedMessage extends Equatable {
  final int id;
  final String message;
  final String author;
  final MessageAttachmentData? file;

  const SelectedMessage({required this.id, required this.message, required this.author, required this.file});

  @override
  String toString() {
    return "Instance of SelectedMessage[ $id, $message, $author, $file ]";
  }

  @override
  List<Object?> get props => [id];
}