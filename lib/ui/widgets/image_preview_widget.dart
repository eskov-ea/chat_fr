import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import '../../theme.dart';
import '../navigation/main_navigation.dart';
import '../screens/image_screen.dart';

class ImagePreviewWidget extends StatefulWidget {
  const ImagePreviewWidget({
    required this.p2p,
    required this.isMe,
    required this.senderName,
    required this.borderRadius,
    required this.file,
    required this.localFileAttachment,
    required this.authorNameWidgetGroupChat,
    Key? key
  }) : super(key: key);

  final int p2p;
  final bool isMe;
  final String? senderName;
  final double borderRadius;
  final MessageAttachmentsData? file;
  final File? localFileAttachment;
  final Function authorNameWidgetGroupChat;

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
    final rawFile = await loadFileAndSaveLocally(attachmentId: widget.file?.attachmentId, fileName: widget.file!.name);
    if (rawFile != null) {
      setState(() {
        imageFile = rawFile;
      });
    }
    setState(() {
      isDownloading = false;
    });
  }
  checkIfAttachmentLoaded() async {
    if (kIsWeb) return null;
    if (widget.file != null){
      imageFile = await isLocalFileExist(fileName: widget.file!.name);
    }
  }

  void getImageDataWeb() async {
    setState(() {
      isDownloading = true;
    });
    final base64String = await MessagesRepository().loadAttachmentData(attachmentId: widget.file!.attachmentId.toString());
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
          customToastMessage(context, "Сохранено!");
        }
      });
      return;
    } else {
      webPlatformSaveFile(bytes: fileBytesRepresentation, filename: widget.file!.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.p2p != 1 && !widget.isMe) widget.authorNameWidgetGroupChat(widget.senderName, widget.borderRadius),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.isMe ? AppColors.myMessageBackground : Theme.of(context).cardColor,
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(widget.borderRadius),
              bottomRight: widget.isMe ? const Radius.circular(0.0) : Radius.circular(widget.borderRadius),
              bottomLeft: !widget.isMe ? const Radius.circular(0.0) : Radius.circular(widget.borderRadius),
            ),
          ),
          child: getImagePreview(
            file: widget.file,
            localFileAttachment: imageFile,
            isDownloading: isDownloading,
            downloadImageFunction: _startDownloadingImage,
            context: context,
            fileBytesRepresentation: fileBytesRepresentation,
            saveImageFunction: _safeImageToDevice
          ),
        )
      ],
    );
  }
}

Widget? getImagePreview({
  required MessageAttachmentsData? file,
  required File? localFileAttachment,
  required bool isDownloading,
  required Function downloadImageFunction,
  required BuildContext context,
  required Uint8List? fileBytesRepresentation,
  required Function saveImageFunction
}) {
  if ( localFileAttachment != null || fileBytesRepresentation != null ) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pushNamed(
              MainNavigationRouteNames.imageScreen,
              arguments: ImageScreenArguments(
                fileName: file!.name,
                localFileAttachment: localFileAttachment,
                fileBytesRepresentation: fileBytesRepresentation,
                width: null,
                saveCallback: saveImageFunction
              )
          );
        },
        child: kIsWeb
          ? Image.memory(fileBytesRepresentation!, width: 186,)
          : Image.file(localFileAttachment!, width: 186,)
    );
  }
  if ( file != null) {
    try {
      return Stack(
        alignment: Alignment.center,
        children: [
          file.preview != ""
              ? Image.memory(base64Decode(file.preview!), width: 186, fit: BoxFit.fill)
              : Image.asset("assets/blured_img_icon.jpg", width: 186, fit: BoxFit.fill),
          isDownloading
              ? Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.4),
                    borderRadius:  BorderRadius.all(Radius.circular(50)),
                  ),
                  child: CircularProgressIndicator(),
                )
              : Material(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderOnForeground: false,
                  color: const Color.fromRGBO(255, 255, 255, 0.4),
                  child: InkWell(
                      onTap: (){ downloadImageFunction();},
                      splashColor: const Color.fromRGBO(200, 200, 200, 0.7),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.download_rounded,
                          size: 55,
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      )
                  ),
                ),
        ],
      );
    } catch (err){
      print("ERROR parsing base64 to image data  $err  , attachment id ${file.attachmentId}");
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/blured_img_icon.jpg", width: 186, fit: BoxFit.fill),
          isDownloading
              ? Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.4),
              borderRadius:  BorderRadius.all(Radius.circular(50)),
            ),
            child: CircularProgressIndicator(),
          )
              : Material(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            borderOnForeground: false,
            color: const Color.fromRGBO(255, 255, 255, 0.4),
            child: InkWell(
                onTap: (){ downloadImageFunction();},
                splashColor: const Color.fromRGBO(200, 200, 200, 0.7),
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.download_rounded,
                    size: 55,
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                )
            ),
          ),
        ],
      );
    }
  }
}

