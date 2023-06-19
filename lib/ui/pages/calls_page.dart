import 'dart:async';

import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_event.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/call_logs_bloc/call_logs_state.dart';
import '../../services/global.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/user/users_view_cubit_state.dart';
import '../widgets/app_bar.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({Key? key, helper}) : super(key: key);


  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {


  @override
  void initState() {
    DataProvider().getUserId().then( (val) {
      userId = val;
    });
    _errorSubscription = BlocProvider.of<CallLogsBloc>(context).stream.listen((state) {
      _onState(state);
    });
    _usersSubscription = BlocProvider.of<UsersViewCubit>(context).stream.listen((state) {
      setState(() {
        users = state.usersDictionary ;
      });
    });
    super.initState();
  }

  late final StreamSubscription _usersSubscription;
  String? userId;
  Map<String, UserContact> users = {};
  late final StreamSubscription _errorSubscription;
  bool isError = false;
  void _onState(state) {
    if (state is CallLogErrorState) {
      setState(() {
        isError = true;
      });
    }
  }

  String getDate(String callDate) {
    final now = DateTime.now();
    final callTime = DateTime.parse(callDate);
    final timeDiff = now.difference(callTime).inDays;
    switch(timeDiff) {
      case 0:
        if (callTime.hour < 10 && callTime.minute < 10) return "0${callTime.hour}:0${callTime.minute}";
        if (callTime.hour < 10) return "0${callTime.hour}:${callTime.minute}";
        if (callTime.minute < 10) return "${callTime.hour}:0${callTime.minute}";
        return "${callTime.hour}:${callTime.minute}";
      case 1:
        return "Вчера";
      default:
        return "${callTime.day}.${callTime.month}.${callTime.year}";
    }
  }

  Widget getCallInfo(Map<String, UserContact>  users, CallModel call, int index) {
    try {
      CallRenderData? data;
      final toCaller = call.toCaller.replaceAll(new RegExp(r'[^0-9]'), '').substring(1);
      final fromCaller = call.fromCaller.replaceAll(new RegExp(r'[^0-9]'), '').substring(1);
      if (toCaller == userId) {
        final user = users["$fromCaller"]!;
        data = CallRenderData(
            userId: int.parse(userId!),
            callName:
                call.callStatus == "ANSWERED" ? "Входящий" : "Пропущенный",
            callerName: "${user.firstname} ${user.lastname}",
            callerNumber: fromCaller,
            callDate: DateTime.parse(call.date),
            callDuration: call.duration);
      } else {
        final user = users["$toCaller"]!;
        data = CallRenderData(
            userId: int.parse(userId!),
            callName: "Исходящий",
            callerName: "${user.firstname} ${user.lastname}",
            callerNumber: toCaller,
            callDate: DateTime.parse(call.date),
            callDuration: call.duration);
      }
      return GestureDetector(
        onTap: () {
          callNumber(context, data!.callerNumber);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: index % 2 == 0 ? Colors.transparent : Colors.grey[200],
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.callerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      color: data.callName == "Пропущенный" ? Colors.red[500] : Colors.grey[700]
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        data.callName,
                        style: TextStyle(
                          color: Colors.grey[700]
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(getDate(call.date))),
            GestureDetector(
              onTap: () {
                print("Get call info");
                Navigator.of(context).pushNamed(
                    MainNavigationRouteNames.callInfoPage,
                    arguments: data);
              },
              child: Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
              ),
            )
          ]),
        ),
      );
    }
    catch (err) {
      return Container(
        child: Text(err.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: kIsWeb
        ? const Center(child: Text("Недоступно в веб-версии"),)
        : isError
          ? Center(child: Text("Произошла ошибка при загрузке истории звонков"),)
          : BlocBuilder<CallLogsBloc, CallLogsBlocState>(
              builder: (context, state) {
                final usersState = BlocProvider.of<UsersViewCubit>(context).state;
                if (state is CallsLoadedLogState && users.isNotEmpty) {
                  if (state.callLog.isEmpty) {
                    return Center(
                      child: Text("Нет истории звонков"),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Text("Журнал звонков",
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700
                            ),
                          )
                        ),
                        Divider(
                          color: Colors.grey[600],
                          thickness: 0.4,
                          height: 8,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.callLog.length,
                            itemBuilder: (context, index) {
                              return getCallInfo(users, state.callLog[index], index);
                          }),
                        ),
                      ],
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }
      ),
    );
  }
}


class CallRenderData {
  final int userId;
  final String callName;
  final String callerName;
  final String callerNumber;
  final DateTime callDate;
  final String callDuration;

  CallRenderData({
    required this.userId,
    required this.callName,
    required this.callerName,
    required this.callerNumber,
    required this.callDate,
    required this.callDuration
  });
}