import 'package:flutter/material.dart';

class ForwardMessagePrefixWidget extends StatelessWidget {
  final int p2p;
  final String? forwardFrom;
  const ForwardMessagePrefixWidget({
    required this.p2p,
    required this.forwardFrom,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    if (forwardFrom != null) {
      return Container(
        padding: EdgeInsets.only(top: p2p == 1 ? 10 : 0, right: 10),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Icon(Icons.forward, color: Colors.grey, size: 18,),
            Flexible(
              child: Text('Пересланое сообщение',
                  style: TextStyle(fontSize: 13, height: 1.2, fontStyle: FontStyle.italic),
                  maxLines: 3
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
