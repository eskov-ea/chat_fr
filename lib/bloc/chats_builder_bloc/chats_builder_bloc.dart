import 'dart:async';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_builder_model.dart';
import '../../models/message_model.dart';
import '../error_handler_bloc/error_handler_bloc.dart';
import '../error_handler_bloc/error_handler_events.dart';
import '../error_handler_bloc/error_types.dart';
import '../ws_bloc/ws_bloc.dart';
import '../ws_bloc/ws_state.dart';
import 'chats_builder_event.dart';
import 'chats_builder_state.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


class ChatsBuilderBloc extends Bloc<ChatsBuilderEvent, ChatsBuilderState> {
  final MessagesRepository messagesRepository;
  final WsBloc webSocketBloc;
  final ErrorHandlerBloc errorHandlerBloc;
  final DataProvider dataProvider;
  late final StreamSubscription newMessageSubscription;

  ChatsBuilderBloc({
    required this.webSocketBloc,
    required this.dataProvider,
    required this.errorHandlerBloc,
    required this.messagesRepository}) : super( ChatsBuilderState.initial()){
    newMessageSubscription = webSocketBloc.stream.listen((streamState) {
      print("streamState   ${streamState}");
      if (streamState is WsStateReceiveNewMessage){
        print("ChatsBuilderAddMessageEvent");
        add(ChatsBuilderAddMessageEvent(message: streamState.message, dialogId: streamState.message.dialogId));
      } else if (streamState is WsStateUpdateStatus){
        print("WsStateUpdateStatus ololo   ${streamState.statuses}");
        add(ChatsBuilderReceivedUpdatedMessageStatusesEvent(statuses: streamState.statuses));
      }
    });
    print("newMessageSubscription $newMessageSubscription");

    on<ChatsBuilderEvent>((event, emit) async {
      print("ChatsBuilderEvent   $event");
      if(event is ChatsBuilderLoadMessagesEvent) {
        await onChatsBuilderLoadMessagesEvent(event, emit);
      } else if (event is ChatsBuilderAddMessageEvent) {
        onChatsBuilderAddMessageEvent(event, emit);
      } else if (event is ChatsBuilderUpdateStatusMessagesEvent) {
        await onChatsBuilderUpdateStatusMessagesEvent(event, emit);
      } else if (event is ChatsBuilderReceivedUpdatedMessageStatusesEvent) {
        onChatsBuilderReceivedUpdatedMessageStatusesEvent(event, emit);
      } else if (event is ChatsBuilderUpdateLocalMessageEvent) {
        onChatsBuilderUpdateLocalMessageEvent(event, emit);
      } else if (event is RefreshChatsBuilderEvent) {
        onRefreshChatsBuilderEvent(event, emit);
      } else if (event is DeleteAllChatsEvent) {
        onDeleteAllChatsEvent(event, emit);
      } else if (event is ChatsBuilderUpdateMessageWithErrorEvent) {
        onChatsBuilderUpdateLocalMessageWithErrorEvent(event, emit);
      } else if (event is ChatsBuilderDeleteLocalMessageEvent) {
        onChatsBuilderDeleteLocalMessageEvent(event, emit);
      } else if (event is ChatsBuilderDeleteMessagesEvent){
        onChatsBuilderDeleteMessagesEvent(event, emit);
      }
    });
  }


