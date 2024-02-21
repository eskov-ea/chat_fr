import 'package:flutter/material.dart';

Widget StatusWidget(int status) {
  switch (status) {
    case 2:
      return const Icon(
        Icons.check_outlined,
        color: Colors.grey,
        size: 20.0,
      );
    case 3:
      return const Stack(
        alignment: Alignment.center,
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