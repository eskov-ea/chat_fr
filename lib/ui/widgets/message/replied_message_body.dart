import 'package:chat/models/message_model.dart';
import 'package:chat/theme.dart';
import 'package:flutter/material.dart';

class RepliedMessageBodyWidget extends StatelessWidget {
  final String senderName;
  final RepliedMessage parentMessage;
  const RepliedMessageBodyWidget({
    required this.senderName,
    required this.parentMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white70,
        borderRadius:   BorderRadius.only(
          topLeft: Radius.circular(MessageStyle.borderRadius),
          topRight: Radius.circular(MessageStyle.borderRadius),
          bottomRight: Radius.circular(0.0),
          bottomLeft: Radius.circular(0.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
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
}
