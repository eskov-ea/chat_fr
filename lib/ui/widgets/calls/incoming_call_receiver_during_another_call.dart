import 'package:flutter/material.dart';

class IncomingCallReceivedDuringCallWidget extends StatelessWidget {
  final String caller;
  final String callId;
  final Function(String) onAccept;
  final Function(String) onDecline;
  const IncomingCallReceivedDuringCallWidget({
    required this.caller,
    required this.callId,
    required this.onAccept,
    required this.onDecline,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 80,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: Colors.white70
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: Text(caller,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                callButton(Colors.green, "assets/call_controls/accept_icon.png", onAccept),
                callButton(Colors.red, "assets/call_controls/decline_icon.png", onDecline),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget callButton(Color color, String image, Function(String) action) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Ink(
          width: 100,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: color
          ),
          child: InkWell(
            onTap: () {
              print('Try to accept next: $callId');
              action(callId);
              },
            splashColor: Colors.white30,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              width: 60,
              height: 40,
              child: Image.asset(
                  image, fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
