import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';

class SendingImagePreview extends StatelessWidget {
  const SendingImagePreview({
    required this.username,
    required this.userId,
    required this.dialogId,
    required this.file,
    required this.controller,
    required this.createDialogFn,
    required this.parentMessageId,
    Key? key,
  }) : super(key: key);

  final String username;
  final int userId;
  final int? dialogId;
  final File file;
  final createDialogFn;
  final TextEditingController controller;
  final int? parentMessageId;

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
                final messageText = controller.text;
                final String filetype = file.path.split('.').last;
                controller.clear();
                if(dialogId == null) await createDialogFn();
                sendMessageWithPayload(
                  file: file,
                  //TODO: first check if dialog exists
                  dialogId: dialogId,
                  filetype: filetype,
                  messageText: messageText,
                  context: context,
                  parentMessageId: parentMessageId
                );
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
