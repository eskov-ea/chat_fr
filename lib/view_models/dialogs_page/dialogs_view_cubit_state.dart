import 'package:chat/models/dialog_model.dart';

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
              dialogs == other.dialogs &&
              searchQuery == other.searchQuery &&
              isError == other.isError;

  @override
  int get hashCode => dialogs.hashCode ^ searchQuery.hashCode ^ isError.hashCode;

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

// class DialogsCubitLoadingState extends DialogsViewCubitState {
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is DialogsCubitLoadingState &&
//               runtimeType == other.runtimeType;
//
//   @override
//   int get hashCode => 0;
// }
//
// class DialogsViewCubitErrorState extends DialogsViewCubitState {
//   final String errorMessage;
//
//   DialogsViewCubitErrorState(this.errorMessage);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is DialogsViewCubitErrorState &&
//               runtimeType == other.runtimeType &&
//               errorMessage == other.errorMessage;
//
//   @override
//   int get hashCode => errorMessage.hashCode;
// }
//
// class DialogsViewCubitAuthProgressState extends DialogsViewCubitState {
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is DialogsViewCubitAuthProgressState &&
//               runtimeType == other.runtimeType;
//
//   @override
//   int get hashCode => 0;
// }
//
// class DialogsViewCubitSuccessAuthState extends DialogsViewCubitState {
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is DialogsViewCubitSuccessAuthState &&
//               runtimeType == other.runtimeType;
//
//   @override
//   int get hashCode => 0;
// }