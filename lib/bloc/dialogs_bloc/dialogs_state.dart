import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import '../../services/helpers/equality_helper.dart';

class DialogsState {
  final List<DialogData>? dialogs;
  final String searchQuery;
  final bool isErrorHappened;
  final AppErrorExceptionType? errorType;

  bool get isSearchMode => searchQuery.isNotEmpty;

  const DialogsState.initial()
      : dialogs = null,
        searchQuery = "",
        isErrorHappened = false,
        errorType = null;

  DialogsState({
    required this.dialogs,
    required this.searchQuery,
    required this.isErrorHappened,
    required this.errorType
  });

  @override
  bool operator ==(Object other) =>
          other is DialogsState &&
              runtimeType == other.runtimeType &&
              dialogs == other.dialogs &&
              searchQuery == other.searchQuery &&
              errorType == other.errorType &&
              isErrorHappened == other.isErrorHappened;

  @override
  int get hashCode =>
      dialogs.hashCode ^
      searchQuery.hashCode ^
      errorType.hashCode ^
      isErrorHappened.hashCode;

  DialogsState copyWith({
    List<DialogData>? dialogs,
    String? searchQuery,
    bool? isErrorHappened,
    AppErrorExceptionType? errorType
  }) {
    return DialogsState(
      dialogs:
      dialogs ?? this.dialogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isErrorHappened: isErrorHappened ?? this.isErrorHappened,
      errorType: errorType ?? this.errorType
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
          createdAt: dialog.createdAt,
          picture: dialog.picture
        );
        dialogs.add(d);
      }
    }
    return DialogsState(
      dialogs: dialogs,
      searchQuery: searchQuery,
      isErrorHappened: isErrorHappened,
      errorType: errorType
    );
  }
}