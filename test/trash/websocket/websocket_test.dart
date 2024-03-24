// import 'package:bloc_test/bloc_test.dart';
// import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
// import 'package:chat/bloc/ws_bloc/ws_event.dart';
// import 'package:chat/bloc/ws_bloc/ws_state.dart';
// import 'package:flutter_test/flutter_test.dart';
// import '../mock_secure_storage/secure_storage.dart';
// import '../mock_services/dialogs/mock_dialogs_repository.dart';
// import '../mock_services/messages/mock_message_repository.dart';
//
//
// void main() {
//   group('WebsocketBloc tests', () {
//
//     final MockDialogsRepository dialogsRepository = MockDialogsRepository();
//     final MockDataProvider secureStorage = MockDataProvider.storage;
//     final websocketBloc =  WsBloc(
//         initialState: Unconnected(),
//         dialogsRepository: dialogsRepository,
//         secureStorage: secureStorage
//     );
//
//     TestWidgetsFlutterBinding.ensureInitialized();
//
//     test('initial state is correct', () {
//       final websocketBloc =  WsBloc(
//         initialState: Unconnected(),
//         dialogsRepository: dialogsRepository,
//         secureStorage: secureStorage
//       );
//       expect(websocketBloc.state, Unconnected());
//     });
//
//     group('Connectivity tests', () {
//
//       /**
//        * These two test are quite fake and depends on the wait time.
//        * Because we do not have mock websocket implementation for tests we use the regular one.
//        * So we call [socket.connect()] and it emits the success connection earlier then connection error happens
//        */
//       blocTest<WsBloc, WsBlocState>(
//           "Connection test",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(InitializeSocketEvent()),
//           wait: const Duration(milliseconds: 1050),
//           expect: () => [
//             ConnectingState(),
//             Connected()
//           ]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "Reconnect functionality",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(WsEventReconnect()),
//           wait: const Duration(milliseconds: 1050),
//           expect: () => [
//             Unconnected(),
//             ConnectingState(),
//             Connected()
//           ]
//       );
//     });
//
//     group('Operational tests', () {
//
//
//       blocTest<WsBloc, WsBlocState>(
//           "New message received",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(WsEventReceiveNewMessage(message: newMessage)),
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateReceiveNewMessage(message: newMessage)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "The same message received multiple times",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) {
//             bloc.add(WsEventReceiveNewMessage(message: newMessage));
//             bloc.add(WsEventReceiveNewMessage(message: newMessage));
//           },
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateReceiveNewMessage(message: newMessage)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "A new user joins chat",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180)),
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateNewUserJoinDialog(profile: chatUser, dialogId: 180)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "The same user joins chat twice",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) {
//             bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180));
//             bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180));
//           },
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateNewUserJoinDialog(profile: chatUser, dialogId: 180)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "A user exits chat",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180)),
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateNewUserJoinDialog(profile: chatUser, dialogId: 180)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "The same user exits chat twice",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) {
//             bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180));
//             bloc.add(WsUserJoinChatEvent(profile: chatUser, dialogId: 180));
//           },
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateNewUserJoinDialog(profile: chatUser, dialogId: 180)],
//       );
//
//       // blocTest<WsBloc, WsBlocState>(
//       //     "A new dialog created",
//       //     build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//       //     act: (bloc) => bloc.add(WsEventNewDialogCreated(dialog: newReceivedDialog)),
//       //     wait: const Duration(seconds: 1),
//       //     expect: () => [WsStateNewDialogCreated(dialog: newReceivedDialog)]
//       // );
//
//       blocTest<WsBloc, WsBlocState>(
//           "A new user joins the app [online]",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) => bloc.add(WsOnlineUsersJoinEvent(userId: 40)),
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateOnlineUsersJoinState(userId: 40)]
//       );
//
//       blocTest<WsBloc, WsBlocState>(
//           "Server yielded twice that a user comes to [online] state",
//           build: () => WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage),
//           act: (bloc) {
//             bloc.add(WsOnlineUsersJoinEvent(userId: 40));
//             Future.delayed(const Duration(milliseconds: 500));
//             bloc.add(WsOnlineUsersJoinEvent(userId: 40));
//           },
//           wait: const Duration(seconds: 1),
//           expect: () => [WsStateOnlineUsersJoinState(userId: 40)]
//       );
//
//
//     });
//
//
//   });
// }