import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat/models/call_model.dart';
import 'package:chat/services/calls_manager/calls_manager.dart';
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
  final CallsManager callsManager;


  CallsBloc({required this.callsManager}) : super(ReleasedCallState()) {
    callsManager.subscribe(stream);
    callServiceEventChannelSubscription = callServiceEventChannel
        .receiveBroadcastStream()
        .listen((dynamic event)  {
      print("CALL_SERVICE_EVENT    ${event}") ;
      final callEvent = CallServiceEventModel.fromJson(event);
      if (callEvent.event == "CONNECTED") {
        print("Connected calldata:  ${callEvent.callData}");
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        print("Connected calldata:  $callData");
        add(ConnectedCallEvent(callData: callData));
      } else if (callEvent.event == "STREAM_RUNNING") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(StreamRunningCallEvent(callData: callData));
      } else if (callEvent.event == "ENDED") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(StreamStopCallEvent(callData: callData));
        if (callEvent.callData!["call_id"] == null && callEvent.callData!["uniqueid"] == null) {
          add(EndCallWithNoLogEvent());
          return;
        }
        print('Call ended with data:: $callData');
        add(EndedCallEvent(callData: callData));
      } else if (callEvent.event == "RELEASED") {
        print("CALL_RELEASED event:    ${callEvent.callData} ${callEvent.callData!["uniqueid"]} ${callEvent.callData!["call_id"]}");
        if (callEvent.callData!["call_id"] == null && callEvent.callData!["uniqueid"] == null) {
          add(EndCallWithNoLogEvent());
          return;
        }
          final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
          add(EndedCallEvent(callData: callData));
      } else if (callEvent.event == "INCOMING") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        print('INCOMING::: ${callEvent.callData} ${callEvent.callerId}');
        add(IncomingCallEvent(callerId: callEvent.callerId!, callData: callData));
      } else if (callEvent.event == "OUTGOING") {
        final callData = CallModel.fromJsonOnOutgoingCall(callEvent.callData);
        add(OutgoingCallEvent(callData: callData));
      } else if (callEvent.event == "ERROR") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(ErrorCallEvent(callData: callData));
      } else if (callEvent.event == "OUTGOING_RINGING") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(OutgoingRingingCallEvent(callData: callData));
      } else if (callEvent.event == "PAUSED") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(PausedCallEvent(callData: callData));
      } else if (callEvent.event == "RESUMED") {
        final callData = CallModel.fromJsonOnEndedCall(callEvent.callData);
        add(ResumedCallEvent(callData: callData));
      }
    });
      on<CallsEvent>((event, emit) async {
        if (event is IncomingCallEvent) {
          state.addCall(event.callData);
          emit(IncomingCallState(callerId: event.callerId));
        } else if (event is EndedCallEvent) {
          // timer.stop();
          state.removeCall(event.callData);
          emit(EndedCallState(callData: event.callData));
        } else if (event is OutgoingCallEvent) {
          state.addCall(event.callData, outgoing: true);
          emit(OutgoingCallState(callData: event.callData));
        } else if (event is ConnectedCallEvent) {
          state.update(event.callData);
          emit(ConnectedCallState(callData: event.callData));
        } else if (event is StreamRunningCallEvent) {
          state.startTimer(event.callData.id); //timer.start();
          emit(StreamRunningCallState(callData: event.callData));
        } else if (event is StreamStopCallEvent) {
          state.stopTimer(event.callData.id); //timer.stop();
          emit(StreamStopCallState());
        } else if (event is ErrorCallEvent) {
          state.stopTimer(event.callData.id); //timer.stop();
          state.removeCall(event.callData);
          emit(ErrorCallState(callData: event.callData));
        } else if (event is OutgoingRingingCallEvent) {

          emit(OutgoingRingingCallState(callData: event.callData));
        } else if (event is EndCallWithNoLogEvent) {
          emit(EndCallWithNoLogState());
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
  print('makeCallDataMap:: $string');
  if (string == null) return null;
  final json = jsonDecode(jsonEncode(string));
  return json;
}