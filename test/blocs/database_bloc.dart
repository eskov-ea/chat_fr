import 'package:bloc_test/bloc_test.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/services/user_profile/user_profile_repository.dart';
import 'package:chat/services/users/users_repository.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../mock_data/user_profile.dart';
import '../mock_services/database/mock_db_provider.dart';
import '../mock_services/user/user_provider.dart';
import '../mock_services/user_profile_provider/user_profile_provider.dart';


void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() async {

  sqfliteTestInit();

  test('DatabaseBloc tests', () async {
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
            storage: DataProvider.storage,
            profileRepository: UserProfileRepository(
              provider: MockUserProfileProvider()
            ),
            usersRepository: UsersRepository(
                provider: MockUserProvider()
            ),
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
              profile: userProfileMock
          )
        ]
    );

  });
}