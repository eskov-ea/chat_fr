import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat/bloc/calls_bloc/call_state_extension.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/widgets/calls/incoming_call_receiver_during_another_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/calls_bloc/calls_bloc.dart';
import '../../services/global.dart';
import '../../services/helpers/call_timer.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../widgets/calls/call_controls_widget.dart';

class RunningCallScreen extends StatefulWidget {

  const RunningCallScreen({
    required this.userId,
    required this.callId,
    Key? key
  }) : super(key: key);

  final String? userId;
  final String callId;

  @override
  State<RunningCallScreen> createState() => _RunningCallScreenState();
}

class _RunningCallScreenState extends State<RunningCallScreen> {

  final audioDeviceMethodChannel = const MethodChannel("com.application.chat/audio_devices");
  final sipMethodChannel = const MethodChannel("com.application.chat/sip");
  late final StreamSubscription _callServiceBlocSubscription;
  String username = "Не удалось определить номер";
  late final StreamSubscription _streamSubscription;
  String? callDuration;
  bool isSipServiceActive = true;
  bool isCallingIncoming = false;
  bool isCallingOutgoing = false;
  bool isCallInProgress = true;
  bool isCallPaused = false;
  double isAudioOptionPanelVisible = 0;
  Map<int, List<String>> availableAudioDevices = {};
  int? currentDeviceId;
  bool isSwitchCallPanelVisible = false;
  String? activeCallId;
  Map<String, ActiveCallModel> activeCalls = {};

  bool incomingCallDuringRunningCall = false;
  String? incomingCallerDuringRunningCall;

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

  void setToggleSwitchCallPanelVisibility() {
    setState(() {
      isSwitchCallPanelVisible = !isSwitchCallPanelVisible;
    });
  }

