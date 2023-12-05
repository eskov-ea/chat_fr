import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CallControlsWidget extends StatelessWidget {
  const CallControlsWidget({
    required this.isMute,
    required this.isSpeaker,
    required this.isConnected,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onCallDecline,
    required this.onCallAccept,
    required this.isSipServiceActive,
    required this.isCallRunning,
    required this.isCallingIncoming,
    super.key
  });

  final bool isMute;
  final bool isSpeaker;
  final bool isConnected;
  final bool isSipServiceActive;
  final bool isCallingIncoming;
  final bool isCallRunning;
  final Function() onToggleMute;
  final Function() onToggleSpeaker;
  final Function() onCallDecline;
  final Function() onCallAccept;


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
                    GestureDetector(
                      onTap: onToggleMute,
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
                                'assets/images/mute.png',
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
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                                'assets/images/message_icon.png',
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
                    GestureDetector(
                      onTap: onToggleSpeaker,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                color: isSpeaker
                                    ? Colors.white
                                    : const Color(0x80ffffff),
                                borderRadius: const BorderRadius.all(Radius.circular(50))),
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Image.asset(
                                'assets/images/speaker_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const SizedBox(
                            width: 80,
                            child: Text("Динамик",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ],
                      ),
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
                                  'assets/images/accept_icon.png',
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
                                  'assets/images/decline_icon.png',
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
