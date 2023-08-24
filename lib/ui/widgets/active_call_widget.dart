import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/helpers/call_timer.dart';
import '../../theme.dart';


class RunningCallStatusWidget extends StatefulWidget {
  const RunningCallStatusWidget({
    required this.screenCallback,
    Key? key
  }):super(key: key);

  final void Function() screenCallback;

  @override
  State<RunningCallStatusWidget> createState() => _RunningCallStatusWidgetState();
}

class _RunningCallStatusWidgetState extends State<RunningCallStatusWidget> {
  final timer = CallTimer.getInstance();
  late final StreamSubscription _streamSubscription;
  String callDuration = "00:00:00";

  @override
  void initState() {
    super.initState();
    _streamSubscription = timer.stream().listen((time) {
      setState(() {
        callDuration = time;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.screenCallback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        color: AppColors.activeCall,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text("Вернуться к звонку - $callDuration",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveCallStatusWidget extends StatelessWidget {
  const ActiveCallStatusWidget({
    required this.screenCallback,
    required this.message,
    Key? key
  }) :super(key: key);

  final void Function() screenCallback;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: screenCallback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        color: AppColors.activeCall,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(message,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
