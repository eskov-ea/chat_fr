import 'package:chat/ui/widgets/call_audio_device_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CallControlsWidget extends StatelessWidget {
  const CallControlsWidget({
    required this.setAvailableAudioDeviceOptions,
    required this.optionsMenuOpen,
    required this.onToggleSpeaker,
    required this.onCallDecline,
    required this.onMessage,
    required this.onCallAccept,
    required this.toggleAudioOptionsPanel,
    required this.setCurrentDeviceId,
    required this.isSipServiceActive,
    required this.isCallRunning,
    required this.isCallingIncoming,
    super.key
  });

  final bool optionsMenuOpen;
  final bool isSipServiceActive;
  final bool isCallingIncoming;
  final bool isCallRunning;
  final Function(Map<int, List<String>>) setAvailableAudioDeviceOptions;
  final Function(int) setCurrentDeviceId;
  final Function() onMessage;
  final Function() onToggleSpeaker;
  final Function() onCallDecline;
  final Function() onCallAccept;
  final Function() toggleAudioOptionsPanel;


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   const MuteButton(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: toggleAudioOptionsPanel,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // margin: EdgeInsets.symmetric(horizontal: 20),
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF626262),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Image.asset(
                                  'assets/call_controls/message_icon.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const SizedBox(
                              width: 80,
                              child: Text("Сообщение",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, fontSize: 14)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AudioOutputDeviceWidget(
                      toggleAudioOptionsPanel: toggleAudioOptionsPanel,
                      setAvailableAudioDeviceOptions: setAvailableAudioDeviceOptions,
                      setCurrentDeviceId: setCurrentDeviceId,
                      optionsMenuOpen: optionsMenuOpen
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: onCallAccept,
                  child: Row(
                    mainAxisAlignment: isCallingIncoming ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                    children: [
                      isCallingIncoming ? Column(
                        children: [
                          GestureDetector(
                            onTap: onCallAccept,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Image.asset(
                                  'assets/call_controls/accept_icon.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const Text("Принять",
                              style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ) : const SizedBox.shrink(),
                      SizedBox(height: isCallingIncoming ? 10 : 0,),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onCallDecline,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(Radius.circular(50))),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Image.asset(
                                  'assets/call_controls/decline_icon.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const SizedBox(
                            width: 80,
                            child: Text("Отменить",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
              ],
            ),
          ),
          !isSipServiceActive
            ? Container(
              height: 250,
              width: MediaQuery.of(context).size.width,
            color: Color(0x34FFFFFF),
            )
            : SizedBox.shrink()
        ],
      )
    );
  }
}

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

