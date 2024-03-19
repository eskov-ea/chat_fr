import 'dart:io';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/helpers/message_sender_helper.dart';
import '../navigation/main_navigation.dart';


class SendingImagePreview extends StatelessWidget {
  const SendingImagePreview({
    required this.username,
    required this.userId,
    required this.dialogId,
    required this.file,
    required this.controller,
    required this.createDialogFn,
    required this.parentMessage,
    Key? key,
  }) : super(key: key);

  final String username;
  final int userId;
  final int? dialogId;
  final File file;
  final createDialogFn;
  final TextEditingController controller;
  final RepliedMessage? parentMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon( Icons.arrow_circle_up),
              const SizedBox(width: 20,),
              Text(username)
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: kIsWeb ? Image.network(file.path) : Image.file(file),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: TextFormField(
                controller: controller,

                decoration: InputDecoration(
                  hintText: 'Добавить подпись',
                  alignLabelWithHint: true,
                  helperStyle: TextStyle(),
                  contentPadding: const EdgeInsets.only(left: 25.0, right: 4.0, bottom: 4.0),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
                primary: Color(0x40ffffff)
              ),
              child: const Icon(Icons.arrow_back),
            ),
            ElevatedButton(
              onPressed: () async {
                showModalBottomSheet(
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: Colors.black54,
                  context: context,
                  builder: (BuildContext context) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 30),
                      Text(
                        "Отправка",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )
                    ],
                ));
                if(dialogId == null) {
                  PopupManager.showInfoPopup(context, dismissible: false, type: PopupType.general, message: 'Создаем диалог');
                  try {
                    await createDialogFn();
                  } catch (_) {
                    PopupManager.closePopup(context);
                    PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: 'Не удалось создать диалог');
                  }
                }
                BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocSendMessageEvent(dialogId: dialogId!, messageText: controller.text,
                    file: file, parentMessage: parentMessage));
                controller.clear();
                Navigator.popUntil(context, (route) => route.settings.name == MainNavigationRouteNames.chatPage);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              child: const Icon(Icons.send_rounded),
            )
          ],
        ),
      ),
    );
  }
}
