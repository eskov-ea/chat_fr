import '../../models/dialog_model.dart';



bool compareDialogDataLists (List<DialogData>? list1, List<DialogData>? list2) {
  if (list1 == null) return list2 == null;
  if (list2 == null) return false;
  if (list1.length != list2.length) return false;
  for (var i = 0; i < list1.length; i += 1) {
    if (list1[i].dialogId != list2[i].dialogId ||
      list1[i].users.length != list2[i].users.length
        // || list1[i].lastMessage.messageId != list2[i].lastMessage.messageId
        // || list1[i].lastMessage.statuses.length != list2[i].lastMessage.statuses.length

    ) return false;
  }
  return true;
}

bool compareDialogDataLists2 (List<DialogData>? list1, List<DialogData>? list2) {
  final b = compareDialogDataLists(list1, list2);
  return b;
}