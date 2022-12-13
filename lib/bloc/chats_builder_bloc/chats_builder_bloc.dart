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
        Future.microtask(() =>
           onChatsBuilderAddMessageEvent(event, emit));
      } else if (event is ChatsBuilderUpdateStatusMessagesEvent) {
        await onChatsBuilderUpdateStatusMessagesEvent(event, emit);
      } else if (event is ChatsBuilderReceivedUpdatedMessageStatusesEvent) {
        onChatsBuilderReceivedUpdatedMessageStatusesEvent(event, emit);
      } else if (event is ChatsBuilderUpdateLocalMessageEvent) {
        onChatsBuilderUpdateLocalMessageEvent(event, emit);
      } else if (event is RefreshChatsBuilderEvent) {
        onRefreshChatsBuilderEvent(event, emit);
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
    for (var chat in state.chats) {
      if (chat.chatId == event.dialogId) {
        chat.messages.addAll(messages);
        chatExist = true;
      }
    }
    if (chatExist == false) {
      state.chats.add(ChatsData.makeChatsData(event.dialogId, messages));
    }
    // final newState = state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++);
    emit(ChatsBuilderState(counter: state.counter++, chats: state.chats));
  }

  Future<void> onChatsBuilderAddMessageEvent (
      ChatsBuilderAddMessageEvent event, Emitter<ChatsBuilderState> emit
      ) async {
    print("TRY TO ADD MESSAGE");
    for (var chat in state.chats) {
      if (chat.chatId == event.dialog) {
        if (chat.messages.isEmpty || chat.messages.last.messageId != event.message.messageId) {
          chat.messages.insert(0, event.message);
        }
      }
    }
    emit(state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++));
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
        print("CHATS LOCAL   ${chat.messages}");
        final message = chat.messages.firstWhere((element) => element.messageId == event.messageId);
        message.messageId = event.message.messageId;
        message.status.addAll(event.message.status);
      }
    }
    emit(state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++));
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

}

