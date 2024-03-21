import 'dart:async';
import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:chat/models/call_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchCallButton extends StatefulWidget {
  final Function() switchCallPanelToggleCallback;
  const SwitchCallButton({
    required this.switchCallPanelToggleCallback,
    super.key
  });

  @override
  State<SwitchCallButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<SwitchCallButton> {

  late final StreamSubscription<CallState> _callEventSubscription;
  Map<String, CallModel> _activeCalls = {};

  @override
  void initState() {
    super.initState();
    _callEventSubscription = BlocProvider.of<CallsBloc>(context).stream.listen(_onCallEvent);
  }


  void _onCallEvent(CallState state) {
    setState(() {
      _activeCalls = state.activeCalls;
    });
  }

  @override
  void dispose() {
    _callEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCalls.isEmpty) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0x809d9d9d),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: SizedBox()
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text("",
              style:
              TextStyle(color: Colors.white, fontSize: 14)),
        ],
      );
    } else if (_activeCalls.length == 1) {
      return Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: const Color(0x809d9d9d),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Image.asset(
                'assets/call_controls/switch.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text("1 активный",
              style:
              TextStyle(color: Colors.white, fontSize: 14)),
        ],
      );
    } else {
      return Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0x809d9d9d),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Image.asset(
                  'assets/call_controls/switch.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Text("Выбрать",
              style:
              TextStyle(color: Colors.white, fontSize: 14)),
        ],
      );
    }
  }
}
