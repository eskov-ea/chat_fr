import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_profile/user_profile_repository.dart';
import '../../storage/data_storage.dart';
import '../error_handler_bloc/error_handler_bloc.dart';
import '../error_handler_bloc/error_handler_events.dart';
import '../error_handler_bloc/error_types.dart';


class ProfileBloc extends Bloc<ProfileBlocEvent, UserProfileState> {
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final ErrorHandlerBloc errorHandlerBloc;
  final _secureStorage = DataProvider();

  ProfileBloc({
    required this.errorHandlerBloc
  }): super( UserProfileInitialState(user: null)){
    on<ProfileBlocEvent>((event, emit) async {
      if (event is ProfileBlocLoadingEvent) {
        await onProfileBlocLoadingEvent(event, emit);
      } else if (event is ProfileBlocLoadedEvent) {
        await onProfileBlocLoadedEvent(event, emit);
      } else if (event is ProfileBlocLogoutEvent) {
        await onProfileBlocChangeProfileEvent(event, emit);
      }
    });
  }

  Future<void> onProfileBlocLoadingEvent (event, emit) async {
    final String? token = await _secureStorage.getToken();
    try {
      final userProfile = await _userProfileRepository.getUserProfile(token);
      final newState = UserProfileLoadedState(user: userProfile);
      emit(newState);
    } catch (err) {
      if(err is AppErrorException && err.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
      } else {
        emit(UserProfileErrorState());
      }
    }
  }

  Future<void> onProfileBlocLoadedEvent (event, emit) async {

  }

  Future<void> onProfileBlocChangeProfileEvent (event, emit) async {
    emit(UserProfileLoggedOutState());
  }
}