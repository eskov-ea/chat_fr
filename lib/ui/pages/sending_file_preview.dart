import 'dart:convert';
import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../models/message_model.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import 'package:chat/models/message_model.dart' as parseTime;

class SendingFilePreview extends StatefulWidget {
  const SendingFilePreview({
    required this.username,
    required this.userId,
    required this.dialogId,
    required this.file,
    required this.controller,
    required this.parentMessageId,
    Key? key
  }) : super(key: key);

  final String username;
  final int userId;
  final int? dialogId;
  final File file;
  final TextEditingController controller;
  final int? parentMessageId;

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
                  hintText: 'Add a caption...',
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
                final messageText = widget.controller.text;
                final String filetype = widget.file.path.split('.').last;
                widget.controller.clear();
                sendMessageWithPayload(
                  file: widget.file,
                  //TODO: first check if dialog exists
                  dialogId: widget.dialogId!,
                  filetype: filetype,
                  messageText: messageText,
                  context: context,
                  parentMessageId: widget.parentMessageId
                );
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

  _sendMessage(context) async {
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.black54,
        context: context,
        builder: (BuildContext context) =>
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 30,),
                Text("Отправка", style: TextStyle(color: Colors.white, fontSize: 24),)
              ],
            )
    );
    try {
      final messageText = widget.controller.text;
      final String filetype = widget.file.path.split('.').last;
      widget.controller.clear();
      //TODO: implement local message beind added first
      // final localMessage = MessageData(
      //   messageId: 1111,
      //   senderId: widget.userId,
      //   dialogId: widget.dialogId!,
      //   message: messageText,
      //   messageDate: parseTime.getDate(DateTime.now()),
      //   messageTime: parseTime.getTime(DateTime.now()),
      //   rawDate: DateTime.now(),
      //   file: MessageAttachmentsData(
      //       preview: '',
      //       name: '11',
      //       attachmentId: 11,
      //       chatMessageId: 11,
      //       filetype: filetype,
      //       content: ''),
      //   status: [MessageStatuses(
      //       id: 0,
      //       userId: widget.userId,
      //       statusId: 0,
      //       messageId: 0,
      //       dialogId: widget.dialogId!,
      //       createdAt: DateTime.now().toString()
      //   )],
      // );
      // TODO: if response status code is 200 else ..
      print("messageText  --> $messageText");
      final sentMessage = await MessagesRepository().sendMessageWithFile(dialogId: widget.dialogId, messageText: messageText, file: widget.file, filetype: filetype, parentMessageId: widget.parentMessageId);
      final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderAddMessageEvent(message: message, dialog: widget.dialogId!)
      );
      // BlocProvider.of<ChatsBuilderBloc>(context).add(
      //     ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: widget.dialogId!, messageId: localMessage.messageId)
      // );
      // dialogCubit.updateLastDialogMessage(localMessage);
    } catch (err) {
      print(err);
    }
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogId!));
    // TODO: Can be refactored to named route
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
