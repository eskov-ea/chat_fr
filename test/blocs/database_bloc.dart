import 'package:bloc_test/bloc_test.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/user_profile/user_profile_repository.dart';
import 'package:chat/services/users/users_repository.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../mock_data/user_profile.dart';
import '../mock_services/database/mock_db_provider.dart';
import '../mock_services/dialogs/dialog_provider.dart';
import '../mock_services/user/user_provider.dart';
import '../mock_services/user_profile_provider/user_profile_provider.dart';


void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() async {

  sqfliteTestInit();
  late final ErrorHandlerBloc errorHandlerBloc;
  late final WebsocketRepository websocketRepository;


  final MockDBProvider db = MockDBProvider();
  await db.database;

    blocTest<DatabaseBloc, DatabaseBlocState>(
        "Initialize all app data",
        setUp: () async {


          errorHandlerBloc = ErrorHandlerBloc();
          websocketRepository = WebsocketRepository.instance;
        },
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
            dialogsRepository: DialogsRepository(
              provider: MockDialogsProvider()
            ),
            db: db,
          );
        },
        act: (bloc) => bloc.add(DatabaseBlocInitializeEvent()),
        // wait: const Duration(seconds: 5),
        expect: () => [
          DatabaseBlocInitializationInProgressState(
              message: 'Подключение к Базе Данных',
              progress: 0.05
          ),
          DatabaseBlocInitializationInProgressState(
              message: 'Синхронизируем данные с сервера',
              progress: 0.12
          ),
          DatabaseBlocInitializationInProgressState(
              message: 'Загружаем профиль',
              progress: 0.4
          ),
          DatabaseBlocDBInitializedState(
              dialogs: [],
              users: {},
              calls: [],
              profile: userProfileMock
          )
        ]
    );
}