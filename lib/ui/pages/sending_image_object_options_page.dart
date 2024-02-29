import 'dart:convert';
import 'dart:developer';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/ui/pages/sending_file_preview.dart';
import 'package:chat/ui/pages/sending_image_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';



Widget SendingObjectOptionsPage({
  required context,
  required messageController,
  required username,
  required userId,
  required dialogId,
  required createDialogFn,
  required RepliedMessage? parentMessage
}) {

  final _messageController = messageController;
  final ImagePicker _picker = ImagePicker();

  void _pickImageAndSend() async {
    try {
      if (dialogId == null) await createDialogFn;
      final XFile? result =
          await _picker.pickImage(source: ImageSource.gallery);
      if (result != null && !kIsWeb) {
        final Directory documentDirectory =
            await getApplicationDocumentsDirectory();
        final String path = documentDirectory.path;
        final String tmpFileName = result.path.split('/').last;
        final File file = File("$path/$tmpFileName");
        file.writeAsBytesSync(await result.readAsBytes());
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SendingImagePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: file,
                createDialogFn: createDialogFn,
                parentMessage: parentMessage)));
      }
      if (result != null && kIsWeb) {
        //TODO: refactor this repeated code
        showModalBottomSheet(
            isDismissible: false,
            isScrollControlled: true,
            backgroundColor: Colors.black54,
            context: context,
            builder: (BuildContext context) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Отправка",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  ],
                ));
        final Uint8List bytes = await result.readAsBytes();
        IMG.Image img = IMG.decodeImage(bytes)!;
        print("original image size W x H  --> ${img.width} x ${img.height}");
        print("original image size  -->  ${img.length}");
        print("original bytes size  -->  ${bytes.lengthInBytes}");

        String base64 = base64Encode(bytes);
        await MessagesRepository()
            .messagesProvider
            .sendMessageWithFileBase64ForWeb(
                base64: base64,
                dialogId: dialogId,
                filetype: result.name.split('.').last,
                parentMessageId: parentMessage?.parentMessageId,
                bytes: bytes);
        BlocProvider.of<ChatsBuilderBloc>(context)
            .add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } on PlatformException {
      Navigator.pop(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.warning, message: "Произошла ошибка чтения данных с устройства. Это может быть связано с проблемой доступа приложения к данным устройства. Проверьте права приложения в настройках или повторите попытку");
    } catch (err) {
      Navigator.pop(context);
      ClientErrorHandler.informErrorHappened(context,
          "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
    }
  }

  void _takeImageAndSend() async {
    try {
      if (dialogId == null) await createDialogFn;
      final XFile? result = await _picker.pickImage(source: ImageSource.camera);
      if (result != null && !kIsWeb) {
        final Directory documentDirectory =
            await getApplicationDocumentsDirectory();
        final String path = documentDirectory.path;
        final String tmpFileName = result.path.split('/').last;
        final File file = File("$path/$tmpFileName");
        file.writeAsBytesSync(await result.readAsBytes());
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SendingImagePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: file,
                createDialogFn: createDialogFn,
                parentMessage: parentMessage)));
      }
    } on PlatformException {
      Navigator.pop(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.warning, message: "Произошла ошибка чтения данных с устройства. Это может быть связано с проблемой доступа приложения к данным устройства. Проверьте права приложения в настройках или повторите попытку");
    } catch (err) {
      Navigator.pop(context);
      ClientErrorHandler.informErrorHappened(context,
          "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
    }
  }

  void _pickFileAndSendWeb() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && kIsWeb) {
        showModalBottomSheet(
            isDismissible: false,
            isScrollControlled: true,
            backgroundColor: Colors.black54,
            context: context,
            builder: (BuildContext context) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Отправка",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                )
              ],
            ));
          final bytes = result.files.first.bytes;
          String base64 = base64Encode(bytes!);
          final response = await MessagesRepository()
            .messagesProvider
            .sendMessageWithFileBase64ForWeb(
            base64: base64,
            dialogId: dialogId,
            filetype: result.files.first.name.split('.').last,
            parentMessageId: parentMessage?.parentMessageId,
            bytes: null
          );
          MessageData.fromJson(jsonDecode(response)["data"]);
          BlocProvider.of<ChatsBuilderBloc>(context)
              .add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: dialogId!));
          Navigator.pop(context);
          Navigator.pop(context);
      }
    } on PlatformException {
      Navigator.pop(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.warning, message: "Произошла ошибка чтения данных с устройства. Это может быть связано с проблемой доступа приложения к данным устройства. Проверьте права приложения в настройках или повторите попытку");
    } catch (err) {
      Navigator.pop(context);
      ClientErrorHandler.informErrorHappened(context,
          "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
    }
  }

  void _pickFileAndSend() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.paths.first != null && !kIsWeb) {
        final docFile = File(result.paths.first!);
        final Directory documentDirectory =
            await getApplicationDocumentsDirectory();
        final String path = documentDirectory.path;
        final String tmpFileName = result.paths.first!.split('/').last;
        final File file = File("$path/$tmpFileName");
        file.writeAsBytesSync(await docFile.readAsBytes());
        //TODO: refactor this repeated code
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SendingFilePreview(
                controller: _messageController,
                username: username,
                userId: userId,
                dialogId: dialogId,
                file: File(result.files.single.path!),
                parentMessage: parentMessage)));
      }
    } on PlatformException {
      Navigator.pop(context);
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.warning, message: "Произошла ошибка чтения данных с устройства. Это может быть связано с проблемой доступа приложения к данным устройства. Проверьте права приложения в настройках или повторите попытку");
    } catch (err) {
      Navigator.pop(context);
      ClientErrorHandler.informErrorHappened(context,
          "Произошла ошибка при отправке сообщения. Попробуйте еще раз.");
    }
  }


  return Wrap(
    children: [
      Column(
        children: [
          OutlinedButton(
              onPressed: (){
                kIsWeb ? _pickFileAndSendWeb() : _pickFileAndSend();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Выбрать файл',
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
                'Выбрать фото',
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
                'Открыть камеру',
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
                'Отменить',
                style: TextStyle(color: Colors.red, fontSize: 20),
              )
          ),
        ],
      )
    ],
  );
}


