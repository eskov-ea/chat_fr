import 'dart:async';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/message_model.dart';
import '../../services/dialogs/dialogs_repository.dart';
import '../../services/logger/logger_service.dart';
import '../ws_bloc/ws_bloc.dart';
import '../ws_bloc/ws_state.dart';


class DialogsBloc extends Bloc<DialogsEvent, DialogsState> {
  final IDialogRepository dialogRepository;
  late final StreamSubscription newMessageSubscription;
  //TODO: remove WSBloc from this Bloc up to DialogsViewCubit
  final WsBloc webSocketBloc;
  //TODO: remove WSBloc from this Bloc up to DialogsViewCubit
  final Logger _logger = Logger.getInstance();
  final ErrorHandlerBloc errorHandlerBloc;

  DialogsBloc({
    required DialogsState initialState,
    required this.webSocketBloc,
    required this.errorHandlerBloc,
    required this.dialogRepository}) : super(initialState) {
        newMessageSubscription = webSocketBloc.stream.listen((streamState) {
          print("DialogsEvent   ${streamState}");
          if (streamState is WsStateReceiveNewMessage){
            final copyState = state.from();
            final List<DialogData> newDialogs = [ ...copyState.dialogs!];
            for (var dialog in newDialogs) {
              if(dialog.dialogId == streamState.message.dialogId) {
                if (dialog.lastMessage != null) {
                  dialog.lastMessage.message = streamState.message.message;
                  dialog.lastMessage.messageId = streamState.message.messageId;
                  dialog.lastMessage.senderId = streamState.message.senderId;
                  dialog.lastMessage.time = streamState.message.rawDate;
                  dialog.lastMessage.statuses = streamState.message.status;

                  newDialogs.remove(dialog);
                  newDialogs.insert(0, dialog);

                } else {
                  final jsonMessage = makeJsonMessage(streamState.message);
                  dialog.lastMessage = LastMessageData.fromJson(jsonMessage);
                }
              }
            }
            final newState = state.copyWith(dialogs: newDialogs);
            emit(newState);
          } else if (streamState is WsStateUpdateStatus){
            final copyState = state.from();
            final List<DialogData> newDialogs = [...copyState.dialogs ?? <DialogData>[]];

            for (var dialog in newDialogs) {
              if (dialog.dialogId == streamState.statuses.last.dialogId) {
                dialog.lastMessage.statuses.addAll(streamState.statuses);
              }
            }
            final newState = state.copyWith(dialogs: newDialogs);
            emit(newState);
          } else if (streamState is WsStateNewDialogCreated) {
            add(ReceiveNewDialogEvent(dialog: streamState.dialog));
          } else if (streamState is WsStateNewUserJoinDialog) {
            add(DialogUserJoinChatEvent(user: streamState.user, dialogId: streamState.dialogId));
          } else if (streamState is WsStateNewUserExitDialog) {
            add(DialogUserExitChatEvent(user: streamState.user, dialogId: streamState.dialogId));
          } else if (streamState is WsStateDialogDeleted) {
            add(DialogDeletedChatEvent(dialog: streamState.dialog));
          }
        });
    on<DialogsEvent>((event, emit) async {
      print("DialogsEvent   ${event}  ${state.dialogs}");
      if (event is DialogsLoadEvent) {
        await onDialogsLoadEvent(event, emit);
      } else if (event is ReceiveNewDialogEvent) {
        onReceiveNewDialogEvent(event, emit);
      } else if (event is UpdateDialogLastMessageEvent) {
        onUpdateDialogLastMessageEvent(event, emit);
      } else if (event is DialogUserJoinChatEvent) {
        onDialogUserJoinChatEvent(event, emit);
      } else if (event is DialogUserExitChatEvent) {
        onDialogUserExitChatEvent(event, emit);
      } else if (event is RefreshDialogsEvent) {
        onRefreshDialogsEvent(event, emit);
      } else if (event is DeleteAllDialogsEvent) {
        onDeleteAllDialogsEvent(event, emit);
      } else if (event is DialogDeletedChatEvent) {
        onDialogDeletedChatEvent(event, emit);
      }
    });
  }

  Future<void> onDialogsLoadEvent (
      DialogsLoadEvent event, Emitter<DialogsState> emit
      ) async {
    try {
      List<DialogData> dialogs = await dialogRepository.getDialogs();
      if (dialogs.isNotEmpty) sortDialogsByLastMessage(dialogs);
      print("Dialogs  $dialogs");
      final newState = state.copyWith(dialogs: dialogs);
      emit(newState);
    } catch(err, stackTrace) {
      print("onDialogsLoadEvent::::: $err");
      err as AppErrorException;
      _logger.sendErrorTrace(stackTrace: stackTrace, errorType: err.type.toString());
      if (err.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
      } else {
        final errorState = state.copyWith(dialogs: [], searchQuery: "", isErrorHappened: true);
        emit(errorState);
      }
    }
  }

