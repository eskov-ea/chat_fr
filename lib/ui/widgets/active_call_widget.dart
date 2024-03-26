import 'dart:async';
import 'dart:io';
import 'package:chat/bloc/calls_bloc/call_state_extension.dart';
import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/call_timer.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/screens/running_call_screen.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';


class RunningCallWidget extends StatefulWidget {
  const RunningCallWidget({
    required this.userId,
    Key? key
  }):super(key: key);

  final String userId;

  @override
  State<RunningCallWidget> createState() => _RunningCallWidgetState();
}

class _RunningCallWidgetState extends State<RunningCallWidget> {
  String callDuration = "00:00:00";
  String? callId;
  String? username;

  void _openCallScreen() {
    if (kIsWeb) return;
    try {
      final CallState state = BlocProvider.of<CallsBloc>(context).state;
      if (Platform.isIOS && state is! IncomingCallState || !Platform.isIOS) {
        final activeCallId = state.activeCalls.entries.firstWhere((call) => call.value.active).key;
        Navigator.of(context).pushNamed(
            MainNavigationRouteNames.runningCallScreen,
            arguments: CallScreenArguments(userId: widget.userId.toString(), callId: activeCallId));
      }
    } catch(_) {

    }
  }

  String? getUsername(String? caller) {
    if (caller == null) return null;

    final callerUser = BlocProvider.of<UsersViewCubit>(context)
        .usersBloc
        .state
        .users
        .firstWhere(
            (el) => "${SipConfig.getPrefix()}${el.id}" == caller);
    final uName = "${callerUser.firstname} ${callerUser.lastname}";
    return uName;

  }

  void onCallReleased() {
    setState(() {
      username = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallsBloc, CallState>(
      listener: (context, state) {
        if (state is EndedCallState || state is EndCallWithNoLogState) {
          onCallReleased();
        }
      },
      builder: (context, state) {
        if (state.activeCalls.isEmpty) {
          return const SizedBox.shrink();
        } else {
          ActiveCallModel? activeCall;
          for (var call in state.activeCalls.values) {
            if (call.active) activeCall = call;
          }
          final caller = activeCall?.call.fromCaller == widget.userId ? activeCall?.call.toCaller : activeCall?.call.fromCaller;
          if (activeCall == null) return const SizedBox.shrink();
          /// either the call outgoing and ringing
          if (CallStateExtension.OUTGOING_STATE.contains(activeCall.callState)) {
            return ProgressCallWidget(message: "Исходящий вызов", username: getUsername(caller), screenCallback: _openCallScreen);
          }
          /// either the call is incoming and ringing
          if (CallStateExtension.INCOMING_STATE.contains(activeCall.callState)) {
            return ProgressCallWidget(message: "Входящий вызов", username: getUsername(caller), screenCallback: _openCallScreen);
          }
          /// if the call is connected and stream running
          if (CallStateExtension.RUNNING_STATE.contains(activeCall.callState)) {
            return RunningProgressCallWidget(timer: activeCall.timer, initDurationValue: activeCall.timer.lastValue,
              screenCallback: _openCallScreen, );
          }
          /// if the call has not been automatically switched to active state
          if (CallStateExtension.PAUSED_STATE.contains(activeCall.callState)) {
            return ProgressCallWidget(message: "Вызов на ожидании", username: getUsername(caller), screenCallback: _openCallScreen);
          }
          return const SizedBox.shrink();
        }
      }
    );
  }
}

class RunningProgressCallWidget extends StatefulWidget {
  const RunningProgressCallWidget({
    required this.screenCallback,
    required this.initDurationValue,
    required this.timer,
    Key? key
  }) :super(key: key);

  final void Function() screenCallback;
  final CallTimer timer;
  final String initDurationValue;

  @override
  State<RunningProgressCallWidget> createState() => _RunningProgressCallWidgetState();
}

class _RunningProgressCallWidgetState extends State<RunningProgressCallWidget> {

  late final StreamSubscription callDurationSubscription;
  String duration = "00:00:00";

  @override
  void initState() {
    super.initState();
    setState(() {
      duration = widget.initDurationValue;
    });
    callDurationSubscription = widget.timer.stream.listen((event) {
      setState(() {
        duration = event;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.screenCallback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        color: AppColors.activeCall,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(duration,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressCallWidget extends StatelessWidget {
  const ProgressCallWidget({
    required this.screenCallback,
    required this.message,
    required this.username,
    Key? key
  }) :super(key: key);

  final void Function() screenCallback;
  final String message;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: screenCallback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        color: AppColors.activeCall,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(username ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(message,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}
