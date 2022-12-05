import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/user_profile/user_profile_repository.dart';
import '../../storage/data_storage.dart';

class ProfileBloc extends Bloc<ABlocEvent, UserProfileState> {
  late final UserProfileRepository _userProfileRepository;
  final _secureStorage = DataProvider();


  ProfileBloc(): super( UserProfileInitialState(user: null)){
    _userProfileRepository = UserProfileRepository();
    on<ABlocEvent>((event, emit) async {
      if (event is ProfileBlocLoadingEvent) {
        await onProfileBlocLoadingEvent(event, emit);
      } else if (event is ProfileBlocLoadedEvent) {
        await onProfileBlocLoadedEvent(event, emit);
      } else if (event is ProfileBlocChangeProfileEvent) {
        await onProfileBlocChangeProfileEvent(event, emit);
      }
    });
  }

  Future<void> onProfileBlocLoadingEvent (event, emit) async {
    final String? token = await _secureStorage.getToken();
    final userProfile = await _userProfileRepository.getUserProfile(token);
    final newState = UserProfileLoadedState(user: userProfile);
    emit(newState);
  }

  Future<void> onProfileBlocLoadedEvent (event, emit) async {

  }

  Future<void> onProfileBlocChangeProfileEvent (event, emit) async {


  }
}