import 'dart:async';
import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/global.dart';
import 'package:flutter/services.dart';
import 'sip_repository_interface.dart';


enum ConnectionStatus { none, progress, connected, cleared, failed }


class SipRepository extends ISipRepository {

  SipRepository._private();

  static final SipRepository _instance = SipRepository._private();
  static SipRepository get instance => _instance;

  final sipChannel = const MethodChannel("com.application.chat/sip");
  final sipConnectionStateEventChannel = const EventChannel("event.channel/sip_connection_state");
  StreamSubscription? _sipEventSubscription;
  SipConnectionState _currentState = SipConnectionState(status: ConnectionStatus.none, message: null);


  SipConnectionState get state => _currentState;
  connect(UserProfileAsteriskSettings settings, int userId, String? displayName) async {
    print('Connect to:::');
    _currentState = SipConnectionState(status: ConnectionStatus.progress, message: null);
    sink(_currentState);
    _sipEventSubscription = sipConnectionStateEventChannel
        .receiveBroadcastStream()
        .listen((dynamic event)  {
      print('sip connection subscription event:  $state');
      final connectionEvent = SipConnectionEvent.fromJson(event);
      if (connectionEvent.event == "REGISTRATION_SUCCESS") {
        if (_currentState.status == ConnectionStatus.connected) return;
        _currentState = SipConnectionState(status: ConnectionStatus.connected, message: connectionEvent.message);
        sink(_currentState);
      } else if (connectionEvent.event == "REGISTRATION_FAILED") {
        if (_currentState.status == ConnectionStatus.failed) return;
        _currentState = SipConnectionState(status: ConnectionStatus.failed, message: connectionEvent.message);
        sink(_currentState);
      } else if (connectionEvent.event == "REGISTRATION_PROGRESS") {
        if (_currentState.status == ConnectionStatus.progress) return;
        _currentState = SipConnectionState(status: ConnectionStatus.progress, message: connectionEvent.message);
        sink(_currentState);
      } else if (connectionEvent.event == "REGISTRATION_CLEARED") {
        if (_currentState.status == ConnectionStatus.cleared) return;
        _currentState = SipConnectionState(status: ConnectionStatus.cleared, message: connectionEvent.message);
        sink(_currentState);
      } else if (connectionEvent.event == "REGISTRATION_NONE") {
        if (_currentState.status == ConnectionStatus.none) return;
        _currentState = SipConnectionState(status: ConnectionStatus.none, message: connectionEvent.message);
        sink(_currentState);
      }
    });
    _resume();
    SipConfig.sipDomain = settings.userDomain;
    SipConfig.sipPrefix = settings.sipPrefix;

    print("Trying to register to SIP with    ${SipConfig.getPrefix()}$userId@${settings.asteriskHost} and password ${settings.asteriskUserPassword} and domain  ${settings.userDomain}");
    await sipChannel.invokeMethod('SIP_LOGIN', {
      "username": "${SipConfig.getPrefix()}$userId",
      "display_name": displayName,
      "password": settings.asteriskUserPassword,
      "domain": settings.userDomain,
      "stun_domain": settings.stunHost,
      "stun_port": settings.stunPort,
      "host": settings.asteriskHost,
      "cert": settings.asteriskCert
    });
  }

  _resume() {
    // if (_sipEventSubscription.isPaused) {
    //   _sipEventSubscription.resume();
    // }
  }

  disconnect() async {
    if (_currentState.status == ConnectionStatus.connected || _currentState.status == ConnectionStatus.progress) {
      await sipChannel.invokeMethod('DESTROY_SIP', null);
    }
    _sipEventSubscription?.cancel();
    _sipEventSubscription = null;
  }

}

class SipConnectionState {
  final ConnectionStatus status;
  final String? message;

  SipConnectionState({required this.status, required this.message});

}

class SipConnectionEvent {
  final String event;
  final String? message;

  SipConnectionEvent({required this.event, required this.message});

  static SipConnectionEvent fromJson(json) =>
    SipConnectionEvent(
      event: json["event"],
      message: json["message"]
    );

}