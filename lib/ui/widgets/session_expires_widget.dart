import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/global.dart';


Future<void> SessionExpiredModalWidget(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Авторизация устарела'),
        content: const Text(
          'В целях безопасности необходимо\n'
          'пройти авторизацию снова.\n'
          '\n'
          'Нажмите кнопку "Ок" чтобы перейти на экран авторизации.',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ок'),
            onPressed: () {
              logoutHelper(context);
            },
          ),
        ],
      );
    },
  );
}
