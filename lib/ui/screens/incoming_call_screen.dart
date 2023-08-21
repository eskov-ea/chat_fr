import 'package:flutter/material.dart';
import '../../services/global.dart';
import '../../services/helpers/call_timer.dart';
import '../navigation/main_navigation.dart';

class IncomingCallScreen extends StatelessWidget {

  final String callerName;
  const IncomingCallScreen({
    required this.callerName,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timer = CallTimer.getInstance();
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
              callerName,
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            SizedBox(
              height: 3,
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
                    print("NAVIGATOR   inc   ${ModalRoute.of(context)?.settings.name}");
                    timer.start();
                    acceptCall();
                  },
                  child: Column(
                    // A button
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                            BorderRadius.all(Radius.circular(50))),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Image.asset(
                            'assets/images/accept_icon.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const Text("Accept",
                          style:
                          TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print("NAVIGATOR   ${ModalRoute.of(context)?.settings.name}");
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
