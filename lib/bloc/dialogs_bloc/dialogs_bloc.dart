import 'dart:async';
import 'dart:convert';

import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/bloc/user_bloc/user_state.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/message_model.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../ws_bloc/ws_bloc.dart';
import '../ws_bloc/ws_event.dart';
import '../ws_bloc/ws_state.dart';


class DialogsBloc extends Bloc<DialogsEvent, DialogsState> {
  final DialogsProvider dialogsProvider;
  late final StreamSubscription newMessageSubscription;
  final WsBloc webSocketBloc;

  DialogsBloc({
    required DialogsState initialState,
    required this.webSocketBloc,
    required this.dialogsProvider}) : super(initialState) {
        newMessageSubscription = webSocketBloc.stream.listen((streamState) {
          print("DIALOGEXIT   ${streamState}");
          if (streamState is WsStateReceiveNewMessage){
            final dialogs = state.dialogs;
            final List<DialogData> newDialogs = [...dialogs!];
            for (var dialog in newDialogs) {
              print("LastMessageData ${dialog.lastMessage}, ");
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
                  print("LastMessageData ${jsonMessage}, ");
                  dialog.lastMessage = LastMessageData.fromJson(jsonMessage);
                }
              }
            }
            final newState = state.copyWith(dialogs: newDialogs);
            emit(newState);
          } else if (streamState is WsStateUpdateStatus){
            final dialogs = state.dialogs;
            final List<DialogData> newDialogs = [...dialogs!];

            for (var chat in newDialogs) {
              if (chat.dialogId == streamState.statuses.last.dialogId) {
                print("SHITMACUS   ${chat.lastMessage.statuses.length}");
                chat.lastMessage.statuses.addAll(streamState.statuses);
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
          }
        });
    on<DialogsEvent>((event, emit) async {
      print("DIALOGEXIT   ${event}");
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
      }
    });
  }

  Future<void> onDialogsLoadEvent (
      DialogsLoadEvent event, Emitter<DialogsState> emit
      ) async {
    List<DialogData>? dialogs = await dialogsProvider.getDialogs();
    if (dialogs != null) sortDialogsByLastMessage(dialogs);
    final newState = state.copyWith(dialogs: dialogs);
    emit(newState);
    webSocketBloc.add(InitializeSocketEvent());
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
    emit(newState);
  }

  void onDialogUserJoinChatEvent(DialogUserJoinChatEvent event, emit) {
    final newDialogs = [ ...state.dialogs!];
    for (var dialog in newDialogs) {
      if(dialog.dialogId == event.dialogId) {
        dialog.usersList.add(event.user.user);
        dialog.chatUsers?.add(event.user);
        break;
      }
    }
    final newState = state.copyWith(dialogs: newDialogs);
    emit(newState);
  }

  void onDialogUserExitChatEvent(DialogUserExitChatEvent event, emit) {
    final newDialogs = [ ...state.dialogs!];
    for (var dialog in newDialogs) {
      if(dialog.dialogId == event.dialogId) {
        print("DIALOGEXIT   ${dialog.chatUsers!.length}");
        for (var user in dialog.chatUsers!) {
          if (user.user.id == event.user.user.id) {
            dialog.chatUsers!.remove(user);
            break;
          }
        }
        print("DIALOGEXIT   ${dialog.chatUsers!.length}");
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
    final newDialogs = [ ...state.dialogs!];
    for (var dialog in newDialogs) {
      print("LAST MESSAGE    ${ event.message}");
      if (dialog.dialogId == event.message.dialogId) {
        dialog.lastMessage.message = event.message.message;
        dialog.lastMessage.messageId = event.message.messageId;
        dialog.lastMessage.senderId = event.message.senderId;
        dialog.lastMessage.time = event.message.rawDate;
        dialog.lastMessage.statuses = event.message.status;

        newDialogs.remove(dialog);
        newDialogs.insert(0, dialog);

      }
    }
    final newState = state.copyWith(dialogs: newDialogs);
    emit(newState);
  }

  void onRefreshDialogsEvent(
      RefreshDialogsEvent event,
      Emitter<DialogsState> emit
      ){
    print("onDeleteDialogsEvent  ${state.dialogs?.length}");
    final newState = state.copyWith(dialogs: []);
    // emit(newState);
    add(DialogsLoadEvent());
  }

  void onDeleteAllDialogsEvent(
      DeleteAllDialogsEvent event,
      Emitter<DialogsState> emit
      ){
    print("onDeleteDialogsEvent  ${state.dialogs?.length}");
    final newState = state.copyWith(dialogs: []);
    emit(newState);
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
  // TODO: refactor, for now the chats being sorted on every state update.
  // It would be more optimize to sort only updated chat on received update.
  dialogs.sort((a, b) {
    if (b.lastMessage.time == null || a.lastMessage.time == null) {
      if (b.lastMessage.time != null && a.lastMessage.time == null) return 1;
      return 0;
    }
    return b.lastMessage.time!.millisecondsSinceEpoch.compareTo(a.lastMessage.time!.millisecondsSinceEpoch);
  });
  return dialogs;
}