import 'dart:async';
import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/dialogs_bloc/dialogs_event.dart';
import 'dialogs_view_cubit_state.dart';

class DialogsViewCubit extends Cubit<DialogsViewCubitState> {
  final DialogsBloc dialogsBloc;
  late final StreamSubscription<DialogsState> dialogBlocSubscription;

  DialogsViewCubit({
    required DialogsViewCubitState initialState,
    required this.dialogsBloc
  }) : super(initialState) {
    Future.microtask(() {
      _onState(dialogsBloc.state);
      dialogBlocSubscription = dialogsBloc.stream.listen(_onState);
    });
  }

  void _onState(DialogsState state) {
    final isError = state.isErrorHappened;
    if (!state.isFirstInitialized) return;
    final newState = DialogsLoadedViewCubitState(dialogs: state.dialogs, searchQuery: "", isError: isError,
        errorType: state.errorType, isAuthenticated: state.isAuthenticated, isFirstInitialized: state.isFirstInitialized);
    emit(newState);
  }

  void loadDialogs() {
    emit(DialogsLoadingViewCubitState());
    dialogsBloc.add(DialogsLoadEvent());
  }

  void updateLastDialogMessage(message){
    dialogsBloc.add(
        UpdateDialogLastMessageEvent(message: message)
    );
  }

  void refreshAllDialogs(){
    emit(DialogsLoadingViewCubitState());
    dialogsBloc.add(RefreshDialogsEvent());
  }

  void deleteAllDialogs(){
    dialogsBloc.add(DeleteDialogsOnLogoutEvent());
  }

  void getPublicDialogs() {

  }

  void search(String searchQuery) {
    dialogsBloc.add(DialogsSearchDialogEvent(searchQuery));
  }

  void joinDialog(user, dialogId) {
    dialogsBloc.add(DialogUserJoinChatEvent(user: user, dialogId: dialogId ));
  }

  @override
  Future<void> close() {
    dialogBlocSubscription.cancel();
    return super.close();
  }

}