import 'dart:async';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_builder_model.dart';
import '../../models/message_model.dart';
import '../ws_bloc/ws_bloc.dart';
import '../ws_bloc/ws_state.dart';
import 'chats_builder_event.dart';
import 'chats_builder_state.dart';


class ChatsBuilderBloc extends Bloc<ChatsBuilderEvent, ChatsBuilderState> {
  final MessagesProvider messagesProvider;
  final WsBloc webSocketBloc;
  late final StreamSubscription newMessageSubscription;

  ChatsBuilderBloc({
    required this.webSocketBloc,
    required this.messagesProvider}) : super( ChatsBuilderState.initial()){

    newMessageSubscription = webSocketBloc.stream.listen((streamState) {
      print("streamState   ${streamState}");
      if (streamState is WsStateReceiveNewMessage){
        print("ChatsBuilderAddMessageEvent");
        add(ChatsBuilderAddMessageEvent(message: streamState.message, dialog: streamState.message.dialogId));
      } else if (streamState is WsStateUpdateStatus){
        print("WsStateUpdateStatus   ${streamState.statuses}");
        add(ChatsBuilderReceivedUpdatedMessageStatusesEvent(statuses: streamState.statuses));
      } else if (streamState is WsStateNewDialogCreated) {

      } else if (streamState is Connected) {

      }
    });

    on<ChatsBuilderEvent>((event, emit) async {
      if(event is ChatsBuilderLoadMessagesEvent) {
        await onChatsBuilderLoadMessagesEvent(event, emit);
      } else if(event is ChatsBuilderCreateEvent) {
        await onChatsBuilderCreateEvent(event, emit);
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
      }
    });
  }


  Future<void> onChatsBuilderCreateEvent(
    ChatsBuilderCreateEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("onChatsBuilderCreateEvent");
  }

  Future<void> onChatsBuilderLoadMessagesEvent (
      ChatsBuilderLoadMessagesEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("onChatsBuilderLoadMessagesEvent");
    // TODO: refactor this part if necessary
    // emit(ChatsBuilderInProgressState(chats: state.chats, counter: state.counter));
    final userId = await DataProvider().getUserId();
    List<MessageData> messages = await messagesProvider.getMessages(userId, event.dialogId, event.pageNumber);
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
    emit(ChatsBuilderState(counter: state.counter++, chats: state.chats, messagesDictionary: newMessagesDictionary));
  }

  Future<void> onChatsBuilderAddMessageEvent (
      ChatsBuilderAddMessageEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("TRY TO ADD MESSAGE");
    if (state.messagesDictionary["${event.message.messageId}"] != null) {
      print("Message already in the list");
      return;
    } else {
      for (var chat in state.chats) {
        if (chat.chatId == event.dialog) {
          print("ADD MESSAGE  ${event.message}");
          chat.messages.insert(0, event.message);
        }
      }
      emit(state.copyWith(
          updatedChats: state.chats, updatedCounter: state.counter++));
    }
  }

  Future<void> onChatsBuilderUpdateStatusMessagesEvent (
      ChatsBuilderUpdateStatusMessagesEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("UPDATE CHAT MESSAGES STATUSES");
    messagesProvider.updateMessageStatuses(dialogId: event.dialogId);
  }

  void onChatsBuilderReceivedUpdatedMessageStatusesEvent(
      ChatsBuilderReceivedUpdatedMessageStatusesEvent event, Emitter<ChatsBuilderState> emit
      ){
    print("onChatsBuilderReceivedUpdatedMessageStatusesEvent");
    final chats = state.chats;
    for (final MessageStatuses status in event.statuses) {
      for (var chat in chats) {
        if (chat.chatId == status.dialogId) {
          for (var message in chat.messages) {
            if (message.messageId == status.messageId) {
              message.status.add(status);
            }
          }
        }
      }
    }
    emit(state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++));
  }

  onChatsBuilderUpdateLocalMessageEvent(
      ChatsBuilderUpdateLocalMessageEvent event, Emitter<ChatsBuilderState> emit
      ){
    for (var chat in state.chats) {
      if (chat.chatId == event.dialogId) {
        print("ChatsBuilderUpdateLocalMessageEvent");
        final message = chat.messages.firstWhere((element) => element.messageId == event.localMessageId);
        message.messageId = event.message.messageId;
        message.status.addAll(event.message.status);
        state.messagesDictionary["${event.message.messageId}"] = true;
      }
    }
    emit(state.copyWith(updatedChats: state.chats,
        updatedCounter: state.counter++));
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

}

