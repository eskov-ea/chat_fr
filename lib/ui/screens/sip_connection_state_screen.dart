import 'dart:async';

import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SipConnectionStateScreen extends StatefulWidget {
  const SipConnectionStateScreen({super.key});

  @override
  State<SipConnectionStateScreen> createState() => _SipConnectionStateScreenState();
}

class _SipConnectionStateScreenState extends State<SipConnectionStateScreen> {

  late final StreamSubscription<SipConnectionState> _sipConnectionState;
  SipConnectionState _connectionState = SipConnectionState(status: ConnectionStatus.none, message: null);
  Color _color = Colors.grey;
  Color _fillColor = Colors.grey.shade100;
  String _message = 'Нет подключения';
  String? _connectErrorMessage;

  void _onSipConnectionStateChange(SipConnectionState state) {
    if ( state.status == ConnectionStatus.connected ) {
      _color = Colors.green.shade700;
      _fillColor = Colors.greenAccent.shade100;
      _message = 'Подключено';
    } else if (state.status == ConnectionStatus.progress ) {
      _color = Colors.blue.shade700;
      _fillColor = Colors.blueAccent.shade100;
      _message = 'Подключение';
    } else if (state.status == ConnectionStatus.failed ) {
      _color = Colors.red.shade700;
      _fillColor = Colors.redAccent.shade100;
      _message = 'Подключение завершилось ошибкой';
    } else if (state.status == ConnectionStatus.cleared) {
      _color = Colors.orange.shade700;
      _fillColor = Colors.orangeAccent.shade100;
      _message = 'Подключение было разъединено';
    } else {
      _color = Colors.grey;
      _fillColor = Colors.grey.shade100;
      _message = 'Нет подключения';
    }
    setState(() {
      _connectionState = state;
    });
  }

  @override
  void initState() {
    _onSipConnectionStateChange(SipRepository.instance.state);
    _sipConnectionState = SipRepository.instance.stream.listen(_onSipConnectionStateChange);
    super.initState();
  }

  @override
  void dispose() {
    _sipConnectionState.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: const Text('Статус SIP-сервиса'),

        ),
        body: Material(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 70, width: MediaQuery.of(context).size.width),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 120,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _fillColor,
                  border: Border.all(color: _color, width: 2.0),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  image: DecorationImage(
                    image: const AssetImage('assets/sip/connecting_background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.35),
                        BlendMode.lighten
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _color,
                      spreadRadius: 1.0,
                      blurRadius: 20.0,
                      blurStyle: BlurStyle.solid
                    )
                  ]
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.topRight,
                  child: Text(_connectionState.message ?? '',
                    style: const TextStyle(fontSize: 12),
                  )
              ),
              const Expanded(child: SizedBox()),
              const SizedBox(height: 100),
              Ink(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                decoration: BoxDecoration(
                  color: _buttonColor(),
                  borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                child: InkWell(
                  onTap: _onButtonTap,
                  splashColor: Colors.white54,
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: _buttonLabel()
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonLabel() {
    if (_connectionState.status == ConnectionStatus.connected) {
      return const Center(
          child: Text('Отключиться',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.050),
          )
      );
    } else if (_connectionState.status == ConnectionStatus.none || _connectionState.status == ConnectionStatus.cleared || _connectionState.status == ConnectionStatus.failed) {
      return const Center(
          child: Text('Подключиться',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.050),
          )
      );
    } else {
      return const Center(
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 8.0,
              strokeCap: StrokeCap.round,
            ),
          )
      );
    }
  }

  Color _buttonColor() {
    if (_connectionState.status == ConnectionStatus.connected) {
      return Colors.red.shade300;
    } else if (_connectionState.status == ConnectionStatus.none || _connectionState.status == ConnectionStatus.cleared || _connectionState.status == ConnectionStatus.failed) {
      return Colors.blue.shade300;
    } else {
      return Colors.grey.shade300;
    }
  }

  Future<void> _onButtonTap() async {
    if (_connectionState.status == ConnectionStatus.connected) {
      SipRepository.instance.disconnect();
    } else if (_connectionState.status == ConnectionStatus.none || _connectionState.status == ConnectionStatus.cleared || _connectionState.status == ConnectionStatus.failed) {
      setState(() {
        _connectErrorMessage = null;
      });
      final userId = await DataProvider.storage.getUserId();
      final profileState = BlocProvider.of<ProfileBloc>(context).state;
      if (profileState is! UserProfileLoadedState) {
        setState(() {
          _connectErrorMessage = 'Данные для подключения еще не получены с ЕРП. Попробуйте еще раз. Причина по которой данные могут быть не получены - проблема соединения или доступности сети, ошибка отправки/получения данных.';
        });
        return;
      }
      final settings = profileState.user!.userProfileSettings;
      final displayName = "${profileState.user!.lastname} ${profileState.user!.firstname}";
      if (settings == null || userId == null ) {
        setState(() {
          _connectErrorMessage = 'Данные для подключения либо не получены, либо их не удалось прочитать, попробуйте еще раз.';
        });
        return;
      }
      SipRepository.instance.connect(settings, userId, displayName);
    } else {
      return;
    }
  }
}
