import 'dart:async';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_list_container.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/storage/data_storage.dart';
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
            final List<DialogData> newDialogs = [...copyState.dialogsContainer!.dialogs];
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
            final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
            emit(newState);
          } else if (streamState is WsStateUpdateStatus){
            final copyState = state.from();
            final List<DialogData> newDialogs = [...copyState.dialogsContainer?.dialogs ?? <DialogData>[]];

            for (var dialog in newDialogs) {
              if (dialog.dialogId == streamState.statuses.last.dialogId) {
                dialog.lastMessage.statuses.addAll(streamState.statuses);
              }
            }
            final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
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
      print("DialogsEvent   ${event}  ${state.dialogsContainer}");
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
      } else if (event is DeleteDialogsOnLogoutEvent) {
        onDeleteDialogsOnLogoutEvent(event, emit);
      } else if (event is DialogDeletedChatEvent) {
        onDialogDeletedChatEvent(event, emit);
      } else if (event is DialogsSearchDialogEvent) {
        await onDialogsSearchEvent(event, emit);
      }
    });
  }

  Future<void> onDialogsLoadEvent (
      DialogsLoadEvent event, Emitter<DialogsState> emit
      ) async {
    try {
      emit(state.copyWith(isLoading: true));
      List<DialogData> dialogs = await dialogRepository.getDialogs();
      if (dialogs.isNotEmpty) sortDialogsByLastMessage(dialogs);
      final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: dialogs), isLoading: false, isAuthenticated: true, isErrorHappened: false, isFirstInitialized: true);
      emit(newState);
    } catch(err, stack) {
      if (err is AppErrorException && err.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
      } else {
        err as AppErrorException;
        final errorState = state.copyWith(dialogsContainer: const DialogsListContainer.initial(), isLoading: false, searchQuery: "", isErrorHappened: true, errorType: err.type, isFirstInitialized: true);
        emit(errorState);
      }
    }
  }

  Future<void> onDialogsSearchEvent(
      DialogsSearchDialogEvent event, Emitter<DialogsState> emit
      ) async {
    try {
      print("Dialogs search ${event.searchQuery}");
      if (event.searchQuery != "") {
        final query = event.searchQuery.toLowerCase();
        final userId = await DataProvider().getUserId();
        final filteredDialogs =
            filterDialogsBySearchQuery(state.dialogsContainer!.dialogs, query, int.parse(userId!));
        final container = state.searchedContainer!.copyWith(dialogs: filteredDialogs);
        emit(state.copyWith(searchedDialogs: container, searchQuery: event.searchQuery));
      } else {
        final container = state.dialogsContainer!;
        final newContainer = container.copyWith(dialogs: container.dialogs);
        emit(state.copyWith(dialogsContainer: newContainer, searchQuery: event.searchQuery));
      }
    } catch (err, stackTrace) {
      print("Search dialog error $err \r\n $stackTrace");
      emit(state.copyWith(errorType: AppErrorExceptionType.other, isErrorHappened: true));
    }
  }

  void onReceiveNewDialogEvent(
      ReceiveNewDialogEvent event,
      Emitter<DialogsState> emit
  ) {
    for (var dialog in state.dialogsContainer!.dialogs) {
      if (dialog.dialogId == event.dialog.dialogId) {
        return;
      }
    }
    final newDialogs = [ event.dialog, ...state.dialogsContainer!.dialogs];
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
    emit(newState);
  }

  void onDialogUserJoinChatEvent(DialogUserJoinChatEvent event, emit) {
    try {
      final copyState = state.from();
      final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
      for (var dialog in newDialogs) {
        if(dialog.dialogId == event.dialogId) {
          dialog.usersList.add(event.user.user);
          dialog.chatUsers.add(event.user);
          final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
          emit(newState);
          return;
        }
      }
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
    }
  }


  void onDialogUserExitChatEvent(DialogUserExitChatEvent event, emit) {
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
    for (var dialog in newDialogs) {
      if(dialog.dialogId == event.dialogId) {
        for (var user in dialog.chatUsers) {
          if (user.userId == event.user.userId) {
            dialog.chatUsers.remove(user);
            break;
          }
        }
        break;
      }
    }
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
    emit(newState);
  }

  void onUpdateDialogLastMessageEvent(
      UpdateDialogLastMessageEvent event,
      Emitter<DialogsState> emit
      ) {
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
    for (var dialog in newDialogs) {
      if (dialog.dialogId == event.message.dialogId) {
        dialog.lastMessage.message = event.message.message;
        dialog.lastMessage.messageId = event.message.messageId;
        dialog.lastMessage.senderId = event.message.senderId;
        dialog.lastMessage.time = event.message.rawDate;
        dialog.lastMessage.statuses = event.message.status;

      }
    }
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
    emit(newState);
  }

  void onRefreshDialogsEvent(
      RefreshDialogsEvent event,
      Emitter<DialogsState> emit
      ){
    add(DialogsLoadEvent());
  }

  void onDeleteDialogsOnLogoutEvent(
      DeleteDialogsOnLogoutEvent event,
      Emitter<DialogsState> emit
      ){
    final newState = state.copyWith(dialogsContainer: const DialogsListContainer.initial(), isErrorHappened:  false, searchQuery: "", isAuthenticated: false);
    emit(newState);
  }

  void onDialogDeletedChatEvent(
      DialogDeletedChatEvent event,
      Emitter<DialogsState> emit
      ){
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
    newDialogs.removeWhere((dialog) => dialog.dialogId == event.dialog.dialogId);
    emit(state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs)));
  }



}


List<DialogData> filterDialogsBySearchQuery(List<DialogData> dialogs, String searchQuery, int userId) {
  List<DialogData> filtered = [];
  final regex = RegExp(searchQuery, caseSensitive: false, multiLine: false);
  for (final dialog in dialogs) {
    final name = getChatItemName(dialog, userId);
    if (regex.hasMatch(name)) filtered.add(dialog);
  }
  return filtered;
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
}