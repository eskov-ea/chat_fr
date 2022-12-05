import 'dart:convert';

import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/ui/pages/sending_file_preview.dart';
import 'package:chat/ui/pages/sending_image_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

Widget SendingObjectOptionsPage({
  required context,
  required messageController,
  required username,
  required userId,
  required dialogId,
  required createDialogFn,
  required parentMessageId
}) {

  final _messageController = messageController;
  final ImagePicker _picker = ImagePicker();

  void _pickImageAndSend() async {
    if (dialogId == null) await createDialogFn;
    final XFile? result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null && !kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              SendingImagePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: File(result.path),
                createDialogFn: createDialogFn,
                parentMessageId: parentMessageId
              )
          )
      );
    }
    if (result != null && kIsWeb) {
      final bytes = await result.readAsBytes();
      String base64 = base64Encode(bytes);
      final response = await MessagesRepository().messagesProvider.sendMessageWithFileBase64ForWeb(base64: base64, dialogId: dialogId, filetype: result.name.split('.').last, parentMessageId: parentMessageId);
      print(response);
    }
  }

  void _takeImageAndSend() async {
    if (dialogId == null) await createDialogFn;
    final XFile? result = await _picker.pickImage(source: ImageSource.camera);
    if (result != null && !kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              SendingImagePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: File(result.path),
                createDialogFn: createDialogFn,
                parentMessageId: parentMessageId
              )
          )
      );
    }
  }

  void _pickFileAndSend() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && !kIsWeb) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              SendingFilePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: File(result.files.single.path!),
                parentMessageId: parentMessageId
              )
          )
      );
    }
    if (result != null && kIsWeb) {
      final bytes = result.files.first.bytes;
      String base64 = base64Encode(bytes!);
      final response = await MessagesRepository().messagesProvider.sendMessageWithFileBase64ForWeb(base64: base64, dialogId: dialogId, filetype: result.files.first.name.split('.').last, parentMessageId:parentMessageId);
      print(response);
    }
  }


  return Wrap(
    children: [
      Column(
        children: [
          OutlinedButton(
              onPressed: (){
                _pickFileAndSend();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Choose file',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              )
          ),
          OutlinedButton(
              onPressed: (){
                _pickImageAndSend();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Choose photo or video',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              )
          ),
          if (!kIsWeb) OutlinedButton(
              onPressed: (){
                _takeImageAndSend();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Open camera',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              )
          ),
          const SizedBox(height: 1,),

          const Divider(
            color: Colors.transparent,
            thickness: 0,
          ),
          OutlinedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 20),
              )
          ),
        ],
      )
    ],
  );
}


