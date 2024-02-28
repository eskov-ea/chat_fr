import 'package:chat/bloc/dialogs_bloc/dialogs_list_container.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import '../../services/helpers/equality_helper.dart';

class DialogsState {
  final DialogsListContainer dialogsContainer;
  final DialogsListContainer searchedContainer;
  final String searchQuery;
  final bool isErrorHappened;
  final bool isAuthenticated;
  final bool isFirstInitialized;
  final AppErrorExceptionType? errorType;
  final bool isLoading;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<DialogData> get dialogs =>
      isSearchMode ? searchedContainer.dialogs : dialogsContainer.dialogs;

  const DialogsState.initial():
    dialogsContainer = const DialogsListContainer.initial(),
    searchedContainer = const DialogsListContainer.initial(),
    searchQuery = "",
    isErrorHappened = false,
    isAuthenticated = true,
    isFirstInitialized = false,
    isLoading = true,
    errorType = null;

  DialogsState({
    required this.dialogsContainer,
    required this.searchedContainer,
    required this.searchQuery,
    required this.isErrorHappened,
    required this.errorType,
    required this.isAuthenticated,
    required this.isFirstInitialized,
    required this.isLoading
  });

  @override
  bool operator ==(Object other) =>
          other is DialogsState &&
              runtimeType == other.runtimeType &&
              dialogsContainer == other.dialogsContainer &&
              searchQuery == other.searchQuery &&
              errorType == other.errorType &&
              isAuthenticated == other.isAuthenticated &&
              isFirstInitialized == other.isFirstInitialized &&
              isLoading == other.isLoading &&
              isErrorHappened == other.isErrorHappened;

  @override
  int get hashCode =>
      dialogsContainer.hashCode ^
      searchQuery.hashCode ^
      errorType.hashCode ^
      isAuthenticated.hashCode ^
      isFirstInitialized.hashCode ^
      isLoading.hashCode ^
      isErrorHappened.hashCode;

  DialogsState copyWith({
    DialogsListContainer? dialogsContainer,
    DialogsListContainer? searchedDialogs,
    String? searchQuery,
    bool? isErrorHappened,
    bool? isAuthenticated,
    bool? isFirstInitialized,
    bool? isLoading,
    AppErrorExceptionType? errorType
  }) {
    return DialogsState(
      dialogsContainer: dialogsContainer ?? this.dialogsContainer,
      searchedContainer: searchedDialogs ?? this.searchedContainer,
      isFirstInitialized: isFirstInitialized ?? this.isFirstInitialized,
      searchQuery: searchQuery ?? this.searchQuery,
      isErrorHappened: isErrorHappened ?? this.isErrorHappened,
      errorType: errorType ?? this.errorType,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading
    );
  }

  DialogsState from() {
    DialogsListContainer dialogsContainer;
    if (this.dialogsContainer.dialogs.isEmpty) {
      dialogsContainer = const DialogsListContainer.initial();
    } else {
      List<DialogData> dialogs =[];
      for (var dialog in this.dialogsContainer.dialogs) {
        final d = DialogData(
          dialogId: dialog.dialogId,
          chatType: dialog.chatType,
          userData: dialog.userData,
          usersList: [...dialog.usersList],
          name: dialog.name,
          description: dialog.description,
          lastMessage: dialog.lastMessage,
          // lastMessage: LastMessageData.from(dialog.lastMessage),
          messageCount: dialog.messageCount,
          chatUsers: [...dialog.chatUsers],
          createdAt: dialog.createdAt,
          picture: dialog.picture
        );
        dialogs.add(d);
      }
      dialogsContainer = DialogsListContainer(dialogs: dialogs);
    }
    return DialogsState(
      dialogsContainer: dialogsContainer,
      searchedContainer: searchedContainer,
      searchQuery: searchQuery,
      isErrorHappened: isErrorHappened,
      errorType: errorType,
      isAuthenticated: isAuthenticated,
      isFirstInitialized: isFirstInitialized,
      isLoading: isLoading
    );
  }

  @override
  String toString() {
    return "Instance of 'DialogsState[$isFirstInitialized $isLoading $isAuthenticated $isErrorHappened $errorType $isSearchMode dialogs length: ${dialogs.length} ] '";
  }
}