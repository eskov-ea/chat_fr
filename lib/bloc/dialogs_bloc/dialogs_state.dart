import 'package:chat/models/dialog_model.dart';

import '../../services/helpers/equality_helper.dart';

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
    return new DialogsState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isErrorHappened: isErrorHappened ?? this.isErrorHappened
    );
  }

  DialogsState from() {
    List<DialogData>? dialogs = [];
    if (this.dialogs == null) {
      dialogs = null;
    } else {
      for (var dialog in this.dialogs!) {
        final d = DialogData(
          dialogId: dialog.dialogId,
          chatType: dialog.chatType,
          userData: dialog.userData,
          usersList: [...dialog.usersList],
          name: dialog.name,
          description: dialog.description,
          lastMessage: LastMessageData.from(dialog.lastMessage),
          messageCount: dialog.messageCount,
          chatUsers: [...dialog.chatUsers],
          createdAt: dialog.createdAt
        );
        dialogs.add(d);
      }
    }
    return DialogsState(
      dialogs: dialogs,
      searchQuery: this.searchQuery,
      isErrorHappened: this.isErrorHappened
    );
  }
}