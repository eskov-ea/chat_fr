import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:flutter/material.dart';

Future<void> sipConnectionServiceInfoWidget(BuildContext context, SipConnectionState state) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Нет подключения к SIP'),
        content: Text(
          'Приложению не удалось подключиться к SIP-серверу.\n'
              'Статус подключения: ${_mapConnectionStateToMessage(state)}.\n'
              '\n'
              'Вы можете выполнить повторное подключение с экрана \'Звонки\'.',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ок'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

String _mapConnectionStateToMessage(SipConnectionState state) {
  if ( state.status == ConnectionStatus.connected ) {
    return 'подключено';
  } else if (state.status == ConnectionStatus.progress ) {
    return 'подключение..';
  } else if (state.status == ConnectionStatus.failed ) {
    return 'подключение завершилось ошибкой';
  } else if (state.status == ConnectionStatus.cleared ) {
    return 'подключение было разъединено';
  } else if (state.status == ConnectionStatus.none ) {
    return 'нет подключения';
  } else {
    return 'произошла оошибка приложения';
  }

}