import 'dart:async';
import 'package:chat/bloc/calls_bloc/call_state_extension.dart';
import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {

  String callDuration = "00:00:00";
  StreamSubscription? callTimeSubscription;
  late final StreamSubscription callServiceSubscription;
  bool timerVisible = false;

  @override
  void initState() {
    print('TimerWidget:: created');
    callServiceSubscription = BlocProvider.of<CallsBloc>(context).stream.listen((state) {
      print('TimerWidget:: active call $state');
      if (state is ConnectedCallState) {
        callTimeSubscription?.cancel();
        callTimeSubscription = null;

        callTimeSubscription = state.activeCall?.timer.stream.listen((event) {
          setState(() {
            callDuration = event;
          });
        });
      } else if (state is ResumedCallState) {
        callTimeSubscription?.cancel();
        callTimeSubscription = null;

        callTimeSubscription = state.activeCall?.timer.stream.listen((event) {
          setState(() {
            callDuration = event;
          });
        });
      }

      ActiveCallModel? activeCall = state.activeCall;
      if (activeCall != null && CallStateExtension.RUNNING_STATE.contains(activeCall.callState)) {
        if (!timerVisible) {
          setState(() {
            timerVisible = true;
          });
        }
      } else {
        if (timerVisible) {
          setState(() {
            timerVisible = false;
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    print('TimerWidget:: destroyed');
    callTimeSubscription?.cancel();
    callServiceSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        callDuration,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
