import 'dart:async';

import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/user_profile/user_profile_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';


class ProfileBloc extends Bloc<ProfileBlocEvent, UserProfileState> {
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final _secureStorage = DataProvider.storage;
  final ErrorHandlerBloc errorHandlerBloc;
  final DBProvider _db = DBProvider.db;
  final DatabaseBloc databaseBloc;
  late final StreamSubscription<DatabaseBlocState> _databaseDialogEventSubscription;

  ProfileBloc({
    required this.errorHandlerBloc,
    required this.databaseBloc,
  }): super( UserProfileInitialState(profile: null)) {
    _databaseDialogEventSubscription = databaseBloc.stream.listen((event) {
      if (event is DatabaseBlocDBInitializedState) {
        add(ProfileBlocLoadedEvent(profile: event.profile));
      }
    });

    on<ProfileBlocEvent>((event, emit) async {
      if (event is ProfileBlocLoadingEvent) {
        await onProfileBlocLoadingEvent(event, emit);
      } else if (event is ProfileBlocLoadedEvent) {
        emit(UserProfileLoadedState(profile: event.profile));
      }  else if (event is ProfileBlocUpdateEvent) {
        try {
          await _db.saveUserProfile(event.profile);
        } on DatabaseException catch(err) {
          errorHandlerBloc.add(ErrorHandlerWithErrorEvent(error: AppErrorException(AppErrorExceptionType.db, message: err.toString())));
        }
        emit(UserProfileLoadedState(profile: event.profile));
      } else if (event is ProfileBlocLogoutEvent) {
        await onProfileBlocChangeProfileEvent(event, emit);
      }
    });
  }



  Future<void> onProfileBlocLoadingEvent (event, emit) async {
    final String? token = await _secureStorage.getToken();
    try {

      final userProfile = await _db.getProfile();
      final newState = UserProfileLoadedState(profile: userProfile);
      emit(newState);
    } catch (err) {
      if(err is AppErrorException && err.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
      } else {
        emit(UserProfileErrorState());
      }
    }
  }



  Future<void> onProfileBlocChangeProfileEvent (event, emit) async {
    emit(UserProfileLoggedOutState());
  }
}