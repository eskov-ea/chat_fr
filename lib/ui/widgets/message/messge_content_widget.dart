import 'dart:io';

import 'package:chat/models/message_model.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/ui/widgets/audioplayer_widget.dart';
import 'package:chat/ui/widgets/image_preview_widget.dart';
import 'package:chat/ui/widgets/message/forward_message_prefix_widget.dart';
import 'package:chat/ui/widgets/message/group_chat_sender_name_widget.dart';
import 'package:chat/ui/widgets/message/message_attachment_icon_preview.dart';
import 'package:chat/ui/widgets/message/message_status_widget.dart';
import 'package:chat/ui/widgets/message/replied_message_body.dart';
import 'package:chat/ui/widgets/message/text_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/helpers/file_types_helper.dart';


class MessageContentWidget extends StatelessWidget {
  final bool isMe;
  final MessageAttachmentsData? file;
  final Function(SelectedMessage) setSelected;
  final int messageId;
  final int p2p;
  final int status;
  final String messageDate;
  final String messageTime;
  final String message;
  final String senderName;
  final String? repliedMsgSenderName;
  final double borderRadius;
  final File? fileAttachment;
  final String? forwardFrom;
  final ParentMessage? parentMessage;
  const MessageContentWidget({
    required this.isMe,
    required this.file,
    required this.setSelected,
    required this.messageId,
    required this.message,
    required this.senderName,
    required this.repliedMsgSenderName,
    required this.p2p,
    required this.forwardFrom,
    required this.status,
    required this.messageDate,
    required this.messageTime,
    required this.fileAttachment,
    required this.parentMessage,
    required this.borderRadius,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSelected(SelectedMessage(id: messageId, message: message, author: senderName, file: file));
      },
      child: Align(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
            // color: Color(0x83FF5983),
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
              bottomRight: isMe ? const Radius.circular(0.0) : Radius.circular(borderRadius),
              bottomLeft: !isMe ? const Radius.circular(0.0) : Radius.circular(borderRadius),
            ),
          ),
          child: Column(
            // crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (p2p != 1 && !isMe) GroupChatSenderNameWidget(senderName: senderName),

              ForwardMessagePrefixWidget(p2p: p2p, forwardFrom: forwardFrom),

              if (file != null && GraphicTypes.contains(file!.filetype))
              ImagePreviewWidget(
                key: ValueKey<int>(file!.attachmentId),
                p2p: p2p,
                isMe: isMe,
                senderName: senderName,
                borderRadius: 10.0,
                file: file,
                localFileAttachment: fileAttachment,
                messageTime: messageTime,
                status: StatusWidget(status),
              ),

              if (file != null && AudioTypes.contains(file!.filetype))
                Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8 ),
                  child: AudioPlayerWidget(
                    attachmentId: file!.attachmentId,
                    fileName: file!.name,
                    isMe: isMe,
                    messageTime: messageTime
                  ),
                ),

              if (file != null && DocumentTypes.contains(file!.filetype))
              MessageAttachmentIconPreview(
                iconPath: "assets/file_icon_2.png",
                width: 64,
                file: file!,
                isMe: isMe,
                messageTime: messageTime,
                status: status,
              ),

              TextBodyWidget(
                message: message,
                messageTime: messageTime,
                isMe: isMe,
                p2p: p2p,
                parentMessage: parentMessage,
                repliedMsgSenderName: repliedMsgSenderName
              ),

              if (file == null || !GraphicTypes.contains(file!.filetype))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 8),
                    child: Text(
                      messageTime,
                      style: const TextStyle(
                        color: AppColors.textFaded,
                        fontSize: 12,
                        height: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isMe) const SizedBox(width: 1),
                  if (isMe) Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: StatusWidget(status)
                  ),
                  const SizedBox(width: 5)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}