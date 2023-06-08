import 'dart:convert';
import 'dart:io';
import 'package:chat/models/message_model.dart';
import 'package:chat/ui/widgets/image_preview_widget.dart';
import 'package:chat/ui/widgets/pdf_viewer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import '../../theme.dart';
import '../../view_models/dialogs_page/dialogs_view_cubit.dart';
import '../navigation/main_navigation.dart';
import 'audioplayer_widget.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({
    required this.index,
    required this.userId,
    required this.selected,
    required this.selectedMode,
    required this.setSelectedMode,
    required this.setSelected,
    required this.message,
    required this.messageId,
    required this.messageDate,
    required this.messageTime,
    required this.senderId,
    required this.focusNode,
    required this.setReplyMessage,
    required this.status,
    required this.file,
    required this.p2p,
    required this.senderName,
    required this.parentMessage,
    required this.repliedMsgSenderName,
    required this.repliedMsgId,
    required this.isError,
    required this.dialogId,
    Key? key
  }) : super(key: key);

  final int index;
  final int userId;
  final int dialogId;
  final int p2p;
  final List selected;
  final bool selectedMode;
  final Function setSelectedMode;
  final Function(int) setSelected;
  final String message;
  final int messageId;
  final String messageDate;
  final String messageTime;
  final int senderId;
  final FocusNode focusNode;
  final Function setReplyMessage;
  final int status;
  final MessageAttachmentsData? file;
  final String? senderName;
  final ParentMessage? parentMessage;
  final String? repliedMsgSenderName;
  final int? repliedMsgId;
  final bool isError;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget>  with SingleTickerProviderStateMixin {

  File? localFileAttachment;

  @override
  void initState() {
    checkIfAttachmentLoaded();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  checkIfAttachmentLoaded() async {
    if (widget.file != null && !kIsWeb){
      localFileAttachment = await isLocalFileExist(fileName: widget.file!.name);
      if (localFileAttachment != null) setState(() {});
      print("Check if file exists -->  $localFileAttachment");
    }
  }

  void onSwipeRight(){
    widget.setReplyMessage(widget.message, widget.senderId, widget.messageId);
  }

  @override
  Widget build(BuildContext context) {
    return _MessageTile(
      index: widget.index,
      userId: widget.userId,
      selected: widget.selected,
      selectedMode: widget.selectedMode,
      setSelectedMode: widget.setSelectedMode,
      message: widget.message,
      messageId: widget.messageId,
      messageDate: widget.messageDate,
      messageTime: widget.messageTime,
      setSelected: widget.setSelected,
      isMe: widget.userId == widget.senderId,
      onSwipeRight: onSwipeRight,
      status: widget.status,
      file: widget.file,
      p2p: widget.p2p,
      senderName: widget.senderName,
      parentMessage: widget.parentMessage,
      repliedMsgSenderName: widget.repliedMsgSenderName,
      isError: widget.isError,
      fileAttachment: localFileAttachment,
      dialogId: widget.dialogId,
      repliedMsgId: widget.repliedMsgId,
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.index,
    required this.message,
    required this.messageId,
    required this.messageDate,
    required this.messageTime,
    required this.setSelected,
    required this.selected,
    required this.selectedMode,
    required this.setSelectedMode,
    required this.userId,
    required this.isMe,
    required this.onSwipeRight,
    required this.status,
    required this.file,
    required this.senderName,
    required this.p2p,
    required this.parentMessage,
    required this.repliedMsgSenderName,
    required this.repliedMsgId,
    required this.fileAttachment,
    required this.isError,
    required this.dialogId,
  }) : super(key: key);

  final int index;
  final int p2p;
  final String message;
  final int messageId;
  final String messageDate;
  final String messageTime;
  final String? senderName;
  final String? repliedMsgSenderName;
  final Function(int) setSelected;
  final Function setSelectedMode;
  final List selected;
  final bool selectedMode;
  final int userId;
  final bool isMe;
  final onSwipeRight;
  final int status;
  final MessageAttachmentsData? file;
  final ParentMessage? parentMessage;
  final File? fileAttachment;
  final bool isError;
  final int dialogId;
  final int? repliedMsgId;

  static const _borderRadius = 10.0;

  void _copyMessageToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message)).then((_){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Сообщение скопировано")));
    });
  }

  audioMessCallback (BuildContext context) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.audioMessagePage,
      arguments: AttachmentViewPageArguments(
        fileName: file!.name,
        fileExt: file!.filetype,
        attachmentId: file!.attachmentId
      )
    );
  }

  void fileAttachmentMessCallback(BuildContext context) {
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.filePreviewPage,
        arguments: AttachmentViewPageArguments(
            fileName: file!.name,
            fileExt: file!.filetype,
            attachmentId: file!.attachmentId
        )
    );
  }

  Widget fileIconWidget ({
    required BuildContext context,
    required double width,
    required String iconPath,
    required callback
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
            borderRadius:  BorderRadius.only(
              topLeft: const Radius.circular(_borderRadius),
              topRight: const Radius.circular(_borderRadius),
              bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
              bottomLeft: !isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
            ),
          ),
          child: GestureDetector(
            onTap: () {callback(context);},
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(iconPath, width: width,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, right: 0, bottom: 0),
                      child: Text(
                        messageTime,
                        style: const TextStyle(
                          color:AppColors.textFaded,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isMe) const SizedBox(width: 1,),
                    if (isMe) _StatusWidget(status),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      iconOnRightSwipe: Icons.reply,
      // rightSwipeWidget: Icon(Icons.reply),
      onRightSwipe: onSwipeRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),  // TODO: ???
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (selectedMode)
              Checkbox(
                activeColor: Colors.transparent,
                value: selected.contains(messageId),
                onChanged: (_) {
                  setSelected(messageId);
                },
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                FocusedMenuHolder(
                  onPressed: () {},
                  menuItems: <FocusedMenuItem>[
                    FocusedMenuItem(
                        title: const Text(
                          'Copy',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {
                          _copyMessageToClipboard(context);
                        },
                        trailingIcon: const Icon(Icons.copy)),
                    FocusedMenuItem(
                        title: const Text(
                          'Forward',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {},
                        trailingIcon: const Icon(Icons.forward)),
                    FocusedMenuItem(
                        title:
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          // _detDeletedStatus();
                        },
                        trailingIcon: const Icon(Icons.delete, color: Colors.red)),
                    FocusedMenuItem(
                        title: const Text(
                          'Select',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {
                          setSelectedMode(true);
                          setSelected(messageId);
                        },
                        trailingIcon: const Icon(Icons.control_point)),
                  ],
                  child: GestureDetector(
                    onTap: () {
                      setSelected(messageId);
                    },
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        //TODO: refactor 3 widgets with one function/widget to avoid unnecessary code
                        file != null && file!.filetype == "jpg" || file != null && file!.filetype == "jpeg" || file != null && file!.filetype == "png"
                          ? Container(
                            height: 240,
                            width: 186,
                            child: ImagePreviewWidget(
                                key: ValueKey<int>(file!.attachmentId),
                                p2p: p2p,
                                isMe: isMe,
                                senderName: senderName,
                                borderRadius: _borderRadius,
                                file: file, localFileAttachment:
                                fileAttachment,
                                authorNameWidgetGroupChat: _authorNameWidgetGroupChat,
                                messageTime: messageTime,
                                status: _StatusWidget(status),
                              ),
                          )
                          : const SizedBox.shrink(),
                        file != null && file!.filetype == "mp4"
                          ? Container(
                            height: 80,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8 ),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
                              borderRadius:  BorderRadius.only(
                                topLeft: const Radius.circular(_borderRadius),
                                topRight: const Radius.circular(_borderRadius),
                                bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
                                bottomLeft: !isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (p2p != 1 && !isMe) _authorNameWidgetGroupChat(senderName, _borderRadius),
                                AudioPlayerWidget(
                                    attachmentId: file!.attachmentId,
                                    fileName: file!.name,
                                    isMe: isMe
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Text(
                                    messageTime,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      color:AppColors.textFaded,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                )
                              ]
                            ),
                          )
                          : const SizedBox.shrink(),
                            file != null && file!.filetype != "mp4" && file!.filetype != "jpeg" && file!.filetype != "jpg" && file!.filetype != "png"
                          ? fileIconWidget(
                              context: context,
                              iconPath: "assets/file_icon_2.png",
                              width: 64,
                              callback: fileAttachmentMessCallback
                            )
                          : const SizedBox.shrink(),
                        const SizedBox(height: 5,),
                        message.isNotEmpty && message.trim() != ""
                            ? Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                            minWidth: 100
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
                            borderRadius:  BorderRadius.only(
                              topLeft: const Radius.circular(_borderRadius),
                              topRight: const Radius.circular(_borderRadius),
                              bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
                              bottomLeft: !isMe ? const Radius.circular(0.0) : const Radius.circular(_borderRadius),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            child: IntrinsicWidth (
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  if (parentMessage != null) RepliedMessageBody(_borderRadius, parentMessage!, repliedMsgSenderName),

                                  if (p2p != 1 && !isMe) _authorNameWidgetGroupChat(senderName, _borderRadius),
                                  // if (replyedText != null) _ReplyedMessageWidget(replyedText: replyedText!, borderRadius: _borderRadius,),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12.0, left: 15, top: 7, bottom: 13),
                                    child: SelectableLinkify (
                                      onOpen: (link) => _launchUrl(Uri.tryParse(link.url)),
                                      text: message,
                                      style: isMe
                                          ? const TextStyle(color: Colors.black, fontSize: 16)
                                          : const TextStyle(color: Colors.black, fontSize: 16),
                                      linkStyle: isMe
                                          ? const TextStyle(color: Colors.white, fontSize: 16)
                                          : const TextStyle(color: Colors.blueAccent, fontSize: 16),
                                    )
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10, bottom: 5),
                                        child: Text(
                                          messageTime,
                                          style: const TextStyle(
                                            color:AppColors.textFaded,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isMe) const SizedBox(width: 1,),
                                      if (isMe) _StatusWidget(status),
                                    ],
                                  ),
                                ]
                              ),
                            ),
                          ),
                        )
                        : const SizedBox.shrink()
                      ],
                    ),
                  ),
                ),
                !isError
                ?Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  // child: Row(
                  //   children: [
                  //     Text(
                  //       messageTime,
                  //       style: const TextStyle(
                  //         color: AppColors.textFaded,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     if (isMe) const SizedBox(width: 8,),
                  //     if (isMe) _StatusWidget(status),
                  //   ],
                  // ),
                )
                : SizedBox.shrink(),
                const SizedBox(height: 5.0,)
              ],
            ),
            isError
            ? GestureDetector(
              onTap: (){

                showModalBottomSheet(
                    isDismissible: true,
                    isScrollControlled: false,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) => Container(
                      padding: EdgeInsets.all(8),
                      height: 200,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Произошла ошибка при отправке сообщения",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: (){ _resendErroredMessage(messageId, dialogId, context, message, parentMessage, repliedMsgId); },
                            child: Container(
                              child: Text("Отправить снова",
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                              onTap: (){
                                _deleteErroredMessage(messageId, dialogId, context);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                child: Text("Удалить сообщение",
                                  style: TextStyle(fontSize: 18, color: Colors.red),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                );
              },
              child: Container(
                  alignment: Alignment.center,
                  // padding: EdgeInsets.only(bottom: 25),
                  child: Icon(Icons.error, size: 35, color: Colors.red,),
              ),
            )
            : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void _resendErroredMessage(int messageId, int dialogId, BuildContext context,
      String messageText, ParentMessage? parentMessage,
      int? repliedMessageId) async {
    print("_resendErroredMessage  -->  $messageId,  text  -->  $messageText");
    final localMessage = createLocalMessage(
      dialogId: dialogId,
      messageText: messageText,
      parentMessage: parentMessage,
      replyedMessageId: repliedMessageId,
      userId: userId
    );
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderDeleteLocalMessageEvent(dialogId: dialogId, messageId: messageId));
    Navigator.of(context).pop();
    try {
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderAddMessageEvent(message: localMessage, dialog: dialogId));
      // TODO: if response status code is 200 else ..
      final sentMessage = await MessagesRepository().sendMessage(
          dialogId: dialogId,
          messageText: messageText,
          parentMessageId: repliedMessageId);
      print("sentMessage response  $sentMessage");
      if (sentMessage == null) {
        customToastMessage(context, "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
        return;
      }
      final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderUpdateLocalMessageEvent(
              message: message,
              dialogId: dialogId,
              localMessageId: localMessage.messageId));
      BlocProvider.of<DialogsViewCubit>(context)
          .updateLastDialogMessage(localMessage);
      print("RESULT IS  $sentMessage ${BlocProvider.of<ChatsBuilderBloc>(context)}");
    } catch (err) {
      print("ERRRRRRRRROR  $err ");
      // customToastMessage(context, "Ошибка: Произошла ошибка при отправке сообщения, попробуйте еще раз");
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderUpdateMessageWithErrorEvent(message: localMessage, dialog: dialogId)
      );
    }
  }

  void _deleteErroredMessage(int messageId, int dialogId, BuildContext context) {
    print("_deleteErroredMessage  -->  $messageId");
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderDeleteLocalMessageEvent(dialogId: dialogId, messageId: messageId));
  }
}

