import 'dart:async';
import 'dart:convert';
import 'package:chat/models/call_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/helpers/call_timer.dart';
import 'calls_event.dart';
import 'calls_state.dart';


class CallsBloc
    extends Bloc<CallsEvent, CallState> {
  late final StreamSubscription callServiceEventChannelSubscription;
  final callServiceEventChannel = const EventChannel("event.channel/call_service");
  final sipChannel = const MethodChannel("com.application.chat/sip");
  final timer = CallTimer.getInstance();


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
      } else if (callEvent.event == "CONNECTED") {
        add(ConnectedCallEvent());
      } else if (callEvent.event == "STREAM_RUNNING") {
        add(StreamRunningCallEvent());
      } else if (callEvent.event == "ENDED") {
        add(StreamStopCallEvent());
      } else if (callEvent.event == "RELEASED") {
        print("CALL_RELEASED event:    ${callEvent.callData} ${callEvent.callData!["uniqueid"]} ${callEvent.callData!["call_id"]}");
        if (callEvent.callData!["call_id"] == null && callEvent.callData!["uniqueid"] == null) {
          add(EndCallWithNoLogEvent());
          return;
        }
          final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
          add(EndedCallEvent(callData: callData));
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
          // timer.init();
          emit(ConnectedCallServiceState());
        } else if (event is ConnectionFailedCallEvent) {
          emit(UnconnectedCallServiceState());
        } else if (event is IncomingCallEvent) {
          emit(IncomingCallState(callerName: event.callerId));
        } else if (event is EndedCallEvent) {
          // timer.stop();
          emit(EndedCallState(callData: event.callData));
          add(ConnectingCallServiceEvent());
        } else if (event is OutgoingCallEvent) {
          emit(OutgoingCallState(callerName: event.callerId));
        } else if (event is ConnectedCallEvent) {
          emit(ConnectedCallState());
        } else if (event is StreamRunningCallEvent) {
          timer.start();
          emit(StreamRunningCallState());
        } else if (event is StreamStopCallEvent) {
          timer.stop();
          emit(StreamStopCallState());
        } else if (event is ErrorCallEvent) {
          timer.stop();
          emit(ErrorCallState(callerName: event.callerId));
        } else if (event is EndCallWithNoLogEvent) {
          emit(EndCallWithNoLogState());
        }
      });
    }



  @override
  Future<void> close() {
    callServiceEventChannelSubscription.cancel();
    timer.dispose();
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