import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/global.dart';
import '../../view_models/dialogs_page/dialogs_view_cubit.dart';
import '../navigation/main_navigation.dart';
import '../screens/chat_screen.dart';
import 'calls_page.dart';

class CallInfoPage extends StatelessWidget {
  
  final CallRenderData callData;
  
  const CallInfoPage({
    required this.callData,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("CallInfoPage route  -->  ${ModalRoute.of(context)?.settings.name}");
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leadingWidth: 100,
        leading: Align(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(
              children: const [
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
            SizedBox(height: 80,),
            Text(callData.callerName,
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.8 + 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:  BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Text("${callData.callDate.day} "
                      "${getMonthRussianName(callData.callDate.month)} "
                      "${callData.callDate.year} г."
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTime(callData.callDate)),
                      SizedBox(width: 10,),
                      Text(callData.callName,
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                      )
                    ]
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      callNumber(context, callData.callerNumber);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 10,),
                          Text("Позвонить")
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  GestureDetector(
                    onTap: (){
                      final dialogData= findDialog(context, callData.userId, int.parse(callData.callerNumber));
                      final ChatPageArguments chatArgs = ChatPageArguments(
                        userId: callData.userId,
                        partnerId: int.parse(callData.callerNumber),
                        dialogData: dialogData,
                        username: callData.callerName,
                        dialogCubit: BlocProvider.of<DialogsViewCubit>(context),
                        usersCubit: BlocProvider.of<UsersViewCubit>(context),
                      );
                      Navigator.of(context).pushNamed(MainNavigationRouteNames.chatPage, arguments: chatArgs);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:  BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
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
              ),
            )
          ],
        ),
      ),
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