class _ReplyedMessageWidget extends StatelessWidget {
  const _ReplyedMessageWidget({
    required this.replyedText,
    required this.borderRadius,
    Key? key
  }) : super(key: key);

  final String replyedText;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xff666666),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius)
          ),
        ),
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            color: Colors.blueAccent,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Andrey'),
                const SizedBox(height: 5,),
                Text(replyedText, maxLines: 1,)
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _authorNameWidgetGroupChat(String? senderName, _borderRadius) {
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:  BoxDecoration(
        color: Colors.white24,
        borderRadius:  BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight:  Radius.circular(_borderRadius),
          bottomRight: Radius.circular(0.0),
          bottomLeft: const Radius.circular(0.0),
        ),
      ),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Text(senderName ?? '',
            style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w700),
          )
        ],
      )
  );
}

void replyToMessage(message) {
  print('replyToMessage');
}

void _onOpen(link) async {
  print(link);
  if (await canLaunchUrl(link.url)) {
    await launchUrl(link.url);
  } else {
    throw 'Could not launch $link';
  }
}

Future<void> _launchUrl(_url) async {
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}

Widget imageFromBase64String(String base64String, int id, BuildContext context) {
  return GestureDetector(
    onTap: (){
      print("FILE TAPPED");
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Image.memory(base64Decode(base64String)),
    ),
  );
}

