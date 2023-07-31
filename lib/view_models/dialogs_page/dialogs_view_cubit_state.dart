import 'package:chat/models/dialog_model.dart';
import '../../services/helpers/equality_helper.dart';


class DialogsViewCubitState{}

class DialogsLoadedViewCubitState extends DialogsViewCubitState {
  final List<DialogData> dialogs;
  final String searchQuery;
  final bool isError;

  DialogsLoadedViewCubitState({
    required this.dialogs,
    required this.searchQuery,
    required this.isError
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogsLoadedViewCubitState &&
              runtimeType == other.runtimeType &&
              //TODO: implement deep equality functionality to compare lists of collections
              compareDialogDataLists(dialogs, other.dialogs) &&
              searchQuery == other.searchQuery &&
              isError == other.isError;

  @override
  int get hashCode => dialogs.hashCode ^ dialogs.length.hashCode ^ searchQuery.hashCode ^ isError.hashCode;

  DialogsLoadedViewCubitState copyWith({
    List<DialogData>? dialogs,
    String? searchQuery,
    bool? isError
  }) {
    return DialogsLoadedViewCubitState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isError: isError ?? this.isError
    );
  }
}

class DialogsLoadingViewCubitState extends DialogsViewCubitState{}