  void onReceiveNewDialogEvent(
      ReceiveNewDialogEvent event,
      Emitter<DialogsState> emit
  ) {
    for (var dialog in state.dialogs!) {
      if (dialog.dialogId == event.dialog.dialogId) {
        return;
      }
    }
    final newDialogs = [ ...state.dialogs!, event.dialog];
    final newState = state.copyWith(dialogs: newDialogs);
    print(newState.dialogs?.length);
    emit(newState);
  }

  void onDialogUserJoinChatEvent(DialogUserJoinChatEvent event, emit) {
    try {
      final copyState = state.from();
      final newDialogs = [ ...copyState.dialogs!];
      for (var dialog in newDialogs) {
        if(dialog.dialogId == event.dialogId) {
          dialog.usersList.add(event.user.user);
          dialog.chatUsers.add(event.user);
          final newState = state.copyWith(dialogs: newDialogs);
          emit(newState);
          return;
        }
      }
    } catch (err, stackTrace) {
      _logger.sendErrorTrace(stackTrace: stackTrace);
    }
  }


  void onDialogUserExitChatEvent(DialogUserExitChatEvent event, emit) {
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogs!];
    for (var dialog in newDialogs) {
      if(dialog.dialogId == event.dialogId) {
        for (var user in dialog.chatUsers) {
          if (user.user.id == event.user.user.id) {
            dialog.chatUsers.remove(user);
            break;
          }
        }
        break;
      }
    }
    final newState = state.copyWith(dialogs: newDialogs);
    emit(newState);
  }

  void onUpdateDialogLastMessageEvent(
      UpdateDialogLastMessageEvent event,
      Emitter<DialogsState> emit
      ) {
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogs!];
    for (var dialog in newDialogs) {
      if (dialog.dialogId == event.message.dialogId) {
        dialog.lastMessage.message = event.message.message;
        dialog.lastMessage.messageId = event.message.messageId;
        dialog.lastMessage.senderId = event.message.senderId;
        dialog.lastMessage.time = event.message.rawDate;
        dialog.lastMessage.statuses = event.message.status;

      }
    }
    final newState = state.copyWith(dialogs: newDialogs);
    emit(newState);
  }

  void onRefreshDialogsEvent(
      RefreshDialogsEvent event,
      Emitter<DialogsState> emit
      ){
    add(DialogsLoadEvent());
  }

  void onDeleteAllDialogsEvent(
      DeleteAllDialogsEvent event,
      Emitter<DialogsState> emit
      ){
    final newState = state.copyWith(dialogs: [], isErrorHappened:  false, searchQuery: "");
    emit(newState);
  }

  void onDialogDeletedChatEvent(
      DialogDeletedChatEvent event,
      Emitter<DialogsState> emit
      ){
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogs!];
    newDialogs.removeWhere((dialog) => dialog.dialogId == event.dialog.dialogId);
    emit(state.copyWith(dialogs: newDialogs));
  }



}

Map<String, dynamic> makeJsonMessage(MessageData message) {
  return {
    "id": message.messageId,
    "message": message.message,
    "user_id": message.senderId,
    "created_at": message.rawDate,
    "statuses": [
      {
        "id": message.status.first.id,
        "user_id": message.status.first.userId,
        "chat_message_id": message.status.first.messageId,
        "chat_id": message.status.first.dialogId,
        "chat_message_status_id": message.status.first.statusId,
        "created_at": message.status.first.createdAt
      },
      {
        "id": message.status.last.id,
        "user_id": message.status.last.userId,
        "chat_message_id": message.status.last.messageId,
        "chat_id": message.status.last.dialogId,
        "chat_message_status_id": message.status.last.statusId,
        "created_at": message.status.last.createdAt
      }
    ]
  };
}


sortDialogsByLastMessage(List<DialogData> dialogs){
  dialogs.sort((a, b) {
    final DateTime? aTime = a.lastMessage.time ?? a.createdAt;
    final DateTime? bTime = b.lastMessage.time ?? b.createdAt;

    return bTime!.millisecondsSinceEpoch.compareTo(aTime!.millisecondsSinceEpoch);
  });
  return dialogs;
}