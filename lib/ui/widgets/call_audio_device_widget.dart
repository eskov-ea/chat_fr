import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


///     Linphone SDK AudioDevice.Type enum
///     0:Unknown, 1:Microphone, 2:Earpiece, 3:Speaker, 4:Bluetooth, 5:BluetoothA2DP,
///     6:Telephony, 7:AuxLine, 8:GenericUsb, 9:Headset, 10:Headphones


const Map<int, List<String>> deviceTypeToDescriptionMap = {
  0: ["Неизвестно", "assets/call_controls/unknown.png"],
  1: ["Микрофон", "assets/call_controls/microphone.png"],
  2: ["Телефон", "assets/call_controls/phone.png"],
  3: ["Динамик", "assets/call_controls/speaker_icon_white.png"],
  4: ["Гарнитура", "assets/call_controls/earbuds.png"],
  5: ["Гарнитура", "assets/call_controls/earbuds.png"],
  6: ["Телефон", "assets/call_controls/phone.png"],
  7: ["Внешний", "assets/call_controls/audio-jack.png"],
  8: ["Внешний", "assets/call_controls/audio-jack.png"],
  9: ["Гарнитура", "assets/call_controls/earbuds.png"],
  10: ["Гарнитура", "assets/call_controls/earbuds.png"]
};


class AudioOutputDeviceWidget extends StatefulWidget {
  final Function() toggleAudioOptionsPanel;
  final Function(Map<int, List<String>>) setAvailableAudioDeviceOptions;
  final Function(int) setCurrentDeviceId;
  final bool optionsMenuOpen;
  const AudioOutputDeviceWidget({
    required this.setAvailableAudioDeviceOptions,
    required this.setCurrentDeviceId,
    required this.toggleAudioOptionsPanel,
    required this.optionsMenuOpen,
    super.key
  });

  @override
  State<AudioOutputDeviceWidget> createState() => _AudioOutputDeviceWidgetState();
}

class _AudioOutputDeviceWidgetState extends State<AudioOutputDeviceWidget> {

  final audioDeviceMethodChannel = const MethodChannel("com.application.chat/audio_devices");
  final audioDeviceEventChannel = const EventChannel("event.channel/audio_device_channel");
  late final StreamSubscription audioDeviceEventChannelSubscription;
  late final StreamSubscription audioOptionValueListener;
  List<int> availableAudioOutputsDevices = [];
  final int defaultAudioOutputDevice = 2;
  bool isMute = false;
  bool isSpeaker = false;
  late List<Widget> audioDeviceOutputsWidgets;
  int currentAudioDevice = 2;

  Map<String, dynamic> _parseAudioDeviceChannelEvent(data) {
    var json;
    if (data.runtimeType == String) {
      json = jsonDecode(data);
    } else {
      json = data;
    }
    return {
      "event": json["event"],
      "data": json["data"]
    };
  }

  void _onAudioDeviceStateChange(dynamic event) {
    final e = _parseAudioDeviceChannelEvent(event);
    if (e["event"] == "DEVICE_LIST") {
      final List<int> devices = [];
      final Map<int, List<String>> ad = {};
      e["data"].forEach((d) {
        d as int;
        if (d != 1) {
          devices.add(d);
          ad.addAll({d: [deviceTypeToDescriptionMap[d]![0], deviceTypeToDescriptionMap[d]![1]]});
        }
      });
      print("setAvailableAudioDeviceOptions ad  $ad");
      widget.setAvailableAudioDeviceOptions(ad);
      availableAudioOutputsDevices = devices;
      setState(() {});
    } else if (e["event"] == "CURRENT_DEVICE_ID") {
      final deviceId = e["data"];
      print("CURRENT_DEVICE, $deviceId");
      widget.setCurrentDeviceId(deviceId);
      setState(() {
        currentAudioDevice = deviceId;
      });
    }
  }

  void toggleSpeaker() async{
    final request = await audioDeviceMethodChannel.invokeMethod("TOGGLE_SPEAKER");
    final result = request["data"];
    setState(() {
      isSpeaker = result;
    });
  }

  Widget _makeAudioOutputDeviceWidget() {
    if (availableAudioOutputsDevices.isEmpty) {
      availableAudioOutputsDevices.add(defaultAudioOutputDevice);
    }

    if (availableAudioOutputsDevices.length < 3) {
      return GestureDetector(
        onTap: toggleSpeaker,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: currentAudioDevice == 3
                      ? Colors.white
                      : const Color(0x80ffffff),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/call_controls/speaker_icon.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const SizedBox(
              width: 80,
              child: Text("Динамик",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: widget.toggleAudioOptionsPanel,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: widget.optionsMenuOpen
                      ? const Color(0xE6FFFFFF)
                      : const Color(0x80ffffff),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  deviceTypeToDescriptionMap[currentAudioDevice]?[1] ?? 'assets/call_controls/phone.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const SizedBox(
              width: 80,
              child: Text("Телефон",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    audioDeviceEventChannelSubscription = audioDeviceEventChannel
        .receiveBroadcastStream()
        .listen(_onAudioDeviceStateChange);
    audioDeviceMethodChannel.invokeMethod("GET_DEVICE_LIST");
    audioDeviceMethodChannel.invokeMethod("GET_CURRENT_AUDIO_DEVICE");
    audioDeviceOutputsWidgets = [

    ];
    super.initState();
  }

  @override
  void dispose() {
    audioDeviceEventChannelSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      child: Stack(
        children: [
          _makeAudioOutputDeviceWidget(),

        ]
      ),
    );
  }
}