  Future<void> onChatsBuilderLoadMessagesEvent (
      ChatsBuilderLoadMessagesEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("onChatsBuilderLoadMessagesEvent");
    // TODO: refactor this part if necessary
    // emit(ChatsBuilderInProgressState(chats: state.chats, counter: state.counter));
    final userId = await dataProvider.getUserId();
    try {
      List<MessageData> messages = await messagesRepository.getMessages(
          userId, event.dialogId, event.pageNumber);
      print("Loaded messages:   pg:  ${event.pageNumber}   $messages");
      var chatExist = false;
      final Map<String, bool> newMessagesDictionary = state.messagesDictionary;
      for (var chat in state.chats) {
        if (chat.chatId == event.dialogId) {
          for (var message in messages) {
            if (newMessagesDictionary["${message.messageId}"] != true) {
              newMessagesDictionary["${message.messageId}"] = true;
              chat.messages.add(message);
            }
          }
          chatExist = true;
        }
      }
      if (chatExist == false) {
        for (var message in messages) {
          newMessagesDictionary["${message.messageId}"] = true;
        }
        state.chats.add(ChatsData.makeChatsData(event.dialogId, messages));
      }
      // final newState = state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++);
      emit(ChatsBuilderState(
        chats: state.chats,
        messagesDictionary: newMessagesDictionary,
        error: null,
        isError: false
      ));
    } catch (err) {
      final e = err as AppErrorException;
      if (e.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: e));
      } else {
        final errorState = state.copyWith(
          updatedChats: state.chats,
          updatedMessagesDictionary: state.messagesDictionary,
          error: e,
          isError: true
        );
        emit(errorState);
      }
    }
  }

  Future<void> onChatsBuilderAddMessageEvent (
      ChatsBuilderAddMessageEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("TRY TO ADD MESSAGE");
    if (state.messagesDictionary["${event.message.messageId}"] != null) {
      print("Message already in the list   ${event.message.messageId}");
      return;
    } else {
      final newDictionary = state.messagesDictionary;
      for (var chat in state.chats) {
        if (chat.chatId == event.dialogId) {
          print("ADD MESSAGE  ${event.message}");
          chat.messages.insert(0, event.message);
          newDictionary["${event.message.messageId}"] = true;
        }
      }
      emit(state.copyWith(
          updatedChats: state.chats));
      final userId = await dataProvider.getUserId();
      if (event.message.senderId.toString() != userId) {
        FlutterRingtonePlayer.play(
          android: AndroidSounds.notification,
          ios: IosSounds.glass,
          looping: false,
          volume: 1.0,
        );
      }
    }
  }

  Future<void> onChatsBuilderUpdateStatusMessagesEvent (
      ChatsBuilderUpdateStatusMessagesEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("UPDATE CHAT MESSAGES STATUSES");
    messagesRepository.updateMessageStatuses(dialogId: event.dialogId);
  }

  void onChatsBuilderReceivedUpdatedMessageStatusesEvent(
      ChatsBuilderReceivedUpdatedMessageStatusesEvent event, Emitter<ChatsBuilderState> emit
      ){
    //TODO: implement chat dictionary not list
    final chats = state.from();
    for (final MessageStatuses status in event.statuses) {
      for (var chat in chats) {
        if (chat.chatId == status.dialogId) {
          for (var message in chat.messages) {
            if (message.messageId == status.messageId &&
            !message.status.contains(status)) {
              message.status.add(status);
            }
          }
        }
      }
    }
    final newState = state.copyWith(updatedChats: chats);
    emit(newState);
  }

  onChatsBuilderUpdateLocalMessageEvent(
      ChatsBuilderUpdateLocalMessageEvent event, Emitter<ChatsBuilderState> emit
      ){
    final messagesDictionary = state.messagesDictionary;
    final chats = state.from();
    for (var chat in chats) {
      if (chat.chatId == event.dialogId) {
        print("ChatsBuilderUpdateLocalMessageEvent  ${event.message}   ${chat.messages.first.status}");
        final message = chat.messages.firstWhere((element) => element.messageId == event.localMessageId);
        message.messageId = event.message.messageId;
        if (event.message.file != null) {
          message.file!.attachmentId = event.message.file!.attachmentId;
        }
        message.status.addAll(event.message.status);
        messagesDictionary.remove("${event.localMessageId}");
        messagesDictionary["${event.message.messageId}"] = true;
      }
    }
    print("ChatsBuilderUpdateLocalMessageEvent    ${state.chats.first.messages.first.status}");
    print("ChatsBuilderUpdateLocalMessageEvent    ${chats.first.messages.first.status}");
    emit(state.copyWith(updatedChats: chats, updatedMessagesDictionary: messagesDictionary));
  }

  Future<void> onChatsBuilderUpdateLocalMessageWithErrorEvent (
      ChatsBuilderUpdateMessageWithErrorEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("TRY TO UPDATE ERROR MESSAGE");
    final chats = [...state.chats];
    for (var chat in chats) {
      if (chat.chatId == event.dialog) {
        print("UPDATE MESSAGE WITH ERROR  ${event.message}");
        for (var message in chat.messages) {
          if (message.messageId == event.message.messageId) {
            message.isError = true;
            break;
          }
        }
      }
    }
    emit(state.copyWith(
        updatedChats: chats));
  }

  @override
  Future<void> close() async {
    super.close();
  }

  void onRefreshChatsBuilderEvent(
      RefreshChatsBuilderEvent event,
      Emitter<ChatsBuilderState> emit
    ) {
    print("onRefreshChatsBuilderEvent ${state.chats.length}");
    final newState = state.copyWith(updatedChats: [], updatedCounter: 0);
    emit(newState);
  }

  void onDeleteAllChatsEvent(
      DeleteAllChatsEvent event,
      Emitter<ChatsBuilderState> emit
    ) {
    print("onRefreshChatsBuilderEvent ${state.chats.length}");
    final newState = state.copyWith(updatedChats: [], updatedCounter: 0);
    emit(newState);
  }

  void onChatsBuilderDeleteLocalMessageEvent(
      ChatsBuilderDeleteLocalMessageEvent event,
      Emitter<ChatsBuilderState> emit
      ) {
    final newState = [...state.chats];
    final ChatsData chat = newState.firstWhere((el) => el.chatId == event.dialogId);
    chat.messages.removeWhere((message) => message.messageId == event.messageId);
    emit(state.copyWith(updatedChats: newState, updatedMessagesDictionary: state.messagesDictionary));
  }

  void onChatsBuilderDeleteMessagesEvent(
      ChatsBuilderDeleteMessagesEvent event,
      Emitter<ChatsBuilderState> emit
      ) {
    final messagesToDelete = [];
    final newState = [...state.chats];
    final dialog = newState.firstWhere((d) => d.chatId == event.dialogId);
    for (var messageId in event.messagesId) {
      for (var message in dialog.messages) {
        if (message.messageId == messageId) {
          state.messagesDictionary[messageId.toString()] = false;
          messagesToDelete.add(message);
        }
      }
    }
    if (messagesToDelete.isNotEmpty)  {
      messagesToDelete.forEach((m) {
        dialog.messages.remove(m);
      });
      emit(state.copyWith(updatedChats: newState, updatedMessagesDictionary: state.messagesDictionary));
    }
  }
}

