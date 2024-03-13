import 'dart:async';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_event.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/messages/message_loading_state_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoadingMessagesStatusWidget extends StatefulWidget {
  final int? dialogId;
  const LoadingMessagesStatusWidget({super.key, required this.dialogId});

  @override
  State<LoadingMessagesStatusWidget> createState() => _LoadingMessagesStatusWidgetState();
}

class _LoadingMessagesStatusWidgetState extends State<LoadingMessagesStatusWidget> {

  late final StreamSubscription<MessageLoadingState> _loadingMessagesStateSubscription;
  bool loading = false;
  AppErrorException? error;

  @override
  void initState() {
    _loadingMessagesStateSubscription = MessageLoadingStateStreamer.instance.stream.listen((event) {
      print('st');
      if (event.dialogId == widget.dialogId) {
        setState(() {
          loading = event.status;
          error = event.error;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _loadingMessagesStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dialogId != null && loading) {
      return SizedBox(
          height: 6,
          width: MediaQuery.of(context).size.width,
          child: LinearProgressIndicator(
            backgroundColor: Colors.green.shade100,
            borderRadius: BorderRadius.circular(6),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade800),
            minHeight: 6.0,
          )
      );
    } else if (error != null) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.all(Radius.circular(12.0))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65 - 20,
                height: 40,
                child: Text(error != null ? mapErrorToMessage(error!) : "",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Ink(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(6.0))
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        error = null;
                      });
                      BlocProvider.of<MessageBloc>(context).add(MessageBlocLoadNextPortionMessagesEvent(dialogId: widget.dialogId!));
                    },
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                    ),
                    splashColor: Colors.red.shade300,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.black,
                      size: 30.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
