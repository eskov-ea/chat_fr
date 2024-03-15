import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/message_model.dart' as messageModel;
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/ws/ws_repositor_interface.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/helpers/message_sender_helper.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';
import 'package:chat/services/users/users_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqlite_api.dart';


class DatabaseBloc extends Bloc<DatabaseBlocEvent, DatabaseBlocState> {
  final ErrorHandlerBloc errorHandlerBloc;
  final WebsocketRepository websocketRepository;
  final DBProvider db = DBProvider.db;
  final _storage = DataProvider.storage;
  late final StreamSubscription websocketEventSubscription;

  DatabaseBloc({
    required this.websocketRepository,
    required this.errorHandlerBloc
  }): super( DatabaseBlocDBNotInitializedState()){
    on<DatabaseBlocEvent>((event, emit) async {
      if (event is DatabaseBlocInitializeEvent) {
        await onDatabaseBlocInitializeEvent(event, emit);
        websocketEventSubscription = websocketRepository.events.listen(_onWebsocketEvent);
      } else if (event is DatabaseBlocSendMessageEvent) {
        await onDatabaseBlocSendMessageEvent(event, emit);
      } else if (event is DatabaseBlocNewMessageReceivedEvent) {
        await onDatabaseBlocNewMessageReceivedEvent(event, emit);
      } else if (event is DatabaseBlocNewDialogReceivedEvent) {
        await onDatabaseBlocNewDialogReceivedEvent(event, emit);
      } else if (event is DatabaseBlocNewMessageStatusEvent) {
        await onDatabaseBlocNewMessageStatusEvent(event, emit);
      } else if (event is DatabaseBlocNewMessageStatusEvent) {
        await onDatabaseBlocNewMessageStatusEvent(event, emit);
      } else if (event is DatabaseBlocGetUpdatesOnResume) {
        await onDatabaseBlocGetUpdatesOnResume(event, emit);
      } else if (event is DatabaseBlocCheckAuthTokenEvent) {
        await onDatabaseBlocCheckAuthTokenEvent(event, emit);
      } else if (event is DatabaseBlocResendMessageEvent) {
        await onDatabaseBlocResendMessageEvent(event, emit);
      } else if (event is DatabaseBlocDeleteMessagesEvent) {
        await onDatabaseBlocDeleteMessagesEvent(event, emit);
      } else if (event is DatabaseBlocUserExitChatEvent) {
        await onDatabaseBlocUserExitChatEvent(event, emit);
      } else if (event is DatabaseBlocUserJoinChatEvent) {
        await onDatabaseBlocUserJoinChatEvent(event, emit);
      }
    }, transformer: sequential());
  }

  void _onWebsocketEvent(WebsocketEventPayload payload) async {
    print('websocket event:::  ${payload.event} ${payload.data}');
    if (payload.event == WebsocketEvent.message) {
      add(DatabaseBlocNewMessageReceivedEvent(message: payload.data?["message"]));
    } else if (payload.event == WebsocketEvent.status) {
      add(DatabaseBlocNewMessageStatusEvent(status: payload.data?["status"]));
    } else if (payload.event == WebsocketEvent.dialog) {
        add(DatabaseBlocNewDialogReceivedEvent(dialog: payload.data?["dialog"]));
    } else if (payload.event == WebsocketEvent.exit) {
      add(DatabaseBlocUserExitChatEvent(chatUser: payload.data?["exit"]));
    } else if (payload.event == WebsocketEvent.join) {
      add(DatabaseBlocUserJoinChatEvent(chatUser: payload.data?["join"]));
    }
  }

  Future<bool> onDatabaseBlocCheckAuthTokenEvent(
      DatabaseBlocCheckAuthTokenEvent event,
      emit
  ) async {
    final token = await db.getToken();
    print('onDatabaseBlocCheckAuthTokenEvent  $token');
    return token != null;
  }

