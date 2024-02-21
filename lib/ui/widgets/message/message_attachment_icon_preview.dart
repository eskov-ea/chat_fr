import 'package:chat/models/message_model.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/widgets/message/message_status_widget.dart';
import 'package:chat/ui/widgets/pdf_viewer_widget.dart';
import 'package:flutter/material.dart';

class MessageAttachmentIconPreview extends StatelessWidget {
  final double width;
  final String iconPath;
  final bool isMe;
  final String messageTime;
  final int status;
  final MessageAttachmentsData file;
  const MessageAttachmentIconPreview({
    required this.width,
    required this.iconPath,
    required this.isMe,
    required this.messageTime,
    required this.status,
    required this.file,
    super.key
  });


  @override
  Widget build(BuildContext context) {

    void fileAttachmentMessCallback() {
      Navigator.of(context).pushNamed(
          MainNavigationRouteNames.filePreviewPage,
          arguments: AttachmentViewPageArguments(
              fileName: file.name,
              fileExt: file.filetype,
              attachmentId: file.attachmentId,
              isMe: isMe,
              messageTime: messageTime
          )
      );
    }

    return Column(
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
            borderRadius:  BorderRadius.only(
              topLeft: const Radius.circular(MessageStyle.borderRadius),
              topRight: const Radius.circular(MessageStyle.borderRadius),
              bottomRight: isMe ? const Radius.circular(0.0) : const Radius.circular(MessageStyle.borderRadius),
              bottomLeft: !isMe ? const Radius.circular(0.0) : const Radius.circular(MessageStyle.borderRadius),
            ),
          ),
          child: GestureDetector(
            onTap: fileAttachmentMessCallback,
            child: Image.asset(iconPath, width: width, height: width),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(file.name,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          )
        )
      ],
    );
  }
}
