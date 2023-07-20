import 'dart:async';
import 'dart:convert';
import 'package:chat/models/call_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'calls_event.dart';
import 'calls_state.dart';


class CallsBloc
    extends Bloc<CallsEvent, CallState> {
  late final StreamSubscription callServiceEventChannelSubscription;
  final callServiceEventChannel = const EventChannel("event.channel/call_service");
  final sipChannel = const MethodChannel("com.application.chat/sip");


  CallsBloc() : super(UnconnectedCallServiceState()) {
    callServiceEventChannelSubscription = callServiceEventChannel
        .receiveBroadcastStream()
        .listen((dynamic event)  {
      print("CALL_SERVICE_EVENT    ${event}") ;
      final callEvent = CallServiceEventModel.fromJson(event);
      if (callEvent.event == "REGISTRATION_SUCCESS") {
        add(ConnectingCallServiceEvent());
      } else if (callEvent.event == "REGISTRATION_FAILED") {
        add(ConnectionFailedCallEvent());
      }  else if (callEvent.event == "CONNECTED") {
        add(ConnectedCallEvent());
      } else if (callEvent.event == "ENDED") {
        print("CALL_ENDED event:    ${callEvent.callData} ${callEvent.callData!["uniqueid"]} ${callEvent.callData!["call_id"]}");
        if (callEvent.callData!["call_id"] == null && callEvent.callData!["uniqueid"] == null) {
          add(EndCallWithNoLogServiceEvent());
          return;
        }
          final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
          add(EndedCallServiceEvent(callData: callData));
        // if(callEvent.callData != null && callEvent.callData!["sip_from"] != null && callEvent.callData!["call_id"] != null) {
        //   final callData = CallModel.fromJson(callEvent.callData);
        //   add(EndedCallServiceEvent(callData: callData));
        // } else {
        //   final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        //   add(EndedCallServiceEvent(callData: callData));
        // }
      } else if (callEvent.event == "INCOMING") {
        add(IncomingCallEvent(callerId: callEvent.callerId!));
      } else if (callEvent.event == "OUTGOING") {
        add(OutgoingCallEvent(callerId: callEvent.callerId!));
      } else if (callEvent.event == "ERROR") {
        print("ERROR_CALL  -->  ${callEvent.callerId}");
        add(ErrorCallEvent(callerId: callEvent.callerId!));
      }
    });
      on<CallsEvent>((event, emit) async {
        if (event is ConnectingCallServiceEvent) {
          emit(ConnectedCallServiceState());
        } else if (event is ConnectionFailedCallEvent) {
          emit(UnconnectedCallServiceState());
        } else if (event is IncomingCallEvent) {
          emit(IncomingCallState(callerName: event.callerId));
        } else if (event is EndedCallServiceEvent) {
          emit(EndedCallServiceState(callData: event.callData));
          add(ConnectingCallServiceEvent());
        } else if (event is OutgoingCallEvent) {
          emit(OutgoingCallServiceState(callerName: event.callerId));
        } else if (event is ConnectedCallEvent) {
          emit(ConnectedCallState());
        } else if (event is ErrorCallEvent) {
          emit(ErrorCallServiceState(callerName: event.callerId));
        } else if (event is EndCallWithNoLogServiceEvent) {
          emit(EndCallWithNoLogServiceState());
        }
      });
    }



  @override
  Future<void> close() {
    callServiceEventChannelSubscription.cancel();
    return super.close();
  }
}


class CallServiceEventModel {
  final String event;
  final String? callerId;
  final Map<String, dynamic>? callData;

  const CallServiceEventModel({
    required this.event,
    required this.callerId,
    required this.callData
  });

  static CallServiceEventModel fromJson(data) {
    var json;
    if (data.runtimeType == String) {
      json = jsonDecode(data);
    } else {
      json = data;
    }
    return CallServiceEventModel(
        event: json["event"],
        callerId: json["callerId"],
        callData: makeCallDataMap(json["callData"])
    );
  }
}

makeCallDataMap(string) {
  if (string == null) return null;
  final json = jsonDecode(jsonEncode(string));
  return json;
}