  Future<void> onDatabaseBlocInitializeEvent(event, emit) async {
    try {
      emit(DatabaseBlocInitializationInProgressState(
          message: 'Подключение к Базе Данных',
          progress: 0.05
      ));
      final DateTime start = DateTime.now();
      await db.database;
      await db.initDB();
      await db.initAppSettings();

      final appSettings = await db.getAppSettings();

      if (appSettings.firstInitialized != 1) {
        print('Initialize from server');
        final token = await _storage.getToken();
        await db.initializeChatTypeValues();


        /// Load and save profile
        emit(DatabaseBlocInitializationInProgressState(
          message: 'Синхронизируем данные с сервера',
          progress: 0.12
        ));
        if (appSettings.profileLoaded == 0) {
          final profile = await UserProfileProvider().getUserProfile(token);
          await db.saveUsers([profile.user]);
          await db.saveUserProfile(profile);
          await DataProvider.storage.setUserId(profile.user.id);
          await db.updateBooleanAppSettingByFieldAndValue('users_loaded', 1);
          await db.updateBooleanAppSettingByFieldAndValue('profile_loaded', 1);
        }


        /// Load and save users
        if (appSettings.usersLoaded == 0) {
          final users = await UsersProvider().getUsers(token);
          await db.saveUsers(users);
          await db.updateBooleanAppSettingByFieldAndValue('users_loaded', 1);
        }


        /// Load and save dialogs
        if (appSettings.dialogsLoaded == 0) {
          final dialogs = await DialogsProvider().getDialogs();
          print('Dialogs:::  $dialogs');

          final chatUsers = <ChatUser>[];
          final dialogsLastMessages = <MessageData>[];
          final statuses = <MessageStatus>[];
          final files = <MessageAttachmentData>[];

          for (var dialog in dialogs) {
            for (var chatUser in dialog.chatUsers!) {
              chatUsers.add(ChatUser(
                  chatId: dialog.dialogId,
                  userId: chatUser.userId,
                  chatUserRole: chatUser.chatUserRole,
                  active: chatUser.active,
                  id: chatUser.id,
                  user: chatUser.user));
            }
            if (dialog.lastMessage != null) {
              dialogsLastMessages.add(dialog.lastMessage!);
              for (var status in dialog.lastMessage!.statuses) {
                statuses.add(status);
              }
            }
            if (dialog.lastMessage?.file != null) {
              files.add(dialog.lastMessage!.file!);
            }
          }
          print('Dialogs lm::: $dialogsLastMessages');
          await db.saveMessages(dialogsLastMessages);
          await db.saveAttachments(files);
          await db.saveMessageStatuses(statuses);
          await db.saveChatUsers(chatUsers);
          await db.saveDialogs(dialogs);
          await db.updateBooleanAppSettingByFieldAndValue('dialogs_loaded', 1);
        }

        await db.updateAppSettingsTable(dbInitialized: 1);
      }


      print('Initialize from db');

      emit(DatabaseBlocInitializationInProgressState(
          message: 'Загружаем профиль',
          progress: 0.4
      ));
      final profile = await db.getProfile();

      emit(DatabaseBlocInitializationInProgressState(
          message: 'Загружаем пользователей',
          progress: 0.5
      ));
      final users = await db.getUsers();

      await db.updateMessagesThatFailedToBeSent();
      final messages = await db.getMessages();
      emit(DatabaseBlocInitializationInProgressState(
          message: 'Загружаем диалоги',
          progress: 0.6
      ));
      final chatUsers = await db.getChatUsers();
      final dbDialogs = await db.getDialogs();
      print('dbDialogs $dbDialogs');
      List<DialogData> dialogs = [];
      print('init dialogs:  ${messages[6855]}');
      for (var d in dbDialogs) {
        final dd = DialogData(
            dialogId: d.dialogId,
            chatType: d.chatType,
            dialogAuthorId: d.dialogAuthorId,
            users: d.users,
            name: d.name, description: d.description, messageCount: d.messageCount,
            lastMessage: d.lastMessage?.messageId != null ? messages[d.lastMessage!.messageId] : null,
            picture: d.picture, createdAt: d.createdAt, chatUsers: chatUsers[d.dialogId] ?? [],
            isPublic: d.isPublic, isClosed: d.isClosed, lastPage: d.lastPage
        );
        dialogs.add(dd);
      }
      websocketRepository.connect(dialogs);
      emit(DatabaseBlocInitializationInProgressState(
          message: 'Загружаем историю звонков',
          progress: 0.85
      ));
      await Future.delayed(const Duration(milliseconds: 200));
      final calls = <CallModel>[];

      emit(DatabaseBlocDBInitializedState(
          users: users,
          profile: profile,
          dialogs: dialogs,
          calls: calls
      ));

    } on AppErrorException catch (exception) {
      emit(DatabaseBlocDBFailedInitializeState(exception: exception));
    } on DatabaseException catch (err, stacktrace) {
      print('DatabaseException::  $err');
      emit(DatabaseBlocDBFailedInitializeState(exception: AppErrorException(AppErrorExceptionType.db)));
    } catch (err, stackTrace) {
      emit(DatabaseBlocDBFailedInitializeState(exception: AppErrorException(AppErrorExceptionType.other)));
    }
  }

