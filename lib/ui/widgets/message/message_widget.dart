import 'dart:convert';
import 'dart:io';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/helpers/file_types_helper.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/ui/widgets/image_preview_widget.dart';
import 'package:chat/ui/widgets/message/message_error_widget.dart';
import 'package:chat/ui/widgets/message/message_status_widget.dart';
import 'package:chat/ui/widgets/message/messge_content_widget.dart';
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
import '../../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../../services/global.dart';
import '../../../services/helpers/message_sender_helper.dart';
import '../../../theme.dart';
import '../../navigation/main_navigation.dart';
import '../audioplayer_widget.dart';

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
    required this.forwardFrom,
    required this.senderName,
    required this.parentMessage,
    required this.repliedMsgSenderName,
    required this.repliedMsgId,
    required this.isError,
    required this.isErrorHandling,
    required this.dialogId,
    required this.openForwardMenu,
    Key? key
  }) : super(key: key);

  final int index;
  final int userId;
  final int dialogId;
  final int p2p;
  final List selected;
  final bool selectedMode;
  final Function setSelectedMode;
  final Function(String, String, MessageAttachmentsData?) openForwardMenu;
  final Function(int) setSelected;
  final String message;
  final int messageId;
  final String? forwardFrom;
  final String messageDate;
  final String messageTime;
  final int senderId;
  final FocusNode focusNode;
  final Function(String, int, int, String) setReplyMessage;
  final int status;
  final MessageAttachmentsData? file;
  final String senderName;
  final ParentMessage? parentMessage;
  final String? repliedMsgSenderName;
  final int? repliedMsgId;
  final bool isError;
  final bool isErrorHandling;

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
    }
  }

  void onSwipeRight(){
    widget.setReplyMessage(widget.message, widget.senderId, widget.messageId, widget.senderName);
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
      forwardFrom: widget.forwardFrom,
      senderName: widget.senderName,
      parentMessage: widget.parentMessage,
      repliedMsgSenderName: widget.repliedMsgSenderName,
      isError: widget.isError,
      fileAttachment: localFileAttachment,
      dialogId: widget.dialogId,
      repliedMsgId: widget.repliedMsgId,
      isErrorHandling: widget.isErrorHandling,
      openForwardMenu: widget.openForwardMenu
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
    required this.forwardFrom,
    required this.parentMessage,
    required this.repliedMsgSenderName,
    required this.repliedMsgId,
    required this.fileAttachment,
    required this.isError,
    required this.isErrorHandling,
    required this.dialogId,
    required this.openForwardMenu,
  }) : super(key: key);

  final int index;
  final int p2p;
  final String message;
  final int messageId;
  final String messageDate;
  final String messageTime;
  final String senderName;
  final String? repliedMsgSenderName;
  final Function(int) setSelected;
  final Function setSelectedMode;
  final Function(String, String, MessageAttachmentsData?) openForwardMenu;
  final List selected;
  final bool selectedMode;
  final int userId;
  final String? forwardFrom;
  final bool isMe;
  final onSwipeRight;
  final int status;
  final MessageAttachmentsData? file;
  final ParentMessage? parentMessage;
  final File? fileAttachment;
  final bool isError;
  final bool isErrorHandling;
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
        attachmentId: file!.attachmentId,
        isMe: isMe,
        messageTime: messageTime
      )
    );
  }

  void fileAttachmentMessCallback(BuildContext context) {
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.filePreviewPage,
        arguments: AttachmentViewPageArguments(
          fileName: file!.name,
          fileExt: file!.filetype,
          attachmentId: file!.attachmentId,
          isMe: isMe,
          messageTime: messageTime
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
                    if (isMe) StatusWidget(status),
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
      onRightSwipe: onSwipeRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0), // TODO: ???
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (selectedMode)
              Checkbox(
                activeColor: Colors.transparent,
                value: selected.contains(messageId),
                onChanged: (_) {
                  setSelected(messageId);
                },
              ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8
                ),
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: FocusedMenuHolder(
                        onPressed: () {},
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                              title: const Text(
                                'Скопировать',
                                style: TextStyle(color: Colors.black54),
                              ),
                              onPressed: () {
                                _copyMessageToClipboard(context);
                              },
                              trailingIcon: const Icon(Icons.copy)),
                          FocusedMenuItem(
                              title: const Text(
                                'Переслать',
                                style: TextStyle(color: Colors.black54),
                              ),
                              onPressed: () {
                                openForwardMenu(
                                  message, senderName, file
                                );
                              },
                              trailingIcon: const Icon(Icons.forward)),
                          FocusedMenuItem(
                              title: const Text('Удалить',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                // _detDeletedStatus();
                              },
                              trailingIcon:
                              const Icon(Icons.delete, color: Colors.red)),
                          FocusedMenuItem(
                              title: const Text(
                                'Выбрать',
                                style: TextStyle(color: Colors.black54),
                              ),
                              onPressed: () {
                                setSelectedMode(true);
                                setSelected(messageId);
                              },
                              trailingIcon: const Icon(Icons.control_point)),
                        ],
                        child: MessageContentWidget(
                            isMe: isMe,
                            file: file,
                            setSelected: setSelected,
                            messageId: messageId,
                            message: message,
                            senderName: senderName,
                            repliedMsgSenderName: repliedMsgSenderName,
                            p2p: p2p,
                            forwardFrom: forwardFrom,
                            status: status,
                            messageDate: messageDate,
                            messageTime: messageTime,
                            fileAttachment: fileAttachment,
                            parentMessage: parentMessage,
                            borderRadius: MessageStyle.borderRadius
                        )
                    ),
                  ),
                ),
              ),
            ),
            MessageErrorWidget(
                isError: isError,
                isErrorHandling: isErrorHandling,
                messageId: messageId,
                dialogId: dialogId,
                userId: userId,
                repliedMsgId: repliedMsgId,
                message: message,
                parentMessage: parentMessage
            )
          ],
        ),
      ),
    );
  }

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




