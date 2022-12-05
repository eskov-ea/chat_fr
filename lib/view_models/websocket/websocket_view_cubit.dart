import 'dart:async';
import 'package:chat/bloc/dialogs_bloc/dialogs_bloc.dart';
import 'package:chat/bloc/dialogs_bloc/dialogs_state.dart';
import 'package:chat/bloc/ws_bloc/ws_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/ws_bloc/ws_bloc.dart';
import '../../../../bloc/ws_bloc/ws_event.dart';



enum WebsocketViewCubitState { unknown, connected, unconnected, connecting }

class WebsocketViewCubit extends Cubit<WebsocketViewCubitState> {
  final WsBloc wsBloc;
  late final StreamSubscription<WsBlocState> wsBlocSubscription;

  WebsocketViewCubit({
    required WebsocketViewCubitState initialState,
    required this.wsBloc,
  }) : super(initialState) {
    Future.microtask(
          () {
        _onState(wsBloc.state);
        wsBlocSubscription = wsBloc.stream.listen(_onState);
      },
    );
  }


  void _onState(WsBlocState state) {
    print("WsBlocState $state");
    if (state is ConnectingState) {
      emit(WebsocketViewCubitState.connecting);
    } else if (state is Unconnected) {
      emit(WebsocketViewCubitState.unconnected);
    } else if (state is Connected) {
      emit(WebsocketViewCubitState.connected);
    }
  }

  @override
  Future<void> close() {
    wsBlocSubscription.cancel();
    return super.close();
  }
}