  Future<void> onDatabaseBlocGetUpdatesOnResume(
      DatabaseBlocGetUpdatesOnResume event,
      emit
  ) async {
    final lastUpdate = await db.getLastUpdateTime();

    final now = DateTime.now();
    final tRawDifference = (now.millisecondsSinceEpoch - DateTime.parse(lastUpdate).millisecondsSinceEpoch) / 1000;
    final diff = tRawDifference.ceil();
    print('onDatabaseBlocGetUpdatesOnResume:: time: $diff, last update: $lastUpdate');
    if (diff < 30) return;
    final updates = await MessagesRepository().getNewUpdatesOnResume(diff);
    final List<DialogData> dialogs = updates!["chats"].map((json) => DialogData.fromJson(json)).whereType<DialogData>().toList();
    final List<ChatUser> dialogUsers = updates["chat_users"].map((json) => ChatUser.fromJson(json)).whereType<ChatUser>().toList();
    final List<MessageStatus> statuses = updates["chat_message_status_users"].map((json) => MessageStatus.fromJson(json)).whereType<MessageStatus>().toList();
    final List<MessageData> messages = updates["chat_messages"].map((json) => MessageData.fromJson(json)).whereType<MessageData>().toList();

    print('onDatabaseBlocGetUpdatesOnResume:: dialogs ${dialogs.length}: $dialogs, messages: $messages');
    if (dialogUsers.isNotEmpty) {
      await db.saveChatUsers(dialogUsers);
    }
    if (statuses.isNotEmpty) {
      await db.saveMessageStatuses(statuses);
    }
    if (messages.isNotEmpty) {
      await db.saveMessages(messages);
      emit(DatabaseBlocNewMessagesOnUpdateReceivedState(messages: messages));
    }
    if (dialogs.isNotEmpty) {
      await db.saveDialogs(dialogs);
      emit(DatabaseBlocNewDialogsOnUpdateState(dialogs: dialogs));
    }


    await db.setLastUpdateTime();
    print('last update was:: $lastUpdate   diff: $diff');
  }

  Future<void> onDatabaseBlocSendMessageEvent(DatabaseBlocSendMessageEvent event, emit) async {
    print("DBBloc send:: start");

    final userId = await DataProvider.storage.getUserId();
    if (userId == null) throw AppErrorException(AppErrorExceptionType.other);
    int messageId = UUID();
    while(await db.checkIfMessageExistWithThisId(messageId) == 0) {
      messageId = UUID();
    }
    final attachmentId = event.content == null ? null : UUID();

    final message = createLocalMessage(
        messageId: messageId,
        attachmentId: attachmentId,
        userId: userId,
        dialogId: event.dialogId,
        messageText: event.messageText,
        filename: event.filename,
        filetype: event.filetype,
        content: event.content,
        parentMessage: event.parentMessage
    );
    emit(DatabaseBlocNewMessageReceivedState(message: message));

    await db.saveLocalMessage(message);
    await db.saveLocalMessageStatus(message.statuses.isEmpty ? null : message.statuses.first);
    log('DBBloc send:: message: $message\r\n${message.statuses}');

    try {
      final sentMessageBody = await MessagesRepository().sendMessage(dialogId: event.dialogId,
          messageText: event.messageText, parentMessageId: event.parentMessage?.parentMessageId,
          filetype: event.filetype, bytes: event.bytes, filename: event.filename, content: event.content);
      final sentMessage = MessageData.fromJson(jsonDecode(sentMessageBody)["data"]);

      await db.saveMessageStatuses(sentMessage.statuses);
      // final updateRes = await db.updateMessageId(messageId, sentMessage.messageId);
      // print('update result  $updateRes');
    } catch (err, stackTrace) {
      db.updateMessageWithSendFailed(messageId);
      emit(DatabaseBlocFailedSendMessageState(localMessageId: messageId, dialogId: event.dialogId));
      log('DBBloc send:: error: $err\r\n$stackTrace');
    }
  }

  List<MessageData> updateLocalMessage(List<MessageData> messages, int localMessageId, MessageData sentMessage) {
    final range = messages.length > 10 ? 10 : messages.length;
    for (var i = 0; i < range; i++ ) {
      final message = messages[i];
      if (message.messageId == localMessageId) {
        messages.removeAt(i);
        messages.insert(i, sentMessage);
        return messages;
      }
    }
    return messages;
  }

