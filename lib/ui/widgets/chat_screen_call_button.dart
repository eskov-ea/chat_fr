import 'dart:async';
import 'package:chat/services/global.dart';
import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/calls/sip_connection_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CallButton extends StatefulWidget {
  const CallButton({
    required this.partnerId,
    super.key
  });

  final int partnerId;

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  late final StreamSubscription<SipConnectionState> _sipConnectionState;
  SipConnectionState _connectionState = SipConnectionState(status: ConnectionStatus.none, message: null);

  @override
  void initState() {
    setState(() {
      _connectionState = SipRepository.instance.state;
    });
    _sipConnectionState = SipRepository.instance.stream.listen((event) {
      setState(() {
        _connectionState = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _sipConnectionState.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
          CupertinoIcons.phone,
          color: AppColors.secondary ,
          size: 30
      ),
      onPressed: () {
        if (_connectionState.status == ConnectionStatus.connected) {
          callNumber(context, widget.partnerId.toString());
        } else {
          sipConnectionServiceInfoWidget(context, _connectionState);
        }
      },
    );
  }

}
