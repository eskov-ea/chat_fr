import 'package:chat/models/dialog_model.dart';

class DialogsListContainer {
  final List<DialogData> dialogs;

  const DialogsListContainer.initial()
      : dialogs = const <DialogData>[];

  DialogsListContainer({
    required this.dialogs,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DialogsListContainer &&
              runtimeType == other.runtimeType &&
              dialogs == other.dialogs;

  @override
  int get hashCode =>
      dialogs.hashCode;

  DialogsListContainer copyWith({
    List<DialogData>? dialogs,
  }) {
    return DialogsListContainer(
        dialogs: dialogs ?? this.dialogs
    );
  }
}