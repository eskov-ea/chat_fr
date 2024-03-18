import 'dart:async';
import 'dart:io';
import 'package:chat/services/global.dart';
import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/screens/call_logs_screen.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/ui/widgets/calls/sip_connection_dialog.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class CallInfoPage extends StatefulWidget {
  
  final CallRenderData callData;
  
  const CallInfoPage({
    required this.callData,
    Key? key
  }) : super(key: key);

  @override
  State<CallInfoPage> createState() => _CallInfoPageState();
}

class _CallInfoPageState extends State<CallInfoPage> {
  late final StreamSubscription<SipConnectionState> _sipConnectionState;
  SipConnectionState _connectionState = SipConnectionState(status: ConnectionStatus.none, message: null);

  @override
  void initState() {
    setState(() {
      _connectionState = SipRepository.instance.state;
    });
    _sipConnectionState = SipRepository.instance.stream.listen((event) {
      setState(() {
        _connectionState = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _sipConnectionState.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leadingWidth: 100,
        leading: Align(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Row(
              children: [
                Icon( CupertinoIcons.back,),
                Text('Назад', style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80,),
              Text(widget.callData.callerName,
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
              const SizedBox(height: 20,),
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.8 + 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:  BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Text("${widget.callData.callDate.day} "
                        "${getMonthRussianName(widget.callData.callDate.month)} "
                        "${widget.callData.callDate.year} г."
                    ),
                    const SizedBox(height: 10,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getTime(widget.callData.callDate)),
                          const SizedBox(width: 10,),
                          Text(widget.callData.callName,
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                          )
                        ]
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      if (_connectionState.status == ConnectionStatus.connected) {
                        callNumber(widget.callData.callerNumber);
                      } else {
                        sipConnectionServiceInfoWidget(context, _connectionState);
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call,
                            color: _connectionState.status == ConnectionStatus.connected ? Colors.blueAccent : Colors.grey,
                          ),
                          const SizedBox(width: 10,),
                          Text("Позвонить",
                            style: TextStyle(color: _connectionState.status == ConnectionStatus.connected ? Colors.black : Colors.black54),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  GestureDetector(
                    onTap: () async {
                      final Directory documentDirectory = await getApplicationDocumentsDirectory();
                      final String dirPath = documentDirectory.path;
                      final dialogData= findDialog(context, widget.callData.userId, int.parse(widget.callData.callerNumber));
                      final ChatPageArguments chatArgs = ChatPageArguments(
                        userId: widget.callData.userId,
                        partnerId: int.parse(widget.callData.callerNumber),
                        dialogData: dialogData,
                        dirPath: dirPath,
                        username: widget.callData.callerName,
                        dialogCubit: BlocProvider.of<DialogsViewCubit>(context),
                        users: (BlocProvider.of<UsersViewCubit>(context).state as UsersViewCubitLoadedState).users,
                      );
                      Navigator.of(context).pushNamed(MainNavigationRouteNames.chatPage, arguments: chatArgs);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.messenger,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 10,),
                          Text("Написать")
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}

String getTime(DateTime callTime) {
  callTime = callTime.add(getTZ());
  if (callTime.hour < 10 && callTime.minute < 10) return "0${callTime.hour}:0${callTime.minute}";
  if (callTime.hour < 10) return "0${callTime.hour}:${callTime.minute}";
  if (callTime.minute < 10) return "${callTime.hour}:0${callTime.minute}";
  return "${callTime.hour}:${callTime.minute}";
}
