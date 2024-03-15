import 'dart:async';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_list_container.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/bloc/dialogs_bloc/group_dialog_members_streamer.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DialogsBloc extends Bloc<DialogsEvent, DialogsState> {
  final DialogRepository dialogRepository;
  final ErrorHandlerBloc errorHandlerBloc;
  final DatabaseBloc databaseBloc;
  final _storage = DataProvider.storage;
  late final StreamSubscription<DatabaseBlocState> databaseDialogEventSubscription;
  final GroupDialogsMemberStateStreamer _groupDialogsMemberStateStreamer = GroupDialogsMemberStateStreamer.instance;

  DialogsBloc({
    required DialogsState initialState,
    required this.databaseBloc,
    required this.errorHandlerBloc,
    required this.dialogRepository
  }) : super(initialState) {
    databaseDialogEventSubscription = databaseBloc.stream.listen(_onDatabaseEvent);

    on<DialogsEvent>((event, emit) async {
      print("DialogsEvent   ${event}  ${state.dialogsContainer}");
      if (event is DialogsLoadEvent) {
        await onDialogsLoadEvent(event, emit);
      } else if (event is ReceiveNewDialogEvent) {
        onReceiveNewDialogEvent(event, emit);
      } else if (event is ReceiveDialogsOnUpdateEvent) {
        onReceiveDialogsOnUpdateEvent(event, emit);
      } else if (event is DialogsLoadedEvent) {
        onDialogsLoadedEvent(event, emit);
      } else if (event is DialogStateNewMessageReceived) {
        onDialogStateNewMessageReceived(event, emit);
      }  else if (event is DialogStateNewMessagesOnUpdate) {
        onDialogStateNewMessagesOnUpdate(event, emit);
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
      } else if (event is DialogStateNewMessageStatusesReceived) {
        await onDialogStateNewMessageStatusesReceived(event, emit);
      }
    });
  }

  void _onDatabaseEvent(DatabaseBlocState event) {
    print("Database state change   ${event}");
    if (event is DatabaseBlocDBInitializedState) {
      print('initialized:: ${event.dialogs}');
      add(DialogsLoadedEvent(dialogs: event.dialogs));
    } else if (event is DatabaseBlocNewDialogReceivedState) {
      add(ReceiveNewDialogEvent(dialog: event.dialog));
    } else if (event is DatabaseBlocNewDialogsOnUpdateState) {
      add(ReceiveDialogsOnUpdateEvent(dialogs: event.dialogs));
    } else if (event is DatabaseBlocNewMessageReceivedState) {
      add(DialogStateNewMessageReceived(message: event.message));
    } else if (event is DatabaseBlocNewMessagesOnUpdateReceivedState) {
      add(DialogStateNewMessagesOnUpdate(messages: event.messages));
    } else if (event is DatabaseBlocUpdateMessageStatusesState) {
      add(DialogStateNewMessageStatusesReceived(statuses: event.statuses));
    } else if (event is DatabaseBlocUpdateMessageStatusesState) {
      add(DialogStateNewMessageStatusesReceived(statuses: event.statuses));
    }  else if (event is DatabaseBlocUserExitChatState) {
      _groupDialogsMemberStateStreamer.add(ChatUserEvent(chatUser: event.chatUser, event: event.event));
    }   else if (event is DatabaseBlocUserJoinChatState) {
      _groupDialogsMemberStateStreamer.add(ChatUserEvent(chatUser: event.chatUser, event: event.event));
    }
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

  Future<void> onDialogStateNewMessageStatusesReceived(
      DialogStateNewMessageStatusesReceived event,
      emit
  ) async {
    final userId = await _storage.getUserId();
    for (final status in event.statuses) {
      for (final dialog in state.dialogs) {
        if(dialog.dialogId == status.dialogId) {
          if (dialog.lastMessage != null) dialog.lastMessage!.statuses.add(status);
          if (userId != null && status.userId == userId) emit(state.copyWith());
        }
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
        final userId = await DataProvider.storage.getUserId();
        final filteredDialogs =
            filterDialogsBySearchQuery(state.dialogsContainer!.dialogs, query, userId!);
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
    for (var dialog in state.dialogsContainer.dialogs) {
      if (dialog.dialogId == event.dialog.dialogId) {
        return;
      }
    }
    final newDialogs = [ event.dialog, ...state.dialogsContainer.dialogs];
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
    emit(newState);
  }

  void onReceiveDialogsOnUpdateEvent(
      ReceiveDialogsOnUpdateEvent event,
      Emitter<DialogsState> emit
  ) {
    final newDialogs = <DialogData>[];
    for (var newDialog in event.dialogs) {
      if (newDialog.dialogId == 265) {
        print('onReceiveDialogsOnUpdateEvent:: $newDialog');
        print('onReceiveDialogsOnUpdateEvent:: ${newDialog.lastMessage}');
      }
      bool exist = false;
      for (var dialog in state.dialogsContainer.dialogs) {
        if (dialog.dialogId == newDialog.dialogId) {
          dialog.lastMessage = newDialog.lastMessage;
          exist = true;
          break;
        }
      }
      if (!exist) {
        newDialogs.add(newDialog);
      }
    }
    final updatedDialogs = [ ...newDialogs, ...state.dialogsContainer.dialogs];
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: updatedDialogs));
    emit(newState);
  }

  void onDialogsLoadedEvent(
      DialogsLoadedEvent event,
      Emitter<DialogsState> emit
      ) {
    print('onReceiveNewDialogEvent:: 11 ${state.dialogsContainer.dialogs}');
    emit(state.copyWith(dialogsContainer: DialogsListContainer(dialogs: event.dialogs), isFirstInitialized: true, isAuthenticated: true, isLoading: false));
  }

  void onDialogUserJoinChatEvent(DialogUserJoinChatEvent event, emit) {
    try {
      final copyState = state.from();
      final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
      //TODO: refactor db
      // for (var dialog in newDialogs) {
      //   if(dialog.dialogId == event.dialogId) {
      //     dialog.usersList.add(event.user.user);
      //     dialog.chatUsers.add(event.user);
      //     final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
      //     emit(newState);
      //     return;
      //   }
      // }
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
    }
  }


  void onDialogUserExitChatEvent(DialogUserExitChatEvent event, emit) {
    final copyState = state.from();
    final newDialogs = [ ...copyState.dialogsContainer!.dialogs];
    //TODO: refactor db
    // for (var dialog in newDialogs) {
    //   if(dialog.dialogId == event.dialogId) {
    //     for (var user in dialog.chatUsers) {
    //       if (user.userId == event.user.userId) {
    //         dialog.chatUsers.remove(user);
    //         break;
    //       }
    //     }
    //     break;
    //   }
    // }
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: newDialogs));
    emit(newState);
  }

  void onDialogStateNewMessageReceived(
      DialogStateNewMessageReceived event,
      Emitter<DialogsState> emit
      ) {
    final newDialogs = state.dialogs;
    for (var dialog in newDialogs) {
      if (dialog.dialogId == event.message.dialogId) {
        dialog.lastMessage = event.message;
        // dialog.lastMessage.messageId = event.message.messageId;
        // dialog.lastMessage.senderId = event.message.senderId;
        // dialog.lastMessage.time = event.message.rawDate;
        // dialog.lastMessage.statuses = event.message.status;
      }
    }
    print('onDialogStateNewMessageReceived  $newDialogs');
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: sortDialogsByLastMessage(newDialogs)));
    emit(newState);
  }

  void onDialogStateNewMessagesOnUpdate(
      DialogStateNewMessagesOnUpdate event,
      Emitter<DialogsState> emit
      ) {
    final newDialogs = state.dialogs;
    for (var message in event.messages) {
      for (var dialog in newDialogs) {
        if (dialog.dialogId == message.dialogId) {
          dialog.lastMessage = message;
        }
      }
    }

    print('onDialogStateNewMessageReceived  $newDialogs');
    final newState = state.copyWith(dialogsContainer: DialogsListContainer(dialogs: sortDialogsByLastMessage(newDialogs)));
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
        "id": message.statuses.first.id,
        "user_id": message.statuses.first.userId,
        "chat_message_id": message.statuses.first.messageId,
        "chat_id": message.statuses.first.dialogId,
        "chat_message_status_id": message.statuses.first.statusId,
        "created_at": message.statuses.first.createdAt
      },
      {
        "id": message.statuses.last.id,
        "user_id": message.statuses.last.userId,
        "chat_message_id": message.statuses.last.messageId,
        "chat_id": message.statuses.last.dialogId,
        "chat_message_status_id": message.statuses.last.statusId,
        "created_at": message.statuses.last.createdAt
      }
    ]
  };
}


List<DialogData> sortDialogsByLastMessage(List<DialogData> dialogs){
  dialogs.sort((a, b) {
    final DateTime? aTime = a.lastMessage?.rawDate ?? a.createdAt;
    final DateTime? bTime = b.lastMessage?.rawDate ?? b.createdAt;

    return bTime!.millisecondsSinceEpoch.compareTo(aTime!.millisecondsSinceEpoch);
  });
  return dialogs;
}