import 'package:chat/models/dialog_model.dart';
import 'package:equatable/equatable.dart';
import '../../models/contact_model.dart';



class DialogsState {
  final List<DialogData>? dialogs;
  final String searchQuery;

  bool get isSearchMode => searchQuery.isNotEmpty;

  const DialogsState.initial()
      : dialogs = null,
        searchQuery = "";

  DialogsState({
    required this.dialogs,
    required this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogsState &&
              runtimeType == other.runtimeType &&
              dialogs == other.dialogs &&
              searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      dialogs.hashCode ^
      searchQuery.hashCode;

  DialogsState copyWith({
    List<DialogData>? dialogs,
    String? searchQuery,
  }) {
    return DialogsState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}