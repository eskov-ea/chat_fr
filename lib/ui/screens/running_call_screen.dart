import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/global.dart';
import '../../services/helpers/call_timer.dart';
import '../navigation/main_navigation.dart';

class RunningCallScreen extends StatefulWidget {
  final String callerName;

  const RunningCallScreen(
      {required this.callerName,
      // TODO: stop propagate bloc here
      Key? key})
      : super(key: key);

  @override
  State<RunningCallScreen> createState() => _RunningCallScreenState();
}

class _RunningCallScreenState extends State<RunningCallScreen> {
  final sipChannel = const MethodChannel("com.application.chat/sip");
  final callServiceEventChannel =
      const EventChannel("event.channel/call_service");
  late final StreamSubscription callServiceBlocSubscription;
  bool isMute = false;
  bool isSpeaker = false;
  bool isConnected = false;
  final timer = CallTimer.getInstance();
  String? username;
  late final StreamSubscription _streamSubscription;
  String? callDuration;


  @override
  void initState() {
    callDuration = timer.lastValue;
    _streamSubscription = timer.stream().listen((time) {
      setState(() {
        callDuration = time;
      });
    });
    super.initState();
// print("USEEEERS    ${widget.users}");
    // username = widget.users.firstWhere((el) => el.id.toString() == widget.callerName).lastname;
    // callServiceBlocSubscription = widget.callsBloc.stream.listen((state) {
    //   if (state is EndedCallServiceState) {
    //     final currentRoute = ModalRoute.of(context)?.settings.name;
    //     if (currentRoute == "/home_screen/running_call_screen") {
    //       if (Navigator.canPop(context)) Navigator.pop(context);
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
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
            username ?? widget.callerName,
            style: TextStyle(color: Colors.white, fontSize: 26),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            callDuration ?? "00:00:00",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Expanded(
            child: SizedBox(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await toggleMute();
                  setState(() {
                    isMute = result;
                  });
                },
                child: Column(
                  // A button
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: isMute
                              ? Colors.white
                              : const Color(0x80ffffff),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          'assets/images/mute.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Text("Mute",
                        style:
                        TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  // A button
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: Color(0x80ffffff),
                          borderRadius:
                          BorderRadius.all(Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          'assets/images/message_icon.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Text("Message",
                        style: TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await toggleSpeaker();
                  setState(() {
                    isSpeaker = result;
                  });
                },
                child: Column(
                  // A button
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: isSpeaker
                              ? Colors.white
                              : const Color(0x80ffffff),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          'assets/images/speaker_icon.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Text("Speaker",
                        style:
                        TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
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
                          borderRadius: BorderRadius.all(Radius.circular(50))),
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
      ), context)
    );
  }
}

class CallScreenArguments {
  final String callerName;
  // final Bloc? callsBloc;
  // final List<UserProfileData> users;

  const CallScreenArguments({
    required this.callerName,
    // required this.callsBloc,
    // required this.users,
  });
}


