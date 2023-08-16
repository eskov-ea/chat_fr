import 'dart:io';
import 'package:chat/bloc/auth_bloc/auth_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_bloc.dart';
import 'package:chat/bloc/call_logs_bloc/call_logs_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/messages/messages_repository.dart';
import 'package:chat/services/users/users_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'package:chat/view_models/auth/auth_view_state.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit_state.dart';
import 'package:chat/view_models/loader/loader_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/websocket/websocket_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/calls_bloc/calls_bloc.dart';
import 'bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'bloc/chats_builder_bloc/chats_builder_event.dart';
import 'bloc/dialogs_bloc/dialogs_bloc.dart';
import 'bloc/dialogs_bloc/dialogs_state.dart';
import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'bloc/ws_bloc/ws_state.dart';
import 'services/auth/auth_repo.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // add your localhost detection logic here if you want
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  static final mainNavigation = MainNavigation();

  @override
  Widget build(BuildContext context) {
    final websocketBloc =  WsBloc(
      initialState: Unconnected(),
      dialogsRepository: DialogRepository(),
      secureStorage: DataProvider()
    );
    final errorHandlerBloc =  ErrorHandlerBloc();
    final authBloc = AuthBloc(authRepo: AuthRepository());
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => websocketBloc
        ),
        BlocProvider(
            create: (_) => AuthViewCubit(authBloc: authBloc, initialState: AuthViewCubitFormFillInProgressState())
        ),
        BlocProvider(
            create: (_) => LoaderViewCubit(authBloc: authBloc, initialState: LoaderViewCubitState.unknown)
        ),
        BlocProvider(
            lazy: false,
            create: (context) => ChatsBuilderBloc(
              errorHandlerBloc: errorHandlerBloc,
              messagesRepository: MessagesRepository(),
              webSocketBloc: websocketBloc,
              dataProvider: DataProvider()
            )
        ),
        BlocProvider(
          create: (_) => UsersViewCubit(
            wsBloc: websocketBloc,
            usersBloc: UsersBloc(
              errorHandlerBloc: errorHandlerBloc,
              usersRepository: UsersRepository()
            )
          )
        ),
        BlocProvider(
            create: (context) => DialogsViewCubit(
                dialogsBloc: DialogsBloc(
                    webSocketBloc: websocketBloc,
                    dialogRepository: DialogRepository(),
                    errorHandlerBloc: errorHandlerBloc,
                    initialState: const DialogsState.initial()
                ),
                initialState: DialogsLoadingViewCubitState(
                ))),
        BlocProvider(
          create: (_) => WebsocketViewCubit(
              wsBloc: websocketBloc,
              initialState: WebsocketViewCubitState.unknown
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
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


