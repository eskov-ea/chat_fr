import 'dart:io';

import 'package:chat/services/database/db_provider.dart';
import 'package:flutter/material.dart';

enum PopupType { error, warning, success, general }


class PopupManager {
  static final Map<String, String> popupIcon = {
    'PopupType.success': 'popup-success-icon.png',
    'PopupType.warning': 'popup-warning-icon.png',
    'PopupType.error': 'popup-error-icon.png',
    'PopupType.general': 'popup-general-icon.png'
  };
  static final Map<String, Color> popupColors = {
    'PopupType.success': const Color(0xFF13B426),
    'PopupType.warning': const Color(0xFFD3B70A),
    'PopupType.error': const Color(0xFFDC1111),
    'PopupType.general': const Color(0xff919191)
  };

  static Future<void> showInfoPopup(BuildContext context, {
    required bool dismissible,
    required PopupType type,
    required String message,
    Widget? title,
    String? route
  }) {
    return showDialog(
        barrierDismissible: dismissible,
        barrierColor: const Color(0x73000000),
        context: context,
        builder: (context) =>
            Dialog(
              shadowColor: const Color(0x00000000),
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6)
                ),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border(top: BorderSide(
                          color: popupColors[type.toString()]!, width: 10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                            "assets/icons/${popupIcon[type.toString()]}"),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Text(message)
                            ),
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          if (route != null) {
                            Navigator.of(context).pushNamed(route);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFFFFF)
                          ),
                          child: const Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
    );
  }

  static Future<void> showDbErrorPopup(BuildContext context, {
    required bool dismissible,
  }) {
    return showDialog(
        barrierDismissible: dismissible,
        barrierColor: const Color(0x73000000),
        context: context,
        builder: (context) =>
            AlertDialog(
              shadowColor: Colors.black12,
              backgroundColor: const Color(0xFFEAEAEA),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text('Произошла ошибка'),
              content: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6)
                ),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEA),
                      border: Border(top: BorderSide(
                          color: popupColors["PopupType.error"]!, width: 10))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                            "assets/icons/${popupIcon["PopupType.error"]!}"),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Text('Произошла ошибка при работе с базой данных. Мы находимся в процессе разработки, такое возможно при '
                                    'обновлении на новую версию. В таком случае необходимо перейти на вкладку Профиль и нажать "Удалить данные", после чего запустить приложение заново. Спасибо за понимание!')
                            ),
                          )
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Понятно')
                ),
                OutlinedButton(
                  onPressed: () async {
                    PopupManager.showLoadingPopup(context);
                    final db = DBProvider.db;
                    await db.deleteDBFile();
                    exit(0);
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.redAccent)
                  ),
                  child: Text('Удалить сейчас')
                )
              ],
            )
    );
  }

  static Future<void> showLoadingPopup(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        barrierColor: const Color(0x80FFFFFF),
        context: context,
        builder: (context) =>
            WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                shadowColor: const Color(0x00000000),
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6)
                  ),
                  child: Container(
                    height: 150,
                    width: 150,
                    padding: const EdgeInsets.only(left: 5, right: 10),
                    decoration: const BoxDecoration(
                      color:  Color(0xFFEAEAEA),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B17A4),
                            strokeWidth: 6.0,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text('Загрузка',
                          style: TextStyle(fontSize: 16, color: Color(0xFF0B17A4)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
    );
  }

  static void closePopup(BuildContext context) {
    Navigator.of(context).pop();
  }
}



