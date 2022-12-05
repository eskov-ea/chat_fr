import 'dart:convert';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:flutter/material.dart';
import '../../services/global.dart';
import '../../storage/sqflite_database.dart';

class ImagePreviewWidget extends StatefulWidget{
  final double? width;
  final int attachmentId;

  const ImagePreviewWidget({
    Key? key,
    required this.width,
    required this.attachmentId
  }) : super(key: key);

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {

  final MessagesRepository _messagesRepository = MessagesRepository();
  String? base64StringContent;

  @override
  void initState() {
    getImageData();
    super.initState();
  }
  void getImageData() async {
    print("getimage");
    final fileData = await _messagesRepository.loadAttachmentData(attachmentId: widget.attachmentId.toString());
    if (fileData == null) return; //TODO: implement this method with desired workflow
    setState(() {
      base64StringContent = fileData.content;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: base64StringContent != null
        ? Image.memory(
            base64Decode(base64StringContent!),
            width: widget.width,
          )
        : const Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}