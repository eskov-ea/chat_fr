import 'package:flutter/material.dart';

class SwitchCallButton extends StatefulWidget {
  const SwitchCallButton({super.key});

  @override
  State<SwitchCallButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<SwitchCallButton> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: const Color(0x80ffffff),
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