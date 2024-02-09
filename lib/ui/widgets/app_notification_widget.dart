import 'package:chat/models/app_notification_model.dart';
import 'package:flutter/material.dart';

class AppNotificationWidget extends StatefulWidget {
  const AppNotificationWidget({
    required this.notificationData,
    required this.callback,
    super.key
  });

  final AppNotificationModel? notificationData;
  final Function() callback;

  @override
  State<AppNotificationWidget> createState() => _AppNotificationWidgetState();
}

class _AppNotificationWidgetState extends State<AppNotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {

        },
        onVerticalDragEnd: (event) {
          print("Drag event:  ${event.velocity}");
          widget.callback();
        },
        child: Container(
          width: MediaQuery.of(context).size.width - 10,
          height: 100,
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: Colors.brown.shade100,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
        ),
      ),
    );
  }
}
