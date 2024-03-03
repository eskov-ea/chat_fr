import 'dart:async';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_view_cubit_state.dart';

class ChatBuilderScreenViewCubit extends Cubit<ChatScreenViewCubitState> {
  final MessageBloc chatsBuilderBloc;
  late final StreamSubscription<MessagesBlocState> messagesBlocSubscription;

  ChatBuilderScreenViewCubit({
    required ChatScreenViewCubitState initialState,
    required this.chatsBuilderBloc
  }) : super(initialState) {
      _onState(chatsBuilderBloc.state);
      messagesBlocSubscription = chatsBuilderBloc.stream.listen(_onState);
  }

  void _onState(MessagesBlocState state) {
    // if (state is ChatsBuilderInProgressState) {
    //   emit(ChatScreenViewCubitInProgressState());
    //   return;
    // }
    // emit(ChatScreenViewCubitSuccessState(chats: state.chats));
  }

  void refreshAllChats() {
    // chatsBuilderBloc.add(RefreshChatsBuilderEvent());
  }

  void deleteMessagesCubitEvent(List<int> messagesId) {
    print("Messages to be deleted ${messagesId}");
  }

  @override
  Future<void> close() {
    messagesBlocSubscription.cancel();
    return super.close();
  }

}
