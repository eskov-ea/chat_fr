import 'dart:convert';
import 'dart:developer';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';
import 'package:chat/services/users/users_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DatabaseBloc extends Bloc<DatabaseBlocEvent, DatabaseBlocState> {
  final ErrorHandlerBloc errorHandlerBloc;
  final DBProvider db = DBProvider.db;
  final _storage = DataProvider.storage;

  DatabaseBloc({
    required this.errorHandlerBloc
  }): super( DatabaseBlocDBNotInitializedState()){
    on<DatabaseBlocEvent>((event, emit) async {
      if (event is DatabaseBlocInitializeEvent) {
        await onDatabaseBlocInitializeEvent(event, emit);
      }
    });
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
        print('init dialogs:  ${chatUsers}');
      for (var d in dbDialogs) {
        final dd = DialogData(
            dialogId: d.dialogId,
            chatType: d.chatType,
            dialogAuthorId: d.dialogAuthorId,
            users: d.users,
            name: d.name, description: d.description, messageCount: d.messageCount,
            lastMessage: d.lastMessage?.messageId != null ? messages[d.lastMessage!.messageId] : null,
            picture: d.picture, createdAt: d.createdAt, chatUsers: chatUsers[d.dialogId] ?? [],
            isPublic: d.isPublic, isClosed: d.isClosed
        );
        dialogs.add(dd);
      }
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


}