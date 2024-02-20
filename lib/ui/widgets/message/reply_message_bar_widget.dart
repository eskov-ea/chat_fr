import 'package:flutter/material.dart';

class ReplyMessageBar extends StatelessWidget {
  const ReplyMessageBar({
    required this.replyMessage,
    required this.senderName,
    required this.cancelReplyMessage,
    Key? key
  }) : super(key: key);

  final String replyMessage;
  final String senderName;
  final cancelReplyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff343434),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0)
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 25),
            child: Icon(Icons.subdirectory_arrow_left),
          ),
          Container(
            color: Colors.blueAccent,
            width: 3,
            height: 30,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8 ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senderName,
                      style: TextStyle(
                          color: Color(0xFFC07602)
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      replyMessage,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white70
                      ),
                    ),
                  ]
              ),
            ),
          ),
          IconButton(
              onPressed: (){
                cancelReplyMessage();
              },
              icon: const Icon(Icons.close)
          )
        ],
      ),
    );
  }
}