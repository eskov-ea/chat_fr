import 'dart:async';
import 'dart:io';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/services/helpers/dates.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/widgets/unauthenticated_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/call_logs_bloc/call_logs_event.dart';
import '../../bloc/call_logs_bloc/call_logs_state.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/user/users_view_cubit_state.dart';
import '../widgets/app_bar.dart';


enum CallStatus {answered, declined, noAnswer, errored}

class CallsPage extends StatefulWidget {
  const CallsPage({Key? key, helper}) : super(key: key);


  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {

  late final StreamSubscription _usersSubscription;
  int? userId;
  late UsersViewCubitState _usersState;
  final _controller = ScrollController();

  @override
  void initState() {
    DataProvider.storage.getUserId().then( (val) {
      userId = val;
    });
    setState(() {
      _usersState = BlocProvider.of<UsersViewCubit>(context).state;
    });
    _usersSubscription = BlocProvider.of<UsersViewCubit>(context).stream.listen((state) {
      setState(() {
        _usersState = state;
      });
    });
    super.initState();
  }

  Future<void> _onRefresh() async {
    final asterPass = BlocProvider.of<ProfileBloc>(context).state.user?.userProfileSettings?.asteriskUserPassword;
    if (asterPass == null) {
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.warning, message: "Произошла ошибка при получении данных пользователя");
    } else {
      BlocProvider.of<CallLogsBloc>(context).add(
          LoadCallLogsEvent(passwd: asterPass)
      );
    }
  }

  Widget _mapStateToWidget(BuildContext context, CallLogsBlocState state) {
    if (state is CallsLoadedLogState) {
      if (_usersState is UsersViewCubitLoadedState) {
        if (state.callLog.isEmpty) {
          return const Center(
            child: Text("Нет истории звонков"),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 16, horizontal: 16),
                  child: Text(
                    "Журнал звонков",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )
              ),
              Divider(
                color: Colors.grey[600],
                thickness: 0.4,
                height: 8,
              ),
              Expanded(
                child: Scrollbar(
                  controller: _controller,
                  thumbVisibility: false,
                  thickness: 5,
                  trackVisibility: false,
                  radius: const Radius.circular(7),
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: ListView.builder(
                    itemCount: state.callLog.length,
                    itemBuilder: (context, index) {
                      return getCallInfo(
                          _usersState is UsersViewCubitLoadedState ? (_usersState as UsersViewCubitLoadedState).usersDictionary : <int, UserModel>{},
                        state.callLog[index],
                        index
                      );
                    }),
                ),
              ),
            ],
          );
        }
      } else if (_usersState is UsersViewCubitErrorState) {
        return _errorWidget("Произошла техническая ошибка при загрузке журнала звонков. Попробуйте еще раз.");
      } else if (_usersState is UsersViewCubitLoadingState) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return _errorWidget("Произошла ошибка при загрузке журнала звонков. Попробуйте еще раз.");
      }
    } else if (state is CallLogInitialState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is CallLogErrorState) {
      return ClientErrorHandler.makeErrorInfoWidget(state.errorType!, _onRefresh);
    }  else if (state is CallsLogLogoutState) {
      return UnauthenticatedWidget();
    } else {
      return ClientErrorHandler.makeErrorInfoWidget(AppErrorExceptionType.other, _onRefresh);
    }
  }

  @override
  void dispose() {
    _usersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: kIsWeb
          ? const Center(child: Text("Недоступно в веб-версии"),)
          : BlocBuilder<CallLogsBloc, CallLogsBlocState>(
              builder: (context, state) {
                print("rendering:::  $state");
                return AnimatedSwitcher(
                    switchOutCurve: const Threshold(0),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    duration: Duration(milliseconds: Platform.isIOS ? 100 : 200),
                    child: _mapStateToWidget(context, state)
                );
              }
          )
    );
  }

  Widget _errorWidget(String errorMessage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight
              ),
              child: Center(
                child: Text(errorMessage,
                  textAlign: TextAlign.center,
                )
              )
            )
          )
        );
      }
    );
  }


  Widget getCallInfo(Map<int, UserModel>  users, CallModel call, int index) {
    // try {
      CallRenderData? data;
      final toCaller = int.parse(call.toCaller.replaceAll(RegExp(r'[^0-9]'), '').substring(1));
      final fromCaller = int.parse(call.fromCaller.replaceAll(RegExp(r'[^0-9]'), '').substring(1));
      if (toCaller == userId) {
        final user = users[toCaller]!;
        print('call status:  ${call.callStatus}');
        data = CallRenderData(
            userId: userId!,
            callName:
                call.callStatus == 0 ? "Входящий" : "Пропущенный",
            callerName: "${user.lastname} ${user.firstname}",
            callerNumber: fromCaller.toString(),
            callDate: DateTime.parse(call.date),
            callDuration: call.duration);
      } else {
        final user = users[toCaller]!;
        data = CallRenderData(
            userId: userId!,
            callName: "Исходящий",
            callerName: "${user.lastname} ${user.firstname}",
            callerNumber: toCaller.toString(),
            callDate: DateTime.parse(call.date),
            callDuration: call.duration);
      }
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.callInfoPage,
              arguments: data);
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
                  child: Text(dateFormater(data.callDate))),
          ]),
        ),
      );
    // }
    // catch (err) {
    //   return Container(
    //     child: Text(err.toString()),
    //   );
    // }
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