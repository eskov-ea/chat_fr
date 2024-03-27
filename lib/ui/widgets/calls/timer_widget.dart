import 'dart:async';

import 'package:chat/services/helpers/call_timer.dart';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    required this.timer,
    super.key
  });

  final CallTimer timer;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {

  String callDuration = "00:00:00";
  late final StreamSubscription callTimeSubscription;

  @override
  void initState() {
    super.initState();
    print('TimerWidget created');
    callTimeSubscription = widget.timer.stream.listen((time) {
      setState(() {
        callDuration = time;
      });
    });
  }

  @override
  void dispose() {
    print('TimerWidget destroyed');
    callTimeSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Text(
      callDuration,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }
}
