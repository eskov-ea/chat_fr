import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MuteButton extends StatefulWidget {
  const MuteButton({super.key});

  @override
  State<MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<MuteButton> {

  final audioDeviceMethodChannel = const MethodChannel("com.application.chat/audio_devices");
  bool isMute = false;
  bool isExecuting = false;
  Future<void> toggleMute() async {
    if (isExecuting) return;
    isExecuting = true;
    final result = await audioDeviceMethodChannel.invokeMethod("TOGGLE_MUTE");
    setState(() {
      isMute = result;
      isExecuting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleMute,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              padding: const EdgeInsets.all(25),
              child: Image.asset(
                'assets/call_controls/mute.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 5,),
          const SizedBox(
            width: 80,
            child: Text("Выкл. микр.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}