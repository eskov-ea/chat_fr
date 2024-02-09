import 'package:flutter/cupertino.dart';

class AppNotificationModel {
  final String fromName;
  final String message;
  final AppNotificationType type;
  final Function() callback;
  final GlobalKey key;

  const AppNotificationModel({
    required this.fromName,
    required this.message,
    required this.type,
    required this.callback,
    required this.key
  });
}

enum AppNotificationType { message, call }