import 'dart:math';
import 'package:chat/models/dialog_model.dart';

import 'models/message_model.dart';

abstract class Helpers {
  static final random = Random();


  static checkIReadMessage(List<MessageStatus>? statuses, int userId, DialogData? d) {
    if (statuses?.first.dialogId == 354) {
      print('check status::: bject info: ${d?.lastMessage}');
    }
    if (statuses == null) return 0;
    var status = 0;
    for (var statusObj in statuses) {
      if (statusObj.userId == userId) {
        // print('check status::: dialogID: ${statusObj.dialogId}, userId: $userId, statusUserId: ${statusObj.userId}, status: ${statusObj.statusId}');
        status = statusObj.statusId;
      }
    }
    return status;
  }
  static checkPartnerReadMessage(List<MessageStatus>? statuses, int userId) {
    if (statuses == null) return 0;
    var status = 0;
    for (var statusObj in statuses) {
      if (statusObj.userId != userId) status = statusObj.statusId;
    }
    return status;
  }
}
