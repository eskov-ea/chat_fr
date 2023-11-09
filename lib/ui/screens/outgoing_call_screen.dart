import 'package:flutter/material.dart';
import '../../services/global.dart';
import '../navigation/main_navigation.dart';
import '../widgets/call_controls_widget.dart';

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
    return Container();

      // Scaffold(
      // // appBar: ,
      //   backgroundColor: const Color(0xFF474747),
      //   body: Container(
      //     decoration: const BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage("assets/images/calls_wallpaper.jpg"),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: CustomSizeContainer(
      //       Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Padding(
      //           padding: EdgeInsets.only(top: 80),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               CircleAvatar(
      //                 radius: 80,
      //                 backgroundColor: Colors.grey,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(1), // Border radius
      //                   child: ClipOval(
      //                       child: Image.asset('assets/images/no_avatar.png')),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         const SizedBox(
      //           height: 10,
      //         ),
      //         Text(
      //           widget.callerName,
      //           style: TextStyle(color: Colors.white, fontSize: 26),
      //         ),
      //         const SizedBox(
      //           height: 10,
      //         ),
      //         const Text(
      //           "Calling",
      //           // "Calling ${makeDots()}",
      //           style: TextStyle(color: Colors.white, fontSize: 18),
      //         ),
      //         const Expanded(
      //           child: SizedBox(),
      //         ),
      //         const SizedBox(
      //           height: 20,
      //         ),
      //         CallControlsWidget(
      //           isMute: isMute,
      //           isSpeaker: isSpeaker,
      //           isConnected: isConnected,
      //           isSipServiceActive: false,
      //           onToggleMute: () async {
      //             final result = await toggleMute();
      //             setState(() {
      //               isMute = result;
      //             });
      //           },
      //           onToggleSpeaker: () async {
      //             final result = await toggleSpeaker();
      //             setState(() {
      //               isSpeaker = result;
      //             });
      //           },
      //           onCallDecline: () {
      //             declineCall();
      //             Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
      //           },
      //         ),
      //         const SizedBox(
      //           height: 50,
      //         ),
      //       ],
      //     ), context),
      //   ));
  }
}
