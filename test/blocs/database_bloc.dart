import 'package:bloc_test/bloc_test.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/models/app_settings_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../mock_services/mock_database.dart';

void main() {
  group('DatabaseBloc tests', () async {



    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    final db = MockDBProvider();
    await db.database;


    final ErrorHandlerBloc errorHandlerBloc = ErrorHandlerBloc();
    final websocketRepository = WebsocketRepository.instance;


    blocTest<DatabaseBloc, DatabaseBlocState>(
        "Initialize all app data",
        build: () {
          return DatabaseBloc(
            websocketRepository: websocketRepository,
            errorHandlerBloc: errorHandlerBloc,
            db: db
          );
        },
        act: (bloc) => bloc.add(DatabaseBlocInitializeEvent()),
        wait: const Duration(seconds: 1),
        expect: () => [
          DatabaseBlocDBInitializedState(
              dialogs: [],
              users: {},
              calls: [],
              profile: UserProfileData(
                  user: UserModel,
                  sipSettings: sipSettings,
                  chatSettings: null
              )
          )
        ]
    );

  });
}