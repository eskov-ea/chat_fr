import 'dart:convert';
import 'dart:developer';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
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
      } else if (event is DatabaseBlocLoadUsersEvent) {
        await onDatabaseBlocLoadUsersEvent(event, emit);
      }
    });
  }

  Future<void> onDatabaseBlocInitializeEvent(event, emit) async {
    try {
      await db.database;
      await db.initDB();
      final bool isDatabaseNotEmpty = await db.checkIfDatabaseIsNotEmpty();
      if (isDatabaseNotEmpty) {
        emit(DatabaseBlocDBInitializedState());
      } else {
        add(DatabaseBlocLoadUsersEvent());
      }
    } on Exception catch(err, stackTrace) {
      log('DB error:  $stackTrace');
      emit(DatabaseBlocDBFailedInitializeState());
    }
  }

  Future<void> onDatabaseBlocLoadUsersEvent(event, emit) async {
    try {
      final token = await _storage.getToken();

      final users = await UsersProvider().getUsers(token);
      await db.saveUsers(users);
      emit(DatabaseBlocLoadedUsersState());
      add(DatabaseBlocLoadDialogsEvent());
    } on Exception catch(err, stackTrace) {
      log('DB error:  $stackTrace');
      emit(DatabaseBlocDBFailedInitializeState());
    }
  }

  Future<void> onDatabaseBlocLoadDialogsEvent(event, emit) async {
    try {
      final dialogs = await DialogsProvider().getDialogs();
      await db.saveDialogs(dialogs);
      emit(DatabaseBlocDBInitializedState());
    } on Exception catch(err, stackTrace) {
      log('DB error:  $stackTrace');
      emit(DatabaseBlocDBFailedInitializeState());
    }
  }


}