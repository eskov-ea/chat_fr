import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../pages/image_screen_image_options_dialog.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key? key,
    required this.localFileAttachment,
    required this.fileBytesRepresentation,
    required this.fileName,
    required this.width,
    required this.saveImageFunction
  }) : super(key: key);

    final File? localFileAttachment;
    final Uint8List? fileBytesRepresentation;
    final String fileName;
    final double? width;
    final Function saveImageFunction;


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
          body: (localFileAttachment == null && !kIsWeb) || (fileBytesRepresentation == null && kIsWeb)
            ? const Center(
              child: Text('Ошибка'),
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
                      : Image.file(localFileAttachment!),
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
                            imageSaver: (){saveImageFunction();},
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

class ImageScreenArguments{
  final File? localFileAttachment;
  final Uint8List? fileBytesRepresentation;
  final String fileName;
  final double? width;
  final Function saveCallback;

  const ImageScreenArguments({
    required this.localFileAttachment,
    required this.fileBytesRepresentation,
    required this.fileName,
    required this.saveCallback,
    required this.width
  });
}