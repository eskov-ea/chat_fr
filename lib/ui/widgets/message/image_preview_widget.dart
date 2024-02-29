import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/screens/image_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';


class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget(
      {required this.p2p,
      required this.isMe,
      required this.senderName,
      required this.borderRadius,
      required this.file,
      required this.localFileAttachment,
      required this.messageTime,
      required this.status,
      Key? key})
      : super(key: key);

  final int p2p;
  final bool isMe;
  final String? senderName;
  final String messageTime;
  final double borderRadius;
  final MessageAttachmentData? file;
  final File? localFileAttachment;
  final Widget status;

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  bool isDownloading = false;
  File? imageFile;
  Uint8List? fileBytesRepresentation;

  @override
  void initState() {
    checkIfAttachmentLoaded();

    super.initState();
  }

  _startDownloadingImage() async {
    if (!kIsWeb) {
      getImageData();
    } else {
      getImageDataWeb();
    }
  }

  getImageData() async {
    setState(() {
      isDownloading = true;
    });
    try {
      final rawFile = await loadFileAndSaveLocally(
          attachmentId: widget.file?.attachmentId,
          fileName: widget.file!.name);
      if (rawFile != null) {
        setState(() {
          imageFile = rawFile;
          isDownloading = false;
        });
      } else {
        setState(() {
          isDownloading = false;
        });
      }
    } catch (err) {
      setState(() {
        isDownloading = false;
      });
      customToastMessage(context: context, message: "Произошла ошибка при загрузке данных");
    }
  }

  checkIfAttachmentLoaded() async {
    if (kIsWeb) return null;
    if (widget.file != null) {
      imageFile = await isLocalFileExist(fileName: widget.file!.name);
    }
  }

  void getImageDataWeb() async {
    setState(() {
      isDownloading = true;
    });
    final base64String = await MessagesRepository()
        .loadAttachmentData(attachmentId: widget.file!.attachmentId.toString());
    if (base64String != null) {
      setState(() {
        fileBytesRepresentation =
            base64Decode(base64String.content!.replaceAll('\n', ''));
        isDownloading = false;
      });
    }
  }

  void _safeImageToDevice() async {
    if (!kIsWeb) {
      GallerySaver.saveImage(imageFile!.path, albumName: null).then((success) {
        if (success == true) {
          customToastMessage(context: context, message: "Сохранено!");
        }
      });
      return;
    } else {
      webPlatformSaveFile(
          bytes: fileBytesRepresentation, filename: widget.file!.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (widget.p2p != 1 && !widget.isMe) ? 270 : 240,
      width: 186,
      decoration: BoxDecoration(
          color: widget.isMe
              ? AppColors.myMessageBackground
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius),
            topRight: Radius.circular(widget.borderRadius),
            bottomRight: widget.isMe
                ? const Radius.circular(0.0)
                : Radius.circular(widget.borderRadius),
            bottomLeft: !widget.isMe
                ? const Radius.circular(0.0)
                : Radius.circular(widget.borderRadius),
          )),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.isMe
              ? AppColors.myMessageBackground
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius),
            topRight: Radius.circular(widget.borderRadius),
            bottomRight: widget.isMe
                ? const Radius.circular(0.0)
                : Radius.circular(widget.borderRadius),
            bottomLeft: !widget.isMe
                ? const Radius.circular(0.0)
                : Radius.circular(widget.borderRadius),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: getImagePreview(
              file: widget.file,
              localFileAttachment: imageFile,
              isDownloading: isDownloading,
              downloadImageFunction: _startDownloadingImage,
              context: context,
              fileBytesRepresentation: fileBytesRepresentation,
              saveImageFunction: _safeImageToDevice,
              messageTime: widget.messageTime,
              status: widget.status,
              isMe: widget.isMe),
        ),
      ),
    );
  }
}

Widget? getImagePreview({
    required MessageAttachmentData? file,
    required File? localFileAttachment,
    required bool isDownloading,
    required Function downloadImageFunction,
    required BuildContext context,
    required Uint8List? fileBytesRepresentation,
    required Function saveImageFunction,
    required String messageTime,
    required Widget status,
    required bool isMe
  }) {
  if (localFileAttachment != null || fileBytesRepresentation != null) {
    return GestureDetector(
        onTap: () {
          if (localFileAttachment == null && !kIsWeb || fileBytesRepresentation == null && kIsWeb) {
            PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: 'Произошла ошибка при обработке изображения. Попробуйте еще раз или перезагрузите приложение.');
          } else {
            Navigator.of(context).pushNamed(MainNavigationRouteNames.imageScreen,
                arguments: ImageScreenArguments(
                    fileName: file!.name,
                    localFileAttachment: localFileAttachment,
                    fileBytesRepresentation: fileBytesRepresentation,
                    width: null,
                    saveCallback: saveImageFunction)
            );
          }
        },
        child: Stack(
          children: [
            kIsWeb
                ? Image.memory(
                    fileBytesRepresentation!,
                    width: 186,
                    height: 202,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                      localFileAttachment!,
                      width: 186,
                      height: 232,
                      fit: BoxFit.cover
                  ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 250,
                height: 30,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.bottomRight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    stops: [0.4, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.grey,
                    ],
                  )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      messageTime,
                      style: TextStyle(color: AppColors.backgroundLight),
                    ),
                    isMe ? status : SizedBox.shrink()
                  ],
                )
              ),
            ),
          ],
        )
    );
  }
  if (file != null) {
    try {
      return Stack(
        alignment: Alignment.center,
        children: [
          file.preview != ""
              ? Image.memory(base64Decode(file.preview!),
                  height: 232, width: 186, fit: BoxFit.cover)
              : Image.asset("assets/blured_img_icon.jpg",
                  height: 232, width: 186, fit: BoxFit.cover),
          isDownloading
              ? Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.4),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const CircularProgressIndicator(),
                )
              : Material(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderOnForeground: false,
                  color: const Color.fromRGBO(255, 255, 255, 0.4),
                  child: InkWell(
                      onTap: () {
                        downloadImageFunction();
                      },
                      splashColor: const Color.fromRGBO(200, 200, 200, 0.7),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.download_rounded,
                          size: 55,
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      )),
                ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
                width: 250,
                height: 30,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.bottomRight,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  stops: [0.4, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.grey,
                  ],
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      messageTime,
                      style: const TextStyle(color: AppColors.backgroundLight),
                    ),
                    isMe ? status : const SizedBox.shrink()
                  ],
                )),
          ),
        ],
      );
    } catch (err) {
      return Stack(
        alignment: Alignment.center,
        children: [
          FittedBox(
            child: Image.asset("assets/blured_img_icon.jpg"),
            fit: BoxFit.cover
          ),
          // Image.asset("assets/blured_img_icon.jpg",
          //     height: 232, width: 186, fit: BoxFit.cover),
          isDownloading
              ? Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.4),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const CircularProgressIndicator(),
                )
              : Material(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderOnForeground: false,
                  color: const Color.fromRGBO(255, 255, 255, 0.4),
                  child: InkWell(
                      onTap: () {
                        downloadImageFunction();
                      },
                      splashColor: const Color.fromRGBO(200, 200, 200, 0.7),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.download_rounded,
                          size: 55,
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      )),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                      width: 250,
                      height: 30,
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            stops: [0.4, 1],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.grey,
                            ],
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            messageTime,
                            style: TextStyle(color: AppColors.backgroundLight),
                          ),
                          isMe ? status : SizedBox.shrink()
                        ],
                      )),
                ),
        ],
      );
    }
  }
}
