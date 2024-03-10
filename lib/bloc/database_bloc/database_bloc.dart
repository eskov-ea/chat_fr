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
    websocketEventSubscription = websocketRepository.events.listen(_onWebsocketEvent);
    on<DatabaseBlocEvent>((event, emit) async {
      if (event is DatabaseBlocInitializeEvent) {
        await onDatabaseBlocInitializeEvent(event, emit);
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
      if (state is DatabaseBlocDBInitializedState) {
        add(DatabaseBlocNewDialogReceivedEvent(dialog: payload.data?["dialog"]));
      }
    }
  }

  Future<bool> onDatabaseBlocCheckAuthTokenEvent(
      DatabaseBlocCheckAuthTokenEvent event,
      emit
  ) async {
    final token = await db.getToken();
    return token != null;
  }

  Future<void> onDatabaseBlocInitializeEvent(event, emit) async {
    try {
      final DateTime start = DateTime.now();
      await db.database;
      await db.initDB();
      final bool isDatabaseEmpty = await db.checkIfDatabaseIsEmpty();
      if (isDatabaseEmpty) {
        print('Initialize from server');
        final token = await _storage.getToken();
        await db.initializeChatTypeValues();

        emit(DatabaseBlocLoadingUsersState());
        final profile = await UserProfileProvider().getUserProfile(token);
        await DataProvider.storage.setUserId(profile.id);
        print('Set user id:  ${profile.id}');
        final users = await UsersProvider().getUsers(token);
        users.add(UserModel(id: profile.id, firstname: profile.firstname, lastname: profile.lastname,
            middlename: profile.middlename, company: profile.company, position: profile.position, phone: profile.phone,
            dept: profile.dept, email: profile.email, birthdate: profile.birthdate, avatar: profile.avatar, banned: 0,
            lastAccess: null));
        await db.saveUsers(users);
        emit(DatabaseBlocLoadingDialogsState());

        final dialogs = await DialogsProvider().getDialogs();

        final chatUsers = <ChatUser>[];
        final dialogsLastMessages = <MessageData>[];
        final statuses = <MessageStatus>[];
        final files = <MessageAttachmentData>[];

        for(var dialog in dialogs) {
          for (var chatUser in dialog.chatUsers!) {
            chatUsers.add(ChatUser(chatId: dialog.dialogId, userId: chatUser.userId, chatUserRole: chatUser.chatUserRole, active: chatUser.active, id: chatUser.id, user: chatUser.user));
          }
          if (dialog.lastMessage != null) {
            dialogsLastMessages.add(dialog.lastMessage!);
            for(var status in dialog.lastMessage!.statuses) {
              statuses.add(status);
            }
          }
          if (dialog.lastMessage?.file != null) {
            files.add(dialog.lastMessage!.file!);
          }
        }
        print('Dialogs lm::: $chatUsers');
        await db.saveMessages(dialogsLastMessages);
        await db.saveAttachments(files);
        await db.saveMessageStatuses(statuses);
        await db.saveChatUsers(chatUsers);
        await db.saveDialogs(dialogs);
        emit(DatabaseBlocLoadingCallsState());
        await Future.delayed(const Duration(seconds: 2));
        final calls = <CallModel>[];

        await db.updateAppSettingsTable(dbInitialized: 1);
      }


      print('Initialize from db');

      emit(DatabaseBlocLoadingUsersState());
      final users = await db.getUsers();
      final messages = await db.getMessages();
      emit(DatabaseBlocLoadingDialogsState());
      final chatUsers = await db.getChatUsers();
      final dbDialogs = await db.getDialogs();
      print('dbDialogs $dbDialogs');
      List<DialogData> dialogs = [];
      print('init dialogs:  ${messages[6548]}');
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
      emit(DatabaseBlocLoadingCallsState());
      await Future.delayed(const Duration(seconds: 2));
      final calls = <CallModel>[];

      final DateTime finish = DateTime.now();
      final time = (finish.millisecondsSinceEpoch - start.millisecondsSinceEpoch);
      print('Job longitite:: $time');
      emit(DatabaseBlocDBInitializedState(
          users: users,
          dialogs: dialogs,
          calls: calls
      ));

    } on Exception catch(err, stackTrace) {
      log('DB error:  $err \r\n  $stackTrace');
      emit(DatabaseBlocDBFailedInitializeState());
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
    print('last update was:: $lastUpdate   diff: $diff');
  }

  Future<void> onDatabaseBlocSendMessageEvent(DatabaseBlocSendMessageEvent event, emit) async {
    print("DBBloc send:: start");
    try {
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


      final sentMessageBody = await MessagesRepository().sendMessage(dialogId: event.dialogId,
          messageText: event.messageText, parentMessageId: event.parentMessage?.parentMessageId,
          filetype: event.filetype, bytes: event.bytes, filename: event.filename, content: event.content);
      final sentMessage = MessageData.fromJson(jsonDecode(sentMessageBody)["data"]);

      await db.saveMessageStatuses(sentMessage.statuses);
      // final updateRes = await db.updateMessageId(messageId, sentMessage.messageId);
      // print('update result  $updateRes');
    } catch (err, stackTrace) {
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
    await db.saveDialogs([event.dialog]);
    if (event.dialog.lastMessage != null) await db.saveMessages([event.dialog.lastMessage!]);
    if (event.dialog.lastMessage?.statuses != null) await db.saveMessageStatuses(event.dialog.lastMessage!.statuses);
    if (event.dialog.lastMessage?.file != null) await db.saveAttachments([event.dialog.lastMessage!.file!]);

    emit(DatabaseBlocNewDialogReceivedState(dialog: event.dialog));
  }

  Future<void> onDatabaseBlocNewMessageStatusEvent(
      DatabaseBlocNewMessageStatusEvent event,
      emit
  ) async {
    await db.saveMessageStatus(event.status);
    emit(DatabaseBlocUpdateMessageStatusesState(statuses: [event.status]));
  }
}