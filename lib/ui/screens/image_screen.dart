import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import '../pages/image_screen_image_options_dialog.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    Key? key,
    required this.width,
    required this.attachmentId,
    required this.fileName
  }) : super(key: key);

    final double? width;
    final int attachmentId;
    final String fileName;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  Uint8List? fileBytesRepresentation;
  File? imageFile;
  bool imageIsSaved = true;

  @override
  void initState() {
    if (!kIsWeb) {
      getImageData();
    } else {
      getImageDataWeb();
     }
    super.initState();
  }

  void getImageDataWeb() async {
    final base64String = await MessagesRepository().loadAttachmentData(attachmentId: widget.attachmentId.toString());
    if (base64String != null) {
      setState(() {
        fileBytesRepresentation =
            base64Decode(base64String.content!.replaceAll('\n', ''));
      });
    }
  }

  void getImageData() async {
    final rawFile = await loadFileAndSaveLocally(attachmentId: widget.attachmentId, fileName: widget.fileName);
    if (rawFile != null) {
      setState(() {
        imageFile = rawFile;
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
      webPlatformSaveFile(bytes: fileBytesRepresentation, filename: widget.fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            backgroundColor: Colors.black,
            leadingWidth: 100,
            leading: Align(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: const [
                    Icon( CupertinoIcons.back,),
                    Text('Назад', style: TextStyle(fontSize: 20),),
                  ],
                ),
              ),
            ),
          ),
          body: (imageFile == null && !kIsWeb) || (fileBytesRepresentation == null && kIsWeb)
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : Container(
              color: Colors.black,
              padding: const EdgeInsets.all(0),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: kIsWeb
                      ? Image.memory(fileBytesRepresentation!)
                      : Image.file(imageFile!),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.reply, size: 30,),
                      onPressed: (){
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ImageOptionsDialogWidget(
                            context: context,
                            imageSaver: _safeImageToDevice,
                          ),
                        );
                      }
                    ),
                  ],
                )
              ],
          ),
            ),
        ),
    );
  }
}