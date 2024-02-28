import 'dart:math';
import 'models/message_model.dart';

abstract class Helpers {
  static final random = Random();


  static checkIReadMessage(List<MessageStatus>? statuses, int userId) {
    if (statuses == null) return 0;
    var status = 0;
    for (var statusObj in statuses) {
      if (statusObj.userId == userId) {
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
