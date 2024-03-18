import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/helpers/message_sender_helper.dart';
import '../navigation/main_navigation.dart';

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
                          SizedBox(height: 20,),
                          Text("Просмотреть файл",
                            style: TextStyle(fontSize: 18),),
                          SizedBox(height: 20,),
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
                showModalBottomSheet(
                  isDismissible: false,
                  isScrollControlled: true,
                  backgroundColor: Colors.black54,
                  context: context,
                  builder: (BuildContext context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                final messageText = widget.controller.text;
                final String filetype = widget.file.path.split('.').last;
                widget.controller.clear();
                //TODO: refactor db
                sendMessageUnix(
                    uuid: null,
                    bloc: BlocProvider.of<MessageBloc>(context),
                    messageText: messageText,
                    file: widget.file,
                    dialogId: widget.dialogId!,
                    userId: widget.userId,
                    parentMessage: widget.parentMessage
                );
                Navigator.popUntil(context, (route) => route.settings.name == MainNavigationRouteNames.chatPage);
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
