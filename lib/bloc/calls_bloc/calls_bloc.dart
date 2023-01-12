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
      if (callEvent.event == "REGISTRATION") {
        add(ConnectingCallServiceEvent());
      } else if (callEvent.event == "CONNECTED") {
        add(ConnectedCallEvent());
      } else if (callEvent.event == "ENDED") {
        final callData = CallModel.fromJson(callEvent.callData);
        print("CALL_ENDED  ${callEvent.callData!["calldate"]}");
        add(EndedCallServiceEvent(callData: callData));
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
        } else if (event is IncomingCallEvent) {
          emit(IncomingCallState(callerName: event.callerId));
        } else if (event is EndedCallServiceEvent) {
          emit(EndedCallServiceState(callData: event.callData));
          add(ConnectingCallServiceEvent());
        } else if (event is OutgoingCallEvent) {
          emit(OutgoingCallServiceState(callerName: event.callerId));
          await sipChannel.invokeMethod("OUTGOING_CALL", {"number": "sip:${event.callerId}@aster.mcfef.com"});
        } else if (event is ConnectedCallEvent) {
          emit(ConnectedCallState());
        } else if (event is ErrorCallEvent) {
          emit(ErrorCallServiceState(callerName: event.callerId));
        }
      });
    }



  @override
  Future<void> close() {
    print("CALL_SERVICE_EVENT           CLOSE EVENT");
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
  print("CALL_ENDED  JSON $json");
  return json;
}