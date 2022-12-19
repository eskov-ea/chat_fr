import 'dart:async';
import 'package:chat/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/calls_bloc/calls_state.dart';
import '../../services/global.dart';

class RunningCallScreenCopy extends StatefulWidget {
  final String callerId;
  final Bloc callsBloc;
  final List<UserProfileData> users;

  const RunningCallScreenCopy(
      {required this.callerId,
      // TODO: stop propagate bloc here
      required this.callsBloc,
      required this.users,
      Key? key})
      : super(key: key);

  @override
  State<RunningCallScreenCopy> createState() => _RunningCallScreenCopyState();
}

class _RunningCallScreenCopyState extends State<RunningCallScreenCopy> {
  final sipChannel = const MethodChannel("com.application.chat/sip");
  final callServiceEventChannel =
      const EventChannel("event.channel/call_service");
  late final StreamSubscription callServiceBlocSubscription;
  bool isMute = false;
  bool isSpeaker = false;
  bool isConnected = false;
  Timer? timer;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  String digitSeconds = "00";
  String digitMinutes = "00";
  String digitHours = "00";
  String? username;



  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if(localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }
      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print("USEEEERS    ${widget.users}");
    username = widget.users.firstWhere((el) => el.id.toString() == widget.callerId).lastname;
    callServiceBlocSubscription = widget.callsBloc.stream.listen((state) {
      if (state is EndedCallServiceState) {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute == "/home_screen/running_call_screen") {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    callServiceBlocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: ,
      backgroundColor: const Color(0xFF474747),
      body: BlocBuilder(
        bloc: widget.callsBloc,
        builder: (context, state) {
        if (state is ConnectedCallState && timer == null)  startTimer();
        return Column(
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
              username ?? widget.callerId,
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            SizedBox(
              height: 3,
            ),
            if (state is ConnectedCallState) Text(
              "$digitHours:$digitMinutes:$digitSeconds",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Expanded(
              child: SizedBox(),
            ),
            state is ConnectedCallState
                ? Row(
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
                  )
                : SizedBox(),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (state is IncomingCallState) GestureDetector(
                  onTap: () {
                    print("NAVIGATOR   ${ModalRoute.of(context)?.settings.name}");
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
                            borderRadius: BorderRadius.all(Radius.circular(50))),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Image.asset(
                            'assets/images/decline_icon.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const Text("Accept",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print("NAVIGATOR   ${ModalRoute.of(context)?.settings.name}");
                    // declineCall();
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
        );
        }
      ),
    );
  }
}

class CallScreenArguments {
  final String callerId;
  final Bloc? callsBloc;
  final List<UserProfileData> users;

  const CallScreenArguments({
    required this.callerId,
    required this.callsBloc,
    required this.users,
  });
}


