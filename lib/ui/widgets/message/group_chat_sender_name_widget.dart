import 'package:chat/theme.dart';
import 'package:flutter/material.dart';

class GroupChatSenderNameWidget extends StatelessWidget {
  final String senderName;
  const GroupChatSenderNameWidget({
    required this.senderName,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.white24,
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(MessageStyle.borderRadius),
            topRight:  Radius.circular(MessageStyle.borderRadius),
            bottomRight: Radius.circular(0.0),
            bottomLeft: Radius.circular(0.0),
          ),
        ),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Text(senderName ?? '',
              style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w700, height: 1),
            )
          ],
        )
    );;
  }
}