Widget RepliedMessageBody(borderRadius, ParentMessage parentMessage, senderName) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius:   BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
        bottomRight: const Radius.circular(0.0),
        bottomLeft: const Radius.circular(0.0),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 3,),
              Container(
                color: Colors.blueAccent,
                width: 3,
                height: 20,
              ),
              const SizedBox(width: 5,),
              Text(
                senderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],),
          Row(
            children: [
              const SizedBox(width: 3,),
              Container(
                color: Colors.blueAccent,
                width: 3,
                height: 40,
              ),
              const SizedBox(width: 5,),
              Expanded(
                flex: 1,
                child: Text(
                  parentMessage.parentMessageText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
          ],)
        ],
      ),
    ),
  );
}

Widget _StatusWidget(status) {
  Widget _widget = SizedBox.shrink();
  switch (status) {
    case 2:
      _widget = Icon(
        Icons.check_outlined,
        color: Colors.grey,
        size: 20.0,
      );
      break;
    case 3:
      _widget = Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.check_outlined,
            color: Colors.grey,
            size: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.check_outlined,
              color: Colors.grey,
              size: 20.0,
            ),
          ),
        ],
      );
      break;
    case 4:
      _widget = Stack(
        children: [
          Icon(
            Icons.check_outlined,
            color: Colors.green,
            size: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.check_outlined,
              color: Colors.green,
              size: 20.0,
            ),
          ),
        ],
      );
      break;
  }
  return _widget;
}


