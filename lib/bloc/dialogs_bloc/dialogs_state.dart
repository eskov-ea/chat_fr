import 'package:chat/models/dialog_model.dart';

class DialogsState {
  final List<DialogData>? dialogs;
  final String searchQuery;
  final bool isErrorHappened;

  bool get isSearchMode => searchQuery.isNotEmpty;

  const DialogsState.initial()
      : dialogs = null,
        searchQuery = "",
        isErrorHappened = false;

  DialogsState({
    required this.dialogs,
    required this.searchQuery,
    required this.isErrorHappened
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogsState &&
              runtimeType == other.runtimeType &&
              dialogs == other.dialogs &&
              searchQuery == other.searchQuery &&
              isErrorHappened == other.isErrorHappened;

  @override
  int get hashCode =>
      dialogs.hashCode ^
      searchQuery.hashCode ^
      isErrorHappened.hashCode;

  DialogsState copyWith({
    List<DialogData>? dialogs,
    String? searchQuery,
    bool? isErrorHappened
  }) {
    return DialogsState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isErrorHappened: isErrorHappened ?? this.isErrorHappened
    );
  }
}