import 'dart:async';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_builder_model.dart';
import '../../models/message_model.dart';
import '../../services/logger/logger_service.dart';
import '../error_handler_bloc/error_handler_bloc.dart';
import '../error_handler_bloc/error_handler_events.dart';
import '../error_handler_bloc/error_types.dart';
import '../ws_bloc/ws_bloc.dart';
import '../ws_bloc/ws_state.dart';
import 'message_event.dart';
import 'message_state.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


class MessageBloc extends Bloc<MessageBlocEvent, MessagesBlocState> {
  final MessagesRepository messagesRepository;

  final DatabaseBloc databaseBloc;
  final ErrorHandlerBloc errorHandlerBloc;
  final DataProvider dataProvider;
  final DBProvider db = DBProvider.db;
  late final StreamSubscription newMessageSubscription;

  MessageBloc({
    required this.databaseBloc,
    required this.dataProvider,
    required this.errorHandlerBloc,
    required this.messagesRepository}) : super(MessageBlocInitialState()) {
    newMessageSubscription = databaseBloc.stream.listen((event) {
      print("newMessageSubscription::::   ${event}");
      if (event is DatabaseBlocNewMessageReceivedState) {
        add(MessageBlocReceivedMessageEvent(message: event.message));
      } else if (event is DatabaseBlocUpdateMessageStatusesState) {
        add(MessageBlocNewMessageStatusesReceivedEvent(
            statuses: event.statuses));
      } else if (event is DatabaseBlocUpdateLocalMessageState) {
        add(MessageBlocUpdateLocalMessageEvent(
            localId: event.localId,
            dialogId: event.dialogId,
            messageId: event.messageId,
            statuses: event.statuses
        ));
      }
    });

    on<MessageBlocEvent>((event, emit) async {
      print("ChatsBuilderEvent   $event");
      if (event is MessageBlocReceivedMessageEvent) {
        onMessageBlocReceivedMessageEvent(event, emit);
      } else if (event is MessageBlocLoadMessagesEvent) {
        await onMessageBlocLoadMessagesEvent(event, emit);
      } else if (event is MessageBlocFlushMessagesEvent) {
        onMessageBlocFlushMessagesEvent(event, emit);
      } else if (event is MessageBlocLoadNextPortionMessagesEvent) {
        await onMessageBlocLoadNextPortionMessagesEvent(event, emit);
      } else if (event is MessageBlocSendReadMessagesStatusEvent) {
        onMessageBlocSendReadMessagesStatusEvent(event, emit);
      } else if (event is MessageBlocNewMessageStatusesReceivedEvent) {
        onMessageBlocNewMessageStatusesReceivedEvent(event, emit);
      } else if (event is MessageBlocUpdateLocalMessageEvent) {
        onMessageBlocUpdateLocalMessageEvent(event, emit);
      }


      // if(event is ChatsBuilderLoadMessagesEvent) {
      //   await onChatsBuilderLoadMessagesEvent(event, emit);
      // } else if (event is ChatsBuilderAddMessageEvent) {
      //   onChatsBuilderAddMessageEvent(event, emit);
      // } else if (event is ChatsBuilderUpdateStatusMessagesEvent) {
      //   await onChatsBuilderUpdateStatusMessagesEvent(event, emit);
      // } else if (event is ChatsBuilderReceivedUpdatedMessageStatusesEvent) {
      //   onChatsBuilderReceivedUpdatedMessageStatusesEvent(event, emit);
      // } else if (event is ChatsBuilderUpdateLocalMessageEvent) {
      //   onChatsBuilderUpdateLocalMessageEvent(event, emit);
      // } else if (event is RefreshChatsBuilderEvent) {
      //   onRefreshChatsBuilderEvent(event, emit);
      // } else if (event is DeleteAllChatsEvent) {
      //   onDeleteAllChatsEvent(event, emit);
      // } else if (event is ChatsBuilderUpdateMessageWithErrorEvent) {
      //   onChatsBuilderUpdateLocalMessageWithErrorEvent(event, emit);
      // } else if (event is ChatsBuilderDeleteLocalMessageEvent) {
      //   onChatsBuilderDeleteLocalMessageEvent(event, emit);
      // } else if (event is ChatsBuilderDeleteMessagesEvent){
      //   onChatsBuilderDeleteMessagesEvent(event, emit);
      // }
    }, transformer: sequential());
  }

