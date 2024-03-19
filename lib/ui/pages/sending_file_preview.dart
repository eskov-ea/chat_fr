import 'dart:io';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendingFilePreview extends StatefulWidget {
  const SendingFilePreview({
    required this.username,
    required this.userId,
    required this.dialogId,
    required this.file,
    required this.controller,
    required this.parentMessage,
    Key? key
  }) : super(key: key);

  final String username;
  final int userId;
  final int? dialogId;
  final File file;
  final TextEditingController controller;
  final RepliedMessage? parentMessage;

  @override
  State<SendingFilePreview> createState() => _SendingFilePreviewState();
}

class _SendingFilePreviewState extends State<SendingFilePreview> {

  PDFDocument? pdfDocument;
  bool isPDF = false;
  bool isNoAppToOpenFile = false;

  initPDFDocument() async {
    PDFDocument doc = await PDFDocument.fromFile(widget.file);
    setState(() {
      pdfDocument = doc;
    });
  }

  fileIsPDF() {
    setState(() {
       isPDF = widget.file.path.split('.').last == "pdf" ? true : false;
    });
  }

  @override
  void initState() {
    fileIsPDF();
    if (isPDF) initPDFDocument();
    super.initState();
  }


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
              Text(widget.username)
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                // color: Colors.black54,
                padding: EdgeInsets.all(20),
                child: isPDF
                    ? pdfDocument == null
                        ? const CircularProgressIndicator()
                        : PDFViewer(document: pdfDocument!)
                    : GestureDetector(
                      onTap: (){},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/file_icon.png", height: 80,),
                          const SizedBox(height: 20,),
                          const Text("Просмотреть файл",
                            style: TextStyle(fontSize: 18),),
                          const SizedBox(height: 20,),
                          isNoAppToOpenFile
                            ? const Text(noAppToOpenFileMessage,
                                style: TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,)
                            : const SizedBox.shrink()
                          ],
                      ),
                    )
              ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: TextFormField(
                controller: widget.controller,

                decoration: InputDecoration(
                  hintText: 'Добавить подпись',
                  alignLabelWithHint: true,
                  helperStyle: TextStyle(),
                  contentPadding: const EdgeInsets.only(left: 25.0, right: 4.0, bottom: 4.0),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        height: 60,
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
              onPressed: () {
                PopupManager.showLoadingPopup(context);
                print('sending file:: ${widget.file.path}');
                BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocSendMessageEvent(dialogId: widget.dialogId!, messageText: widget.controller.text,
                    parentMessage: widget.parentMessage, file: widget.file));
                widget.controller.clear();
                // Navigator.popUntil(context, (route) => route.settings.name == MainNavigationRouteNames.chatPage);
                Navigator.pop(context);
                Navigator.pop(context);
                PopupManager.closePopup(context);
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
