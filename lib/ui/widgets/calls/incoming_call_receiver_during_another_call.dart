import 'package:flutter/material.dart';

class IncomingCallReceivedDuringCallWidget extends StatelessWidget {
  final String caller;
  const IncomingCallReceivedDuringCallWidget({
    required this.caller,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Colors.black87
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Center(
              child: Text(caller),
            ),
          ),
          Row(
            children: [
              callButton(Colors.green, () {}),
              callButton(Colors.red, () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget callButton(Color color, Function() action) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Ink(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            color: color
        ),
        child: InkWell(
          onTap: action,
          splashColor: Colors.white24,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