  void setUsername(String callerName) {
    if (username == "Не удалось определить номер") {
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
      } catch (err) {
        print('find username err: $err');
        username = "Не удалось определить номер";
      }
    }
  }

  void _onCallStateChanged(CallState state) {

    if (state is EndedCallState) {
      if (state.activeCalls.isNotEmpty) {
        setState(() {
          activeCallId = state.activeCalls.values.first.call.id;
        });

      }
    }

    activeCalls = state.activeCalls;
    final activeCall = state.activeCalls[activeCallId];
    /// If call ends the calls_bloc removes the call from active calls state
    /// So then we should check if there is any paused calls and resume it either pop back to homescreen
    if (activeCall == null) {
      if (state.activeCalls.isEmpty) {
        print('Should pop to homescreen');
        Navigator.of(context).popUntil((route) => route.settings.name == MainNavigationRouteNames.homeScreen);
      } else {
        /// There is a paused call - we have to resume it
      }
    } else if (CallStateExtension.INCOMING_STATE.contains(activeCall.callState)) {
      if (!isCallInProgress) {
        setUsername(activeCall.call.fromCaller);
        setState(() {
          isCallingIncoming = true;
          isCallingOutgoing = false;
          isCallInProgress = false;
        });
      } else {
        showIncomingCallDyringRunningCallWidget(state.);
      }
    } else if (CallStateExtension.OUTGOING_STATE.contains(activeCall.callState)) {
      setUsername(activeCall.call.toCaller);
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = true;
        isCallInProgress = false;
      });
    } else if (CallStateExtension.RUNNING_STATE.contains(activeCall.callState)) {
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = false;
        isCallInProgress = true;
      });
    } else if (CallStateExtension.PAUSED_STATE.contains(activeCall.callState)) {
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = false;
        isCallInProgress = true;
      });
    } else if (CallStateExtension.ERROR_STATE.contains(activeCall.callState)) {
      setState(() {
        isCallingIncoming = false;
        isCallingOutgoing = false;
        isCallInProgress = true;
      });
    }








    // if (state is IncomingCallState) {
    //   if (state.activeCalls.length == 1) {
    //     setUsername(state.callerId);
    //     setState(() {
    //       isCallingIncoming = true;
    //       isCallingOutgoing = false;
    //       isCallInProgress = false;
    //     });
    //   } else {
    //     final callerUser = BlocProvider.of<UsersViewCubit>(context)
    //         .usersBloc
    //         .state
    //         .users
    //         .firstWhere(
    //             (el) => "${SipConfig.getPrefix()}${el.id}" == state.callerId);
    //     final uName = "${callerUser.firstname} ${callerUser.lastname}";
    //     setState(() {
    //       incomingCallerDuringRunningCall = uName;
    //       incomingCallDuringRunningCall = true;
    //     });
    //   }
    // } else if (state is ConnectedCallState) {
    //   if (widget.userId == state.callData.fromCaller.substring(1, state.callData.fromCaller.length)) {
    //     setUsername(state.callData.toCaller);
    //   } else {
    //     setUsername(state.callData.fromCaller);
    //   }
    //   setState(() {
    //     activeCallId = state.callData.id;
    //     isCallingIncoming = false;
    //     isCallingOutgoing = false;
    //     isCallInProgress = true;
    //   });
    // } else if (state is StreamRunningCallState) {
    //   if (widget.userId == state.callData.fromCaller.substring(1, state.callData.fromCaller.length)) {
    //     setUsername(state.callData.toCaller);
    //   } else {
    //     setUsername(state.callData.fromCaller);
    //   }
    //   setState(() {
    //     isCallingIncoming = false;
    //     isCallingOutgoing = false;
    //     isCallInProgress = true;
    //   });
    // } else if (state is OutgoingCallState) {
    //   setUsername(state.callData.toCaller);
    //   setState(() {
    //     activeCallId = state.callData.id;
    //     isCallingIncoming = false;
    //     isCallingOutgoing = true;
    //     isCallInProgress = false;
    //   });
    // } else if (state is OutgoingRingingCallState) {
    //   setUsername(state.callData.toCaller);
    //   setState(() {
    //     isCallingIncoming = false;
    //     isCallingOutgoing = true;
    //     isCallInProgress = false;
    //   });
    // } else if (state is PausedCallState) {
    //   setState(() {
    //     isCallPaused = true;
    //     isCallInProgress = false;
    //   });
    // } else if (state is ResumedCallState) {
    //   setState(() {
    //     isCallPaused = false;
    //     isCallInProgress = true;
    //   });
    // } else if (state is EndedCallState) {
    //
    //   activeCalls.forEach((key, value) {
    //     if (key != state.callData.id) {
    //       setState(() {
    //         activeCallId = key;
    //         return;
    //       });
    //     }
    //     sipMethodChannel.invokeMethod("RESUME_CALL", {"id": activeCallId});
    //   });
    // }


  }

  void toggleAudioOptionsPanel() {
    setState(() {
      isAudioOptionPanelVisible = isAudioOptionPanelVisible == 0 ? 1 : 0;
    });
  }

  void startConference() {

  }
  
  @override
  void initState() {
    super.initState();
    activeCallId = widget.callId;
    final cBloc = BlocProvider.of<CallsBloc>(context);
    _onCallStateChanged(cBloc.state);
    callDuration = cBloc.state.activeCalls[widget.callId]!.timer.lastValue;
    _streamSubscription = cBloc.state.activeCalls[widget.callId]!.timer.stream.listen((time) {
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
    if (isCallingIncoming == false && isCallingOutgoing == false && isCallInProgress == false) {
      return Scaffold(
        backgroundColor: const Color(0xFF474747),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/calls_wallpaper.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 210,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет активного звонка',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  const Text('Такое могло произойти, например, при попытке перейти на экран звонка, который завершился.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.black87,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.homeScreen);
                        },
                        splashColor: Colors.white24,
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: const Center(
                          child: Text('Домой',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ),
        ),
      );
    }
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Row(
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCallPaused)
                            SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset('assets/call_controls/pause_white.png'),
                          ),
                          if (isCallPaused)
                            const SizedBox(width: 10),
                          Text(
                            username ?? "Не удалось определить номер",
                            style: TextStyle(color: Colors.white, fontSize: 26, height: 1),
                          ),
                        ],
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
                        switchCallPanelToggleCallback: setToggleSwitchCallPanelVisibility,
                        setAvailableAudioDeviceOptions: setAvailableAudioDeviceOptions,
                        setCurrentDeviceId: setCurrentDeviceId,
                        isCallingIncoming: isCallingIncoming,
                        optionsMenuOpen: isAudioOptionPanelVisible == 1,
                        isSipServiceActive: true,
                        isCallPaused: isCallPaused,
                        isCallRunning: isCallInProgress,
                        toggleAudioOptionsPanel: toggleAudioOptionsPanel,
                        onCallHangup: () {
                          hangupCall();
                        },
                        onCallDecline: () {
                          Navigator.of(context).pop;
                          declineCall(activeCallId!);
                        },
                        onCallAccept: () {
                          acceptCall(activeCallId!);
                          setState(() {
                            isCallInProgress = true;
                          });
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                    ],
                  ),
                  isAudioOptionPanelVisible == 1 ? _audioOptions() : const SizedBox.shrink(),
                  if (incomingCallDuringRunningCall) IncomingCallReceivedDuringCallWidget(caller: incomingCallerDuringRunningCall!)
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

  Widget _activeCallsOptions () {
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
                ...getActiveCallsItems()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getActiveCallsItems() {
    final List<Widget> calls = [];
    if (activeCalls.length < 2) return calls;
    activeCalls.forEach((key, value) {
      calls.add(
          Material(
            color: Colors.transparent,
            child: Ink(
              height: 50,
              child: InkWell(
                onTap: () {
                  sipMethodChannel.invokeMethod("SET_ACTIVE_CALL", {"call_id": key});
                  setToggleSwitchCallPanelVisibility();
                },
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                ),
                splashColor: Colors.white24,
                child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: value.callState == key ? Color(0xFF646464) : Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    child: Text("")
                ),
              ),
            ),
          )
      );
    });
    return calls;
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
  final String callId;

  const CallScreenArguments({
    required this.userId,
    required this.callId
  });
}


