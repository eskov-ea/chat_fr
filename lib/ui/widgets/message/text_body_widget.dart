import 'package:chat/models/message_model.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/message/replied_message_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextBodyWidget extends StatelessWidget {
  final String message;
  final String messageTime;
  final bool isMe;
  final int p2p;
  final ParentMessage? parentMessage;
  final String? repliedMsgSenderName;
  const TextBodyWidget({
    required this.message,
    required this.messageTime,
    required this.isMe,
    required this.p2p,
    required this.parentMessage,
    required this.repliedMsgSenderName,
    super.key
  });

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.isNotEmpty && message.trim() != "") {
      return Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            minWidth: 100
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (parentMessage != null) RepliedMessageBodyWidget(
                senderName: repliedMsgSenderName!,
                parentMessage: parentMessage!,
              ),

              // if (p2p != 1 && !isMe) authorNameWidgetGroupChat(senderName),
              Container(
                alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(
                    right: 12.0, left: 15, top: 7, bottom: 0),
                  child: SelectableLinkify(
                    onOpen: (link) => _launchUrl(Uri.tryParse(link.url)),
                    text: message,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.start,
                    linkStyle: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                  )
              ),
            ]
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
