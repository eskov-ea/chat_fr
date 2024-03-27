import 'package:chat/models/contact_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/ui/widgets/calls/call_audio_device_widget.dart';
import 'package:chat/ui/widgets/calls/call_mute_button_widget.dart';
import 'package:chat/ui/widgets/calls/call_switch_call_widget.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CallControlsWidget extends StatelessWidget {
  const CallControlsWidget({
    required this.setAvailableAudioDeviceOptions,
    required this.optionsMenuOpen,
    required this.onCallDecline,
    required this.onCallHangup,
    required this.onCallAccept,
    required this.toggleAudioOptionsPanel,
    required this.setCurrentDeviceId,
    required this.isSipServiceActive,
    required this.isCallRunning,
    required this.isCallingIncoming,
    required this.isCallPaused,
    required this.switchCallPanelToggleCallback,
    super.key
  });

  final bool optionsMenuOpen;
  final bool isSipServiceActive;
  final bool isCallingIncoming;
  final bool isCallRunning;
  final bool isCallPaused;
  final Function(Map<int, List<String>>) setAvailableAudioDeviceOptions;
  final Function(int) setCurrentDeviceId;
  final Function() onCallDecline;
  final Function() onCallHangup;
  final Function() onCallAccept;
  final Function() toggleAudioOptionsPanel;
  final Function() switchCallPanelToggleCallback;


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
                    addCallButton(context),
                    AudioOutputDeviceButton(
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
                if (isCallingIncoming)
                  Row(
                    mainAxisAlignment: isCallingIncoming ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                    children: [
                      acceptCallButton(),
                      SizedBox(height: 10),
                      declineCallButton()
                    ]
                  )
                else
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SwitchCallButton(switchCallPanelToggleCallback: switchCallPanelToggleCallback),
                        hangupCallButton(),
                        conferenceButton()
                      ]
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

  Widget acceptCallButton() {
    return Column(
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
    );
  }

  Widget conferenceButton() {
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
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/call_controls/conference.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text("Объединить",
          style: TextStyle(color: Colors.white, fontSize: 14)
        ),
      ],
    );
  }

  Widget addCallButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              // customToastMessage(context: context, message: 'Функционал находится в разработке');
              if (!isCallRunning) return;
              await _openAddPersonOnCallDialog(context);
            },
            child: Container(
              // margin: EdgeInsets.symmetric(horizontal: 20),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: const Color(0x809d9d9d),
                  // color: isCallRunning
                  //     ? const Color(0x80ffffff)
                  //     : const Color(0x809d9d9d),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: isCallPaused ? Image.asset(
                  'assets/call_controls/pause_white.png',
                  fit: BoxFit.fill,
                ) : Image.asset(
                  'assets/call_controls/add.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5,),
          SizedBox(
            width: 80,
            child: Text(isCallPaused ? "На удержании" : "Добавить",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14)
            ),
          ),
        ],
      ),
    );
  }

  Widget declineCallButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: onCallDecline,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isCallingIncoming ? 0 : 20),
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
        ),
        const SizedBox(height: 5,),
        const SizedBox(
          width: 80,
          child: Text("Отменить",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget hangupCallButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: onCallHangup,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isCallingIncoming ? 0 : 20),
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
        ),
        const SizedBox(height: 5,),
        const SizedBox(
          width: 80,
          child: Text("Завершить",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}


Future<void> _openAddPersonOnCallDialog(BuildContext context) {
  final users = (BlocProvider.of<UsersViewCubit>(context).state as UsersViewCubitLoadedState).users;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 30),
          title: const Text('Добавить к звонку'),
        content: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await _confirmAddingUserToCall(context, users[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text('${users[index].lastname} ${users[index].firstname}'),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    );
                  },
                  itemCount: users.length
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        )
      );
    },
  );
}

Future<void> _confirmAddingUserToCall(BuildContext context, UserModel user) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 60, vertical: MediaQuery.of(context).size.height * 0.35),
          alignment: Alignment.center,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 200,
            color: Colors.white,
            child: Center(child: Text('Добавить ${user.lastname} ${user.firstname} к звонку?')),
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey.shade400),
                ),
                child: Text('Назад')
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  startConference(user.id.toString());
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.purple.shade300),
                ),
                child: Text('Добавить')
            ),
          ],
        );
      });
}

