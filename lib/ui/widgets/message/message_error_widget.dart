import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/helpers/message_sender_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageErrorWidget extends StatelessWidget {
  final int isError;
  final int messageId;
  final int dialogId;
  final int userId;
  final int? repliedMsgId;
  final String message;
  final MessageAttachmentData? file;
  final RepliedMessage? parentMessage;

  const MessageErrorWidget({
    required this.isError,
    required this.messageId,
    required this.dialogId,
    required this.userId,
    required this.repliedMsgId,
    required this.message, this.file,
    required this.parentMessage,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    void deleteErroredMessage() {
      //TODO: refacrot messageBloc
      // BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderDeleteLocalMessageEvent(dialogId: dialogId, messageId: messageId));
    }

    // Widget mIcon = isErrorHandling
    //     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(
    //     strokeWidth: 3.0, color: Colors.green)
    // )
    //     : const Icon(Icons.error, size: 30, color: Colors.red);

    if ( isError == 1 ) {
      return GestureDetector(
        onTap: (){
          showModalBottomSheet(
              isDismissible: true,
              isScrollControlled: false,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) => Container(
                padding: EdgeInsets.all(8),
                height: 200,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Произошла ошибка при отправке сообщения",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                          BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocResendMessageEvent(localMessageId: messageId, dialogId: dialogId));
                          // resendErrorMessage(
                          //     messageId: messageId, dialogId: dialogId, bloc: BlocProvider.of<MessageBloc>(context), userId: userId,
                          //     messageText: message, parentMessage: parentMessage, repliedMessageId: repliedMsgId,
                          //     file: file );
                        },
                        child: const SizedBox(
                          child: Text("Отправить снова",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                    ),
                    const SizedBox(height: 20,),
                    GestureDetector(
                        onTap: (){
                          deleteErroredMessage();
                          Navigator.of(context).pop();
                        },
                        child: const SizedBox(
                          child: Text("Удалить сообщение",
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        )
                    ),
                  ],
                ),
              )
          );
        },
        child: Container(
            alignment: Alignment.center,
            width: 40,
            padding: const EdgeInsets.only(left: 8),
            child: const Icon(Icons.error, size: 30, color: Colors.red)
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
