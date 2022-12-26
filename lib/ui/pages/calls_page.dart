import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/call_logs_bloc/call_logs_state.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../services/global.dart';
import '../../view_models/user/users_view_cubit.dart';
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
    super.initState();
  }

  String? userId;

  String getDate(String callDate) {
    final now = DateTime.now();
    final callTime = DateTime.parse(callDate);
    final timeDiff = now.difference(callTime).inDays;
    switch(timeDiff) {
      case 0:
        return "${callTime.hour}:${callTime.minute}";
      case 1:
        return "Вчера";
      default:
        return "${callTime.day}.${callTime.month}.${callTime.year}";
    }
  }

  Widget getCallInfo(Map<String, UserContact>  users, CallModel call, int index) {
    CallRenderData? data;
    if (call.toCaller == userId) {
      final user = users["${call.fromCaller}"]!;
      data = CallRenderData(
        userId: int.parse(userId!),
        callName: call.callStatus == "ANSWERED" ? "Входящий" : "Пропущенный",
        callerName: "${user.firstname} ${user.lastname}",
        callerNumber: call.fromCaller,
        callDate: DateTime.parse(call.date),
        callDuration: call.duration
      );
    } else {
      final user = users["${call.toCaller}"]!;
      data = CallRenderData(
          userId: int.parse(userId!),
          callName: "Исходящий",
          callerName: "${user.firstname} ${user.lastname}",
          callerNumber: call.toCaller,
          callDate: DateTime.parse(call.date),
          callDuration: call.duration
      );
    }
    return GestureDetector(
      onTap: (){
        callNumber(context, data!.callerNumber);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: index % 2 == 0 ? Colors.transparent : Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.callerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.phone,
                        size: 20,
                      ),
                      SizedBox(width: 5,),
                      Text(data.callName,
                        style: TextStyle(
                          color: call.callStatus == "NO ANSWER" && call.toCaller == userId ? Colors.red[500] : Colors.grey[700],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(getDate(call.date))
            ),
            GestureDetector(
              onTap: (){
                print("Get call info");
                Navigator.of(context).pushNamed(MainNavigationRouteNames.callInfoPage, arguments: data);
              },
              child: Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
              ),
            )
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: kIsWeb
        ? const Center(child: Text("Недоступно в веб-версии"),)
        : BlocBuilder<CallLogsBloc, CallLogsBlocState>(
          builder: (context, state) {
            if (state is CallsLoadedLogState) {
              final users = BlocProvider.of<UsersViewCubit>(context).state.usersDictionary;
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