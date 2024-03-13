import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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

  final audioDeviceMethodChannel = const MethodChannel("com.application.chat/audio_devices");
  late final StreamSubscription _callServiceBlocSubscription;
  final timer = CallTimer.getInstance();
  String? username = "Не удалось определить номер";
  late final StreamSubscription _streamSubscription;
  String? callDuration;
  bool isSipServiceActive = true;
  late bool isCallingIncoming;
  late bool isCallingOutgoing;
  late bool isCallInProgress;
  double isAudioOptionPanelVisible = 0;
  Map<int, List<String>> availableAudioDevices = {};
  int? currentDeviceId;

  void setAvailableAudioDeviceOptions(Map<int, List<String>> devices) {
    log("setAvailableAudioDeviceOptions  $devices");
    setState(() {
      availableAudioDevices = devices;
    });
  }
  void setCurrentDeviceId(int id) {
    setState(() {
      currentDeviceId = id;
    });
  }

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
      setUsername(state.callerId);
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

  void toggleAudioOptionsPanel() {
    setState(() {
      isAudioOptionPanelVisible = isAudioOptionPanelVisible == 0 ? 1 : 0;
    });
  }
  
  @override
  void initState() {
    super.initState();
    _onCallStateChanged(BlocProvider.of<CallsBloc>(context).state);
    callDuration = timer.lastValue;
    _streamSubscription = timer.stream().listen((time) {
      setState(() {
        callDuration = time;
      });
    });
    _callServiceBlocSubscription = BlocProvider.of<CallsBloc>(context).stream.listen(_onCallStateChanged);
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
      body: GestureDetector(
        onTap: () {
          if (isAudioOptionPanelVisible == 1) {
            setState(() {
              isAudioOptionPanelVisible = 0;
            });
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/calls_wallpaper.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: CustomSizeContainer(
              Stack(
                children: [
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
                        setAvailableAudioDeviceOptions: setAvailableAudioDeviceOptions,
                        setCurrentDeviceId: setCurrentDeviceId,
                        isCallingIncoming: isCallingIncoming,
                        optionsMenuOpen: isAudioOptionPanelVisible == 1,
                        isSipServiceActive: true,
                        toggleAudioOptionsPanel: toggleAudioOptionsPanel,
                        onMessage: () {
                          // audioDeviceMethodChannel.invokeMethod("GET_DEVICE_LIST");
                        },
                        onToggleSpeaker: () async {
                          // final result = await toggleSpeaker();
                          // setState(() {
                          //   isSpeaker = result;
                          // });
                        },
                        onCallDecline: () {
                          Navigator.of(context).pop;
                          declineCall();
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
                  ),
                  isAudioOptionPanelVisible == 1 ? _audioOptions() : const SizedBox.shrink()
                ],
              ),
              context),
        ),
      )
    );
  }


  Widget _audioOptions () {
    return Positioned(
      right: 20,
      bottom: 310,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastEaseInToSlowEaseOut,
        opacity: isAudioOptionPanelVisible,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.black54,
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 120,
                spreadRadius: 30
              )
            ]
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._getAudioOptionsItems()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAudioOptionsItems() {
    final List<Widget> devices = [];
    availableAudioDevices.forEach((key, value) {
      devices.add(
          Material(
            color: Colors.transparent,
            child: Ink(
              height: 50,
              child: InkWell(
                onTap: () {
                  audioDeviceMethodChannel.invokeMethod("SET_AUDIO_DEVICE", {"device_id": key});
                  setState(() {
                    isAudioOptionPanelVisible = 0;
                  });
                },
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                ),
                splashColor: Colors.white24,
                child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: currentDeviceId == key ? Color(0xFF646464) : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 40,
                          child: currentDeviceId == key ? Icon(Icons.done, color: Colors.white) : SizedBox(),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(value[0],
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius
                                  .circular(50)),
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(
                                      value[1])
                              )
                          ),

                        ),
                        const SizedBox(width: 20)
                      ],
                    )
                ),
              ),
            ),
          )
      );
    });
    return devices;
  }

}


class CallScreenArguments {
  final String? userId;

  const CallScreenArguments({
    required this.userId
  });
}


