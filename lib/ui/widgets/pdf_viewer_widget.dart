import 'dart:convert';
import 'dart:io';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class PdfViewerWidget extends StatefulWidget {
  const PdfViewerWidget({
    required this.attachmentId,
    required this.fileName,
    required this.fileExt,
    Key? key
  }) : super(key: key);

  final int attachmentId;
  final String fileName;
  final String fileExt;

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {

  PDFDocument? pdfDocument;
  final MessagesRepository _messagesRepository = MessagesRepository();


  void fromBase64ToPdf() async {
    final base64String = await _messagesRepository.loadAttachmentData(attachmentId: widget.attachmentId.toString());
    if (base64String == null) return; //TODO: implement this method with desired workflow
    final bytes = base64Decode(base64String.content!.replaceAll('\n', ''));
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    final File file = File('$path/${widget.fileName}');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    PDFDocument doc = await PDFDocument.fromFile(file);
    setState(() {
      pdfDocument = doc;
    });
  }

  @override
  void initState() {
    fromBase64ToPdf();
    super.initState();
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
      body: Container(
        alignment: Alignment.center,
        child: pdfDocument == null
            ? const CircularProgressIndicator()
            : PDFViewer(document: pdfDocument!),
      )
    );
  }
}

class AttachmentViewPageArguments{
  final String fileName;
  final String fileExt;
  final int attachmentId;
  final String messageTime;
  final bool isMe;

  const AttachmentViewPageArguments({
    required this.fileName,
    required this.fileExt,
    required this.messageTime,
    required this.isMe,
    required this.attachmentId
  });
}
