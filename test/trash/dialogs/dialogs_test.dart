// import 'package:bloc_test/bloc_test.dart';
// import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
// import 'package:chat/bloc/dialogs_bloc/dialogs_event.dart';
// import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
// import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
// import 'package:chat/bloc/ws_bloc/ws_bloc.dart';
// import 'package:chat/bloc/ws_bloc/ws_event.dart';
// import 'package:chat/bloc/ws_bloc/ws_state.dart';
// import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
// import 'package:chat/view_models/dialogs_page/dialogs_view_cubit_state.dart';
// import 'package:flutter_test/flutter_test.dart';
// import '../mock_secure_storage/secure_storage.dart';
// import '../mock_services/dialogs/mock_dialogs_repository.dart';
// import '../mock_services/messages/mock_message_repository.dart';
//
//
// void main() {
//   group('DialogBloc tests', () {
//
//     final MockDialogsRepository dialogsRepository = MockDialogsRepository();
//     final MockDataProvider secureStorage = MockDataProvider.storage;
//     final WsBloc webSocketBloc = WsBloc(initialState: Unconnected(), dialogsRepository: dialogsRepository, secureStorage: secureStorage);
//     final ErrorHandlerBloc errorHandlerBloc = ErrorHandlerBloc();
//     final DialogsBloc dialogsBloc = DialogsBloc(
//         initialState: const DialogsState.initial(),
//         webSocketBloc: webSocketBloc,
//         errorHandlerBloc: errorHandlerBloc,
//         dialogRepository: dialogsRepository
//     );
//
//
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//       "Load dialogs and emit",
//       build: () => DialogsViewCubit(
//         initialState: DialogsLoadingViewCubitState(),
//         dialogsBloc: dialogsBloc
//       ),
//       act: (cubit) => cubit.dialogsBloc.add(DialogsLoadEvent()),
//       wait: const Duration(seconds: 1),
//       expect: () => [
//         DialogsLoadedViewCubitState(
//           dialogs: dialogs,
//           searchQuery: "",
//           isError: false,
//         )
//       ]
//     );
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, receive new dialog twice",
//         build: () => DialogsViewCubit(
//             initialState: DialogsLoadingViewCubitState(),
//             dialogsBloc: dialogsBloc
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 2));
//           cubit.dialogsBloc.add(DialogBlocReceiveNewDialogEvent(dialog: newReceivedDialog));
//           await Future.delayed(const Duration(seconds: 1));
//           cubit.dialogsBloc.add(DialogBlocReceiveNewDialogEvent(dialog: newReceivedDialog));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: [...dialogs, newReceivedDialog],
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//     /**
//      * Twice [user join chat] caught and handled on Websocket bloc.
//      * So we can assume that there might not be two the same [user join chat] events on Dialog Bloc.
//      */
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, receive user join a dialog and emit",
//         build: () => DialogsViewCubit(
//           initialState: DialogsLoadingViewCubitState(),
//           dialogsBloc: DialogsBloc(
//               initialState: const DialogsState.initial(),
//               webSocketBloc: webSocketBloc,
//               errorHandlerBloc: errorHandlerBloc,
//               dialogRepository: dialogsRepository
//           )
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 2));
//           cubit.dialogsBloc.add(DialogUserJoinChatEvent(user: chatUser, dialogId: 180));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: dialogsWithNewUser,
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, receive new dialog emit",
//         build: () => DialogsViewCubit(
//             initialState: DialogsLoadingViewCubitState(),
//             dialogsBloc: dialogsBloc
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 2));
//           cubit.dialogsBloc.add(DialogBlocReceiveNewDialogEvent(dialog: newReceivedDialog));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: [...dialogs, newReceivedDialog],
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, receive user exit the dialog and emit",
//         build: () => DialogsViewCubit(
//             initialState: DialogsLoadingViewCubitState(),
//             dialogsBloc: DialogsBloc(
//                 initialState: const DialogsState.initial(),
//                 webSocketBloc: webSocketBloc,
//                 errorHandlerBloc: errorHandlerBloc,
//                 dialogRepository: dialogsRepository
//             )
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 2));
//           cubit.dialogsBloc.add(DialogUserExitChatEvent(user: chatUser, dialogId: 180));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: dialogsWithRemovedUser,
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, then update the dialog's last message and emit",
//         build: () => DialogsViewCubit(
//             initialState: DialogsLoadingViewCubitState(),
//             dialogsBloc: DialogsBloc(
//                 initialState: const DialogsState.initial(),
//                 webSocketBloc: webSocketBloc,
//                 errorHandlerBloc: errorHandlerBloc,
//                 dialogRepository: dialogsRepository
//             )
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 2));
//           cubit.dialogsBloc.add(UpdateDialogLastMessageEvent(message: newMessage));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: dialogsWithUpdatedLastMessage,
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//     blocTest<DialogsViewCubit, DialogsViewCubitState>(
//         "Load dialogs, then update the dialog's last message status only and emit",
//         build: () => DialogsViewCubit(
//             initialState: DialogsLoadingViewCubitState(),
//             dialogsBloc: DialogsBloc(
//                 initialState: const DialogsState.initial(),
//                 webSocketBloc: webSocketBloc,
//                 errorHandlerBloc: errorHandlerBloc,
//                 dialogRepository: dialogsRepository
//             )
//         ),
//         act: (cubit) async {
//           cubit.dialogsBloc.add(DialogsLoadEvent());
//           await Future.delayed(const Duration(seconds: 3));
//           cubit.dialogsBloc.webSocketBloc.add(WsEventUpdateStatus(statuses: newMessageStatuses));
//         },
//         expect: () => [
//           DialogsLoadedViewCubitState(
//             dialogs: dialogs,
//             searchQuery: "",
//             isError: false,
//           ),
//           DialogsLoadedViewCubitState(
//             dialogs: dialogsWithUpdatedMessageStatuses,
//             searchQuery: "",
//             isError: false,
//           )
//         ]
//     );
//
//
//   });
// }