  Future<void> onDatabaseBlocNewMessageReceivedEvent(
      DatabaseBlocNewMessageReceivedEvent event,
      emit
  ) async {
    print('UPDATMESSAGE:: start');

    final userId = await _storage.getUserId();
    if (userId != null && userId == event.message.senderId) {
      final updated = await db.updateLocalMessageByContent(
          event.message.messageId, event.message.message);
      print('UPDATMESSAGE:: $updated');
      if (updated != null) {
        await db.saveMessageStatuses(event.message.statuses);
        return emit(DatabaseBlocUpdateLocalMessageState(
            localId: updated[0],
            dialogId: event.message.dialogId,
            messageId: updated[1],
            statuses: event.message.statuses
        ));
      }
    }
    print('UPDATMESSAGE:: no way');

    await db.saveMessageStatuses(event.message.statuses);
    if (event.message.file != null) await db.saveAttachments([event.message.file!]);
    await db.saveMessages([event.message]);
    await db.updateDialogLastMessage(event.message);
    emit(DatabaseBlocNewMessageReceivedState(message: event.message));
  }

  Future<void> onDatabaseBlocNewDialogReceivedEvent(
      DatabaseBlocNewDialogReceivedEvent event,
      emit
  ) async {
    print('new dialog received::  ${event.dialog}');
    await db.saveDialogs([event.dialog]);
    if (event.dialog.lastMessage != null) await db.saveMessages([event.dialog.lastMessage!]);
    if (event.dialog.lastMessage?.statuses != null) await db.saveMessageStatuses(event.dialog.lastMessage!.statuses);
    if (event.dialog.lastMessage?.file != null) await db.saveAttachments([event.dialog.lastMessage!.file!]);
    await db.saveChatUsers(event.dialog.chatUsers);
    print('new dialog received::  ${event.dialog.chatUsers}');

    emit(DatabaseBlocNewDialogReceivedState(dialog: event.dialog));
  }

  Future<void> onDatabaseBlocNewMessageStatusEvent(
      DatabaseBlocNewMessageStatusEvent event,
      emit
  ) async {
    await db.saveMessageStatus(event.status);
    emit(DatabaseBlocUpdateMessageStatusesState(statuses: [event.status]));
  }

  Future<void> onDatabaseBlocResendMessageEvent(
    DatabaseBlocResendMessageEvent event,
    emit
  ) async {
    final message = await db.getMessageById(event.localMessageId);
    if (message != null) {
      await db.updateMessageErrorStatusOnResend(event.localMessageId);
      emit(DatabaseBlocUpdateErrorStatusOnResendState(localMessageId: event.localMessageId, dialogId: event.dialogId));
      try {
        final bytes = message.file?.content == null ? null : base64Decode(message.file!.content!);
        final sentMessageBody = await MessagesRepository().sendMessage(dialogId: event.dialogId,
            messageText: message.message, parentMessageId:  message.repliedMessage?.parentMessageId,
            filetype: message.file?.filetype, bytes: bytes, filename:  message.file?.name, content:  message.file?.content);
        final sentMessage = MessageData.fromJson(jsonDecode(sentMessageBody)["data"]);

        await db.saveMessageStatuses(sentMessage.statuses);
      } catch (err, stackTrace) {
        db.updateMessageWithSendFailed(message.messageId);
        emit(DatabaseBlocFailedSendMessageState(localMessageId: message.messageId, dialogId: event.dialogId));
        log('DBBloc send:: error: $err\r\n$stackTrace');
      }
    }
    print('onDatabaseBlocResendMessageEvent:: $json');
  }

  Future<void> onDatabaseBlocDeleteMessagesEvent(
      DatabaseBlocDeleteMessagesEvent event,
      emit
  ) async {
    print('DatabaseBlocDeleteMessagesEvent  ${event.ids}');
    try {
      await MessagesProvider().deleteMessage(messageId: event.ids);
      await db.deleteMessages(event.ids);
      emit(DatabaseBlocDeletedMessagesState(ids: event.ids, dialogId: event.dialogId));
    } catch (err, stackTrace) {

    }
  }

  Future<void> onDatabaseBlocUserExitChatEvent(DatabaseBlocUserExitChatEvent event, emit) async {
    try {
      await db.deleteChatUser(event.chatUser);
      print('streamer:: exit');
      emit(DatabaseBlocUserExitChatState(chatUser: event.chatUser));
    } catch (err) {

    }
  }

  Future<void> onDatabaseBlocUserJoinChatEvent(DatabaseBlocUserJoinChatEvent event, emit) async {
    try {
      await db.addUserToChat(event.chatUser);
      print('streamer:: join');
      emit(DatabaseBlocUserJoinChatState(chatUser: event.chatUser));
    }
    catch (err) {
      print('Failed to save joined user:  $err');
    }
  }
}