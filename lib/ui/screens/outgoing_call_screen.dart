import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/global.dart';
import '../navigation/main_navigation.dart';

class OutgoingCallScreen extends StatefulWidget {
  const OutgoingCallScreen({
    required this.callerName,
    Key? key
  }) : super(key: key);

  final String callerName;

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {

  // List<String> dots = [];
  // makeDots() {
  //   while (true) {
  //     if (dots.length < 4) {
  //       setState(() {
  //         dots.add(".");
  //       });
  //     } else {
  //       setState(() {
  //         dots = [];
  //       });
  //     }
  //     Future.delayed(const Duration(milliseconds: 300));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // makeDots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: ,
        backgroundColor: const Color(0xFF474747),
        body: CustomSizeContainer(Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(1), // Border radius
                      child: ClipOval(
                          child: Image.asset('assets/images/no_avatar.png')),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.callerName,
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Calling",
              // "Calling ${makeDots()}",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Expanded(
              child: SizedBox(),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    print(
                        "NAVIGATOR   ${ModalRoute.of(context)?.settings.name}");
                    declineCall();
                    Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
                  },
                  child: Column(
                    // A button
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                            BorderRadius.all(Radius.circular(50))),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Image.asset(
                            'assets/images/decline_icon.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const Text("Decline",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ), context));
  }
}
