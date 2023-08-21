import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/helpers/call_timer.dart';
import '../../theme.dart';


class ActiveCallStatusWidget extends StatefulWidget {
  const ActiveCallStatusWidget({
    required this.screenCallback,
    Key? key
  }):super(key: key);

  final void Function() screenCallback;

  @override
  State<ActiveCallStatusWidget> createState() => _ActiveCallStatusWidgetState();
}

class _ActiveCallStatusWidgetState extends State<ActiveCallStatusWidget> {
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
        height: 50,
        color: AppColors.activeCall,
        child: Center(
          child: Text("Вернуться к звонку - $callDuration",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class IncomingCallStatusWidget extends StatelessWidget {
  const IncomingCallStatusWidget({
    required this.screenCallback,
    Key? key
  }) :super(key: key);

  final void Function() screenCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: screenCallback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: AppColors.activeCall,
        child: Center(
          child: Text("Входящий вызов",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
