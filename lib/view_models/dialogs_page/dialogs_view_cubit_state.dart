import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import '../../services/helpers/equality_helper.dart';


class DialogsViewCubitState{}

class DialogsLoadedViewCubitState extends DialogsViewCubitState {
  final List<DialogData> dialogs;
  final String searchQuery;
  final bool isError;
  final bool isAuthenticated;
  final AppErrorExceptionType? errorType;

  DialogsLoadedViewCubitState({
    required this.dialogs,
    required this.searchQuery,
    required this.isError,
    required this.isAuthenticated,
    required this.errorType
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogsLoadedViewCubitState &&
              runtimeType == other.runtimeType &&
              true == false &&
              compareDialogDataLists(dialogs, other.dialogs) &&
              searchQuery == other.searchQuery &&
              errorType == other.errorType &&
              isAuthenticated == other.isAuthenticated &&
              isError == other.isError;

  @override
  int get hashCode => dialogs.hashCode ^ dialogs.length.hashCode ^ searchQuery.hashCode ^ isError.hashCode ^ isAuthenticated.hashCode ^ errorType.hashCode;

  DialogsLoadedViewCubitState copyWith({
    List<DialogData>? dialogs,
    String? searchQuery,
    bool? isError,
    bool? isAuthenticated,
    AppErrorExceptionType? errorType
  }) {
    return DialogsLoadedViewCubitState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isError: isError ?? this.isError,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorType: errorType ?? this.errorType
    );
  }
}

class DialogsLoadingViewCubitState extends DialogsViewCubitState{}
