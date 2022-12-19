import 'dart:convert';
import 'dart:io';

import 'package:chat/services/messages/messages_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/global.dart';

class FilePreviewerWidget extends StatefulWidget {
   const FilePreviewerWidget({
    required this.fileName,
    required this.fileExt,
    required this.attachmentId,
    Key? key
  }) : super(key: key);

  final String fileName;
  final String fileExt;
  final int attachmentId;

  @override
  State<FilePreviewerWidget> createState() => _FilePreviewerWidgetState();
}

class _FilePreviewerWidgetState extends State<FilePreviewerWidget> {
  final _messagesRepository = MessagesRepository();
  final filePermissionChannel = const MethodChannel("com.application.chat/write_files_method");
  final filePermissionServiceEventChannel = const EventChannel("event.channel/write_files_service");
  bool isPermissionGranted = false;
  bool isLoadingData = false;

  @override
  void initState() {
    checkPermissionsToSaveFile();
    super.initState();
  }

  Future<bool> checkPermissionsToSaveFile() async {
    try {
      return await filePermissionChannel.invokeMethod('CHECK_WRITE_FILES_PERMISSION', {});
    } catch (err) {
      print("ERROR CHECK_PERMISSIONS");
      print(err);
      return false;
    }
  }

  void fromBase64ToFileOnDevice() async {
    print("started saving file");

    loadingInProgressModalWidget(context, "Загрузка");

    final base64String = await _messagesRepository.loadAttachmentData(
        attachmentId: widget.attachmentId.toString());
    Navigator.of(context).pop();

    if (base64String == null) {
      customToastMessage(context, "Произошла ошибка при загрузке файла!");
      return;
    } //TODO: implement this method with desired workflow
    try {
      if (!kIsWeb) {
        await filePermissionChannel.invokeMethod('SAVE_FILE', {
          "type": "application/${widget.fileExt}",
          "filename": widget.fileName,
          "data": base64String.content
        });
      } else {
        final bytes = base64Decode(base64String.content!.replaceAll('\n', ''));
        webPlatformSaveFile(bytes: bytes, filename: widget.fileName);
      }
    } catch (err) {
      print("fromBase64ToFileOnDevice  error  $err");
      customToastMessage(
          context, "Произошла ошибка, не удалось сохранить файл!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon( Icons.arrow_circle_up),
                const SizedBox(width: 20,),
                Text(widget.fileName)
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Image.asset("assets/file_icon.png", width: 200,)
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 60,
              color: Colors.blue,
              child: GestureDetector(
                onTap: () async {
                    fromBase64ToFileOnDevice();
              },
                child: const Center(
                    child: Text(
                      "Скачать документ",
                      style: TextStyle(fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 60,
              color: Colors.black45,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Center(
                    child: Text(
                      "Назад",
                      style: TextStyle(fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                ),
              ),
            )
          ]
        )
    );
  }
}