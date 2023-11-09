import 'dart:async';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/calls_bloc/calls_bloc.dart';
import '../../services/global.dart';
import '../../services/helpers/call_timer.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../navigation/main_navigation.dart';
import '../widgets/call_controls_widget.dart';

class RunningCallScreen extends StatefulWidget {

  const RunningCallScreen({
    required this.userId,
    Key? key
  }) : super(key: key);

  final String? userId;

  @override
  State<RunningCallScreen> createState() => _RunningCallScreenState();
}

class _RunningCallScreenState extends State<RunningCallScreen> {
  final sipChannel = const MethodChannel("com.application.chat/sip");
  final callServiceEventChannel =
      const EventChannel("event.channel/call_service");
  late final StreamSubscription _callServiceBlocSubscription;
  bool isMute = false;
  bool isSpeaker = false;
  bool isConnected = false;
  final timer = CallTimer.getInstance();
  String? username = "Не удалось определить номер";
  late final StreamSubscription _streamSubscription;
  String? callDuration;

  bool isSipServiceActive = true;
  late bool isCallingIncoming;
  late bool isCallingOutgoing;
  late bool isCallInProgress;

  void setUsername(String callerName) {
    if (username == null || username == "Не удалось определить номер") {
      try {
        final callerUser = BlocProvider.of<UsersViewCubit>(context)
            .usersBloc
            .state
            .users
            .firstWhere(
                (el) => "${SipConfig.getPrefix()}${el.id}" == callerName);
        final uName = "${callerUser.firstname} ${callerUser.lastname}";
        setState(() {
          username = uName;
        });
      } catch (_) {
        username = "Не удалось определить номер";
      }
    }
  }

  void _onCallStateChanged(CallState state) {
    if (state is IncomingCallState) {
      setUsername(state.callData.fromCaller);
      setState(() {
        isCallingIncoming = true;
        isCallingOutgoing = false;
        isCallInProgress = false;
      });
    } else if (state is ConnectedCallState) {
      if (widget.userId == state.callData.fromCaller.substring(1, state.callData.fromCaller.length)) {
        setUsername(state.callData.toCaller);
      } else {
        setUsername(state.callData.fromCaller);
      }
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = false;
        isCallInProgress = true;
      });
    } else if (state is StreamRunningCallState) {
      if (widget.userId == state.callData.fromCaller.substring(1, state.callData.fromCaller.length)) {
        setUsername(state.callData.toCaller);
      } else {
        setUsername(state.callData.fromCaller);
      }
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = false;
        isCallInProgress = true;
      });
    } else if (state is OutgoingCallState) {
      setUsername(state.callData.toCaller);
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = true;
        isCallInProgress = false;
      });
    } else if (state is OutgoingRingingCallState) {
      setUsername(state.callData.toCaller);
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = true;
        isCallInProgress = false;
      });
    }
  }


  
  @override
  void initState() {
    _onCallStateChanged(BlocProvider.of<CallsBloc>(context).state);
    callDuration = timer.lastValue;
    _streamSubscription = timer.stream().listen((time) {
      setState(() {
        callDuration = time;
      });
    });
    _callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen(_onCallStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _callServiceBlocSubscription.cancel();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF474747),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/calls_wallpaper.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomSizeContainer(
          Column(
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
            const SizedBox(
              height: 10,
            ),
            Text(
              username ?? "Не удалось определить номер",
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(
              height: 3,
            ),
            isCallInProgress ? Text(
              callDuration ?? "00:00:00",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ) : const SizedBox.shrink(),
            const Expanded(
              child: SizedBox(),
            ),
            CallControlsWidget(
              isMute: isMute,
              isSpeaker: isSpeaker,
              isConnected: isConnected,
              isCallingIncoming: isCallingIncoming,
              isSipServiceActive: true,
              onToggleMute: () async {
                final result = await toggleMute();
                setState(() {
                  isMute = result;
                });
              },
              onToggleSpeaker: () async {
                final result = await toggleSpeaker();
                setState(() {
                  isSpeaker = result;
                });
              },
              onCallDecline: () {
                declineCall();
                Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
              },
              onCallAccept: () {
                acceptCall();
                setState(() {
                  isCallInProgress = true;
                });
              },
              isCallRunning: isCallInProgress,
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ), context),
      )
    );
  }
}

class CallScreenArguments {
  final String? userId;

  const CallScreenArguments({
    required this.userId
  });
}


