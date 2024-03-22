import 'dart:io';
import 'package:chat/bloc/auth_bloc/auth_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_state.dart';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/group_dialog_members_streamer.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/user_bloc/online_users_manager.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/error_handling_service/error_handling_repository.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/services/users/users_repository.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'package:chat/view_models/auth/auth_view_state.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit_state.dart';
import 'package:chat/view_models/loader/loader_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'bloc/calls_bloc/calls_bloc.dart';
import 'bloc/dialogs_bloc/dialogs_bloc.dart';
import 'bloc/dialogs_bloc/dialogs_state.dart';
import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'firebase_options.dart';
import 'services/auth/auth_repo.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'services/sip_connection_service/sip_repository.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // add your localhost detection logic here if you want
  }
}

Future<void> configureCacheFolder() async {
  final Directory documentDirectory = await getApplicationDocumentsDirectory();
  final String dirPath = documentDirectory.path;
  final imageDir = "$dirPath/cache/media";

  if (!await Directory(imageDir).exists()) await Directory(imageDir).create(recursive: true);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  WebsocketRepository.instance;
  UserOnlineStatusManager.instance;
  ErrorHandlingRepository.instance;
  SipRepository.instance;
  GroupDialogsMemberStateStreamer.instance;
  await configureCacheFolder();

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  FlutterError.onError = (errorDetails) async {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);

      final userId = await DataProvider.storage.getUserId();
      FirebaseCrashlytics.instance.recordError(
          errorDetails.exception,
          errorDetails.stack,
          information: ["[ USER ID ]: $userId"]
      );
    }

  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    }
    return false;
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  static final mainNavigation = MainNavigation();

  @override
  Widget build(BuildContext context) {
    final db = DBProvider.db;
    final websocketRepo = WebsocketRepository.instance;
    final errorHandlerBloc =  ErrorHandlerBloc();
    final authBloc = AuthBloc(authRepo: AuthRepository());
    final databaseBloc = DatabaseBloc(
      websocketRepository: websocketRepo,
      errorHandlerBloc: errorHandlerBloc,
      db: db
    );
    //TODO: refactor bloc=to-bloc dependency with representation layer
    /// https://stackoverflow.com/questions/59137180/flutter-listen-bloc-state-from-other-bloc/72496719#72496719
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => databaseBloc,
        ),
        BlocProvider(
            create: (_) => AuthViewCubit(authBloc: authBloc, initialState: AuthViewCubitFormFillInProgressState())
        ),
        BlocProvider(
            create: (_) => LoaderViewCubit(authBloc: authBloc, initialState: LoaderViewCubitState.unknown)
        ),
        BlocProvider(
            lazy: false,
            create: (context) => MessageBloc(
              errorHandlerBloc: errorHandlerBloc,
              messagesRepository: MessagesRepository(),
              dataProvider: DataProvider.storage,
              databaseBloc: databaseBloc
            )
        ),
        BlocProvider(
          lazy: false,
          create: (_) => UsersViewCubit(
              databaseBloc: databaseBloc,
              wsRepo: websocketRepo,
              usersBloc: UsersBloc(
                  errorHandlerBloc: errorHandlerBloc,
                  usersRepository: UsersRepository()
              )
          )
        ),
        BlocProvider(
            lazy: false,
            create: (context) => DialogsViewCubit(
                dialogsBloc: DialogsBloc(
                    databaseBloc: databaseBloc,
                    dialogRepository: DialogRepository(),
                    errorHandlerBloc: errorHandlerBloc,
                    initialState: const DialogsState.initial()
                ),
            )
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            databaseBloc: databaseBloc,
            errorHandlerBloc: errorHandlerBloc,
          ),
        ),
        BlocProvider(
          create: (_) => CallsBloc(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => CallLogsBloc(initialState: CallLogInitialState(),
            errorHandlerBloc: errorHandlerBloc,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => errorHandlerBloc,
          lazy: false,
        ),
      ],
      child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.light,
          title: 'MCFEF',
          debugShowCheckedModeBanner: false,
          routes: mainNavigation.routes,
          initialRoute: MainNavigationRouteNames.loaderWidget,
          onGenerateRoute: mainNavigation.onGenerateRoute,
      )
    );
  }
}