  Future onMessageBlocLoadMessagesEvent(MessageBlocLoadMessagesEvent event,
      emit) async {
    final lastDialogPage = await db.getLastDialogPage(event.dialogId);

    if (lastDialogPage != null) {
      print('got messages:::  db');
      final messages = await db.getMessagesByDialog(event.dialogId);
      emit(MessageBlocInitializationSuccessState(
          dialogId: event.dialogId, messages: messages));
    } else {
      print('got messages::: network');
      final userId = await dataProvider.getUserId();
      final messages = await MessagesRepository().getMessages(
          userId, event.dialogId, 1);
      final statuses = <MessageStatus>[];
      final files = <MessageAttachmentData>[];

      for (var message in messages) {
        statuses.addAll(message.statuses);
        if (message.file != null) files.add(message.file!);
      }

      await db.saveMessageStatuses(statuses);
      await db.saveAttachments(files);
      await db.saveMessages(messages);
      await db.updateDialogLastPage(event.dialogId, 1);

      emit(MessageBlocInitializationSuccessState(
          dialogId: event.dialogId, messages: messages));
    }
  }

  Future onMessageBlocLoadNextPortionMessagesEvent(
      MessageBlocLoadNextPortionMessagesEvent event,
      emit) async {
    final userId = await dataProvider.getUserId();
    final lastDialogPage = await db.getLastDialogPage(event.dialogId);
    final currentDialogPage = lastDialogPage! + 1;
    final newMessages = await MessagesRepository().getMessages(
        userId, event.dialogId, currentDialogPage);
    if (newMessages.isNotEmpty) {
      await db.saveMessages(newMessages);
      await db.updateDialogLastPage(event.dialogId, currentDialogPage);
      final messages = (state as MessageBlocInitializationSuccessState)
          .messages;

      messages.addAll(newMessages);

      emit(MessageBlocInitializationSuccessState(
          dialogId: event.dialogId, messages: messages)
      );
    }
  }

  void onMessageBlocFlushMessagesEvent(MessageBlocFlushMessagesEvent event,
      emit) {
    emit(MessageBlocInitialState());
  }

  void onMessageBlocReceivedMessageEvent(MessageBlocReceivedMessageEvent event,
      emit) {
    if (state is MessageBlocInitializationSuccessState) {
      final messages = (state as MessageBlocInitializationSuccessState)
          .messages;
      final dialogId = (state as MessageBlocInitializationSuccessState)
          .dialogId;
      if (dialogId != event.message.dialogId) return;
      messages.insert(0, event.message);
      emit(MessageBlocInitializationSuccessState(
          dialogId: dialogId, messages: messages));
    }
  }

  void onMessageBlocSendReadMessagesStatusEvent(
      MessageBlocSendReadMessagesStatusEvent event,
      Emitter<MessagesBlocState> emit) {
    messagesRepository.updateMessageStatuses(dialogId: event.dialogId);
  }

  void onMessageBlocNewMessageStatusesReceivedEvent(
      MessageBlocNewMessageStatusesReceivedEvent event,
      emit) async {
    if (state is MessageBlocInitializationSuccessState) {
      final dialogId = (state as MessageBlocInitializationSuccessState)
          .dialogId;
      final messages = (state as MessageBlocInitializationSuccessState)
          .messages;
      for (final status in event.statuses) {
        if (dialogId == status.dialogId) {
          for (final message in messages) {
            if (message.messageId == status.messageId) {
              message.statuses.add(status);
            }
          }
        }
        emit(MessageBlocInitializationSuccessState(
            dialogId: dialogId, messages: messages));
      }
    }
  }

  void onMessageBlocUpdateLocalMessageEvent(
      MessageBlocUpdateLocalMessageEvent event,
      emit) {
    print('we update locals');
    if (state is MessageBlocInitializationSuccessState) {
      final dialogId = (state as MessageBlocInitializationSuccessState)
          .dialogId;
      final messages = (state as MessageBlocInitializationSuccessState)
          .messages;
      if (dialogId == event.dialogId) {
        for (var message in messages) {
          if (message.messageId == event.localId) {
            message.messageId = event.localId;
            message.statuses.addAll(event.statuses);
            emit(MessageBlocInitializationSuccessState(
                dialogId: dialogId, messages: messages));
            return;
          }
        }
      }
    }

    // Future<void> onChatsBuilderLoadMessagesEvent (
    //     ChatsBuilderLoadMessagesEvent event, Emitter<MessagesBlocState> emit
    //     ) async {
    //   // TODO: refactor this part if necessary
    //   emit(state.copyWith(isLoadingMessages: true));
    //   final userId = await dataProvider.getUserId();
    //   try {
    //     List<MessageData> messages = await messagesRepository.getMessages(
    //         userId, event.dialogId, event.pageNumber);
    //     var chatExist = false;
    //     state.copyWith(isLoadingMessages: false);
    //     final Map<String, bool> newMessagesDictionary = state.messagesDictionary;
    //     for (var chat in state.chats) {
    //       if (chat.chatId == event.dialogId) {
    //         for (var message in messages) {
    //           if (newMessagesDictionary["${message.messageId}"] != true) {
    //             newMessagesDictionary["${message.messageId}"] = true;
    //             chat.messages.add(message);
    //           }
    //         }
    //         chatExist = true;
    //       }
    //     }
    //     if (chatExist == false) {
    //       for (var message in messages) {
    //         newMessagesDictionary["${message.messageId}"] = true;
    //       }
    //       state.chats.add(ChatsData.makeChatsData(event.dialogId, messages));
    //     }
    //     // final List<ChatsData> newChats = [...state.chats, ChatsData.makeChatsData(event.dialogId, messages)];
    //     // final newState = state.copyWith(updatedChats: state.chats, updatedCounter: state.counter++);
    //     emit(MessagesBlocState(
    //       chats: state.chats,
    //       messagesDictionary: newMessagesDictionary,
    //       error: null,
    //       isError: false,
    //       isLoadingMessages: false
    //     ));
    //   } catch (err, stackTrace) {
    //     print("$err, $stackTrace");
    //     if (err is AppErrorException && err.type == AppErrorExceptionType.auth) {
    //       errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
    //       final errorState = state.copyWith(
    //           updatedChats: state.chats,
    //           updatedMessagesDictionary: state.messagesDictionary,
    //           error: err,
    //           isError: true,
    //           isLoadingMessages: false
    //       );
    //       emit(errorState);
    //     } else if (err is AppErrorException) {
    //       final errorState = state.copyWith(
    //         updatedChats: state.chats,
    //         updatedMessagesDictionary: state.messagesDictionary,
    //         error: err,
    //         isError: true,
    //         isLoadingMessages: false
    //       );
    //       emit(errorState);
    //     } else {
    //       final errorState = state.copyWith(
    //           updatedChats: state.chats,
    //           updatedMessagesDictionary: state.messagesDictionary,
    //           error: AppErrorException(AppErrorExceptionType.other),
    //           isError: true,
    //           isLoadingMessages: false
    //       );
    //       emit(errorState);
    //     }
    //   }
    // }
    //
    // Future<void> onChatsBuilderAddMessageEvent (
    //     ChatsBuilderAddMessageEvent event, Emitter<MessagesBlocState> emit
    //     ) async {
    //   if (state.messagesDictionary["${event.message.messageId}"] != null) {
    //     return;
    //   } else {
    //     final newDictionary = state.messagesDictionary;
    //     for (var chat in state.chats) {
    //       if (chat.chatId == event.dialogId) {
    //         chat.messages.insert(0, event.message);
    //         newDictionary["${event.message.messageId}"] = true;
    //       }
    //     }
    //     emit(state.copyWith(
    //         updatedChats: state.chats));
    //     final userId = await dataProvider.getUserId();
    //     if (event.message.senderId.toString() != userId) {
    //       FlutterRingtonePlayer.play(
    //         android: AndroidSounds.notification,
    //         ios: IosSounds.glass,
    //         looping: false,
    //         volume: 1.0,
    //       );
    //     }
    //   }
    // }
    //

    //
    // void onChatsBuilderReceivedUpdatedMessageStatusesEvent(
    //     ChatsBuilderReceivedUpdatedMessageStatusesEvent event, Emitter<MessagesBlocState> emit
    //     ){
    //   //TODO: implement chat dictionary not list
    //   // final chats = state.from();
    //   final chats = state.chats;
    //   for (final MessageStatus status in event.statuses) {
    //     for (var chat in chats) {
    //       if (chat.chatId == status.dialogId) {
    //         for (var message in chat.messages) {
    //           if (message.messageId == status.messageId &&
    //           !message.statuses.contains(status)) {
    //             message.statuses.add(status);
    //           }
    //         }
    //       }
    //     }
    //   }
    //   final newState = state.copyWith(updatedChats: chats);
    //   emit(newState);
    // }
    //
    // onChatsBuilderUpdateLocalMessageEvent(
    //     ChatsBuilderUpdateLocalMessageEvent event, Emitter<MessagesBlocState> emit
    //     ){
    //   final messagesDictionary = state.messagesDictionary;
    //   // final chats = state.from();
    //   final chats = state.chats;
    //   for (var chat in chats) {
    //     if (chat.chatId == event.dialogId) {
    //       final message = chat.messages.firstWhere((element) => element.messageId == event.localMessageId);
    //       message.messageId = event.message.messageId;
    //       if (event.message.file != null) {
    //         message.file!.attachmentId = event.message.file!.attachmentId;
    //       }
    //       message.isError = false;
    //       message.isHandling = false;
    //       message.statuses.addAll(event.message.statuses);
    //       messagesDictionary.remove("${event.localMessageId}");
    //       messagesDictionary["${event.message.messageId}"] = true;
    //     }
    //   }
    //   emit(state.copyWith(updatedChats: chats, updatedMessagesDictionary: messagesDictionary));
    // }
    //
    // Future<void> onChatsBuilderUpdateLocalMessageWithErrorEvent (
    //     ChatsBuilderUpdateMessageWithErrorEvent event, Emitter<MessagesBlocState> emit
    //     ) async {
    //   final chats = [...state.chats];
    //   for (var chat in chats) {
    //     if (chat.chatId == event.dialog) {
    //       for (var message in chat.messages) {
    //         if (message.messageId == event.messageId) {
    //           message.isError = true;
    //           message.isHandling = event.isHandling;
    //           break;
    //         }
    //       }
    //     }
    //   }
    //   emit(state.copyWith(
    //       updatedChats: chats));
    // }
    //
    // @override
    // Future<void> close() async {
    //   super.close();
    // }
    //
    // void onRefreshChatsBuilderEvent(
    //     RefreshChatsBuilderEvent event,
    //     Emitter<MessagesBlocState> emit
    //   ) {
    //   final newState = state.copyWith(updatedChats: [], updatedCounter: 0, isError: false);
    //   emit(newState);
    // }
    //
    // void onDeleteAllChatsEvent(
    //     DeleteAllChatsEvent event,
    //     Emitter<MessagesBlocState> emit
    //   ) {
    //   final newState = state.copyWith(updatedChats: [], updatedCounter: 0);
    //   emit(newState);
    // }
    //
    // void onChatsBuilderDeleteLocalMessageEvent(
    //     ChatsBuilderDeleteLocalMessageEvent event,
    //     Emitter<MessagesBlocState> emit
    //     ) {
    //   final newState = [...state.chats];
    //   final ChatsData chat = newState.firstWhere((el) => el.chatId == event.dialogId);
    //   chat.messages.removeWhere((message) => message.messageId == event.messageId);
    //   emit(state.copyWith(updatedChats: newState, updatedMessagesDictionary: state.messagesDictionary));
    // }
    //
    // void onChatsBuilderDeleteMessagesEvent(
    //     ChatsBuilderDeleteMessagesEvent event,
    //     Emitter<MessagesBlocState> emit
    //     ) {
    //   print("delete result ${event.messagesId}");
    //   final messagesToDelete = [];
    //   final newState = [...state.chats];
    //   final dialog = newState.firstWhere((d) => d.chatId == event.dialogId);
    //   for (var messageId in event.messagesId) {
    //     for (var message in dialog.messages) {
    //       if (message.messageId == messageId) {
    //         state.messagesDictionary[messageId.toString()] = false;
    //         messagesToDelete.add(message);
    //       }
    //     }
    //   }
    //   if (messagesToDelete.isNotEmpty)  {
    //     messagesToDelete.forEach((m) {
    //       dialog.messages.remove(m);
    //     });
    //     emit(state.copyWith(updatedChats: newState, updatedMessagesDictionary: state.messagesDictionary));
    //   }
    // }
  }

}

