import 'dart:async';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_view_cubit_state.dart';

class ChatBuilderScreenViewCubit extends Cubit<ChatScreenViewCubitState> {
  final ChatsBuilderBloc chatsBuilderBloc;
  late final StreamSubscription<ChatsBuilderState> messagesBlocSubscription;

  ChatBuilderScreenViewCubit({
    required ChatScreenViewCubitState initialState,
    required this.chatsBuilderBloc
  }) : super(initialState) {
    Future.microtask(() {
      _onState(chatsBuilderBloc.state);
      messagesBlocSubscription = chatsBuilderBloc.stream.listen(_onState);
    });
  }

  void _onState(ChatsBuilderState state) {
    if (state is ChatsBuilderInProgressState) {
      emit(ChatScreenViewCubitInProgressState());
      return;
    }
    emit(ChatScreenViewCubitSuccessState(chats: state.chats));
  }

  void refreshAllChats() {
    chatsBuilderBloc.add(RefreshChatsBuilderEvent());
  }

  @override
  Future<void> close() {
    messagesBlocSubscription.cancel();
    return super.close();
  }

}
