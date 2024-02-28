import 'dart:convert';
import 'dart:developer';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/from_db_models.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/users/users_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DatabaseBloc extends Bloc<DatabaseBlocEvent, DatabaseBlocState> {
  final ErrorHandlerBloc errorHandlerBloc;
  final DBProvider db = DBProvider.db;
  final _storage = DataProvider();

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
      await db.database;
      await db.initDB();
      final bool isDatabaseNotEmpty = await db.checkIfDatabaseIsNotEmpty();
      if (false) {
        print('Initialize from db');

        emit(DatabaseBlocLoadingUsersState());
        final users = await db.getUsers();
        emit(DatabaseBlocLoadingDialogsState());
        await db.getChatUsers();
        final dbDialogs = await db.getDialogs();
        List<DialogData> dialogs = [];
        // for (var d in dbDialogs) {
        //   final dd = DialogData(dialogId: d.dialogId,
        //       chatType: DialogType(typeId: d.chatTypeId, typeName: d.chatTypeName, p2p: d.p2p, secure: d.secure, readonly: d.readonly, picture: d.chatTypePicture, name: d.chatTypeName, description: d.chatTypeDescription),
        //       userData: d.dialogAuthorId, usersList: d.usersList, name: d.name, description: d.description,
        //       lastMessage: d.lastMessageId, messageCount: d.messageCount, chatUsers: d.usersList,
        //       picture: d.picture, createdAt: DateTime.parse(d.createdAt)
        //   );
        // }
        emit(DatabaseBlocLoadingCallsState());
        await Future.delayed(const Duration(seconds: 2));
        final calls = <CallModel>[];

        emit(DatabaseBlocDBInitializedState(
            users: users,
            dialogs: dialogs,
            calls: calls
        ));

      } else {
        print('Initialize from server');
        final token = await _storage.getToken();
        await db.initializeChatTypeValues();

        emit(DatabaseBlocLoadingUsersState());
        final users = await UsersProvider().getUsers(token);
        await db.saveUsers(users);
        final dialogs = await DialogsProvider().getDialogs();
        final chatUsers = <ChatUserDB>[];
        final dialogsLastMessages = <MessageData>[];
        final statuses = <MessageStatus>[];
        for(var dialog in dialogs) {
          for (var chatUser in dialog.chatUsers) {
            chatUsers.add(ChatUserDB(chatId: dialog.dialogId, userId: chatUser.userId, chatUserRole: chatUser.chatUserRole, active: chatUser.active ? 1 : 0));
          }
          if (dialog.lastMessage != null) {
            dialogsLastMessages.add(dialog.lastMessage!);
            print('STATUSES::;:  $statuses');
            for(var status in dialog.lastMessage!.statuses) {
              statuses.add(status);
            }
          }
        }
        print('Dialogs lm::: $dialogsLastMessages');
        await db.saveMessages(dialogsLastMessages);
        await db.saveMessageStatuses(statuses);
        await db.saveChatUsers(chatUsers);
        await db.saveDialogs(dialogs);
        emit(DatabaseBlocLoadingCallsState());
        await Future.delayed(const Duration(seconds: 2));
        final calls = <CallModel>[];

        await db.updateAppSettingsTable(dbInitialized: 1);

        emit(DatabaseBlocDBInitializedState(
            users: users,
            dialogs: dialogs,
            calls: calls
        ));

      }
    } on Exception catch(err, stackTrace) {
      log('DB error:  $err \r\n  $stackTrace');
      emit(DatabaseBlocDBFailedInitializeState());
    }
  }


}