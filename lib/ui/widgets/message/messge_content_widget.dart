import 'dart:io';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/helpers/file_types_helper.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/ui/widgets/message/audioplayer_widget.dart';
import 'package:chat/ui/widgets/message/image_preview_widget.dart';
import 'package:chat/ui/widgets/message/forward_message_prefix_widget.dart';
import 'package:chat/ui/widgets/message/group_chat_sender_name_widget.dart';
import 'package:chat/ui/widgets/message/message_attachment_icon_preview.dart';
import 'package:chat/ui/widgets/message/message_status_widget.dart';
import 'package:chat/ui/widgets/message/text_body_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class MessageContentWidget extends StatelessWidget {
  final bool isMe;
  final MessageAttachmentData? file;
  final Function(SelectedMessage) setSelected;
  final int messageId;
  final int p2p;
  final int isError;
  final int status;
  final String messageDate;
  final String messageTime;
  final String message;
  final String senderName;
  final String? repliedMsgSenderName;
  final double borderRadius;
  final File? fileAttachment;
  final String? forwardFrom;
  final RepliedMessage? parentMessage;
  final String dirPath;
  const MessageContentWidget({
    required this.isMe,
    required this.file,
    required this.isError,
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
    required this.dirPath,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Messages taped $messageId $file');
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
                dirPath: dirPath,
                p2p: p2p,
                isMe: isMe,
                senderName: senderName,
                borderRadius: 10.0,
                file: file,
                localFileAttachment: fileAttachment,
                messageText: message,
                messageTime: messageTime,
                status: StatusWidget(status),
              ),

              if (file != null && AudioTypes.contains(file!.filetype))
                kIsWeb ? Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: const Text('Аудио сообщение не поддерживается в браузере',
                    softWrap: true, style: TextStyle(fontSize: 12, height: 1),
                  ),
                ) : Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

              if (file == null || (file != null && message.trim() != "") || AudioTypes.contains(file!.filetype))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 0, bottom: 8),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, right: 5),
                    child: SizedBox(
                      width: isMe ? 25 : 0,
                      child: isMe && isError == 0 ? StatusWidget(status) : const SizedBox.shrink()
                      ),
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
