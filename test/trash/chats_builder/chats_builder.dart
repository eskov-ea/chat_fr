import 'package:bloc_test/bloc_test.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
import 'package:chat/bloc/ws_bloc/ws_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_secure_storage/secure_storage.dart';
import '../mock_services/dialogs/mock_dialogs_repository.dart';
import '../mock_services/messages/mock_message_repository.dart';
import '../mock_services/messages/mock_object.dart';



void main() {
  group('ChatsBuilder bloc tests', () {

    final MockDialogsRepository dialogsRepository = MockDialogsRepository();
    final MockMessageRepository messageRepository = MockMessageRepository();
    final MockDataProvider secureStorage = MockDataProvider.storage;
    final WsBloc webSocketBloc = WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage);
    final ErrorHandlerBloc errorHandlerBloc = ErrorHandlerBloc();


    TestWidgetsFlutterBinding.ensureInitialized();

    test('initial state is correct', () {
      final chatsBuilderBloc = ChatsBuilderBloc(
          errorHandlerBloc: errorHandlerBloc,
          messagesRepository: messageRepository,
          webSocketBloc: webSocketBloc,
          dataProvider: MockDataProvider.storage
      );
      expect(chatsBuilderBloc.state, ChatsBuilderState.initial());
    });


    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs and emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) => bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180)),
        wait: const Duration(seconds: 2),
        expect: () => [
          ChatsBuilderState(
            chats: initialChats(),
            messages: initialMessageDictionary(),
            error: null,
            isError: false,
          )
        ]
    );

    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs and add a new message then emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) async {
          bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180));
          await Future.delayed(Duration(seconds: 2));
          bloc.add(ChatsBuilderAddMessageEvent(dialogId: 180, message: newMessage));
        },
        expect: () => [
          ChatsBuilderState(
            chats: initialChatsWithNewMessage(initialChats(), newMessage),
            messages: initialMessageDictionaryWithNewMessage(initialMessageDictionary(), newMessage),
            error: null,
            isError: false,
          )
        ]
    );

    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs and add a new message twice then emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) async {
          bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180));
          await Future.delayed(Duration(seconds: 2));
          bloc.add(ChatsBuilderAddMessageEvent(dialogId: 180, message: newMessage));
          bloc.add(ChatsBuilderAddMessageEvent(dialogId: 180, message: newMessage));
        },
        expect: () => [
          ChatsBuilderState(
            chats: initialChatsWithNewMessage(initialChats(), newMessage),
            messages: initialMessageDictionaryWithNewMessage(initialMessageDictionary(), newMessage),
            error: null,
            isError: false,
          )
        ]
    );

    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs, get updated message status and emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) async {
          bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180));
          await Future.delayed(Duration(seconds: 2));
          bloc.add(ChatsBuilderReceivedUpdatedMessageStatusesEvent(statuses: newMessageStatus));
        },
        expect: () => [
          ChatsBuilderState(
            chats: initialChatsWithNewStatus(initialChats(), newMessageStatus),
            messages: initialMessageDictionary(),
            error: null,
            isError: false,
          )
        ]
    );

    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs, get updated message status twice and emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) async {
          bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180));
          await Future.delayed(Duration(seconds: 2));
          bloc.add(ChatsBuilderReceivedUpdatedMessageStatusesEvent(statuses: newMessageStatus));
          bloc.add(ChatsBuilderReceivedUpdatedMessageStatusesEvent(statuses: newMessageStatus));
        },
        expect: () => [
          ChatsBuilderState(
            chats: initialChatsWithNewStatus(initialChats(), newMessageStatus),
            messages: initialMessageDictionary(),
            error: null,
            isError: false,
          )
        ]
    );

    blocTest<ChatsBuilderBloc, ChatsBuilderState>(
        "Load dialogs, add a local message then update it with the real one and emit",
        build: () => ChatsBuilderBloc(
            errorHandlerBloc: errorHandlerBloc,
            messagesRepository: messageRepository,
            webSocketBloc: webSocketBloc,
            dataProvider: MockDataProvider.storage
        ),
        act: (bloc) async {
          bloc.add(ChatsBuilderLoadMessagesEvent(dialogId: 180));
          await Future.delayed(Duration(seconds: 2));
          bloc.add(ChatsBuilderAddMessageEvent(dialogId: 180, message: localMessage));
          bloc.add(ChatsBuilderUpdateLocalMessageEvent(localMessageId: 11113, message: updatedLocalMessage, dialogId: 180));
        },
        expect: () => [
          ChatsBuilderState(
            chats: initialChatsWithNewMessage(initialChats(), updatedLocalMessage),
            messages: initialMessageDictionaryWithNewMessage(initialMessageDictionary(), updatedLocalMessage),
            error: null,
            isError: false,
          )
        ]
    );


  });


}