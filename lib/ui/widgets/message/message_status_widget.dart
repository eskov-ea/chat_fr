import 'package:flutter/material.dart';

Widget StatusWidget(int status) {
  switch (status) {
    case 0:
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(
              color: Colors.grey,
              strokeCap: StrokeCap.round,
              strokeWidth: 1.0,
            ),
          ),
        ),
      );
    case 2:
      return const Icon(
        Icons.check_outlined,
        color: Colors.grey,
        size: 20.0,
      );
    case 3:
      return const Stack(
        alignment: Alignment.centerRight,
        children: [
          Icon(
            Icons.check_outlined,
            color: Colors.grey,
            size: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Icon(
              Icons.check_outlined,
              color: Colors.grey,
              size: 20.0,
            ),
          ),
        ],
      );
    case 4:
      return const Stack(
        alignment: Alignment.centerRight,
        children: [
          Icon(
            Icons.check_outlined,
            color: Colors.green,
            size: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(
              Icons.check_outlined,
              color: Colors.green,
              size: 20.0,
            ),
          ),
        ],
      );
    default: return const SizedBox.shrink();
  }
}