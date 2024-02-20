import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogAvatar extends StatelessWidget {
  const DialogAvatar({
    required this.base64String,
    this.radius = 28,
    Key? key
}) : super(key: key);

  final String? base64String;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(base64String == null || base64String!.trim().isEmpty ? 4 :1), // Border radius
          child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: base64String == null || base64String!.trim().isEmpty
                  ? Image.asset('assets/images/no_avatar_group_version.png')
                  : Image.memory(base64Decode(base64String!)),
              )
          ),
        ),
      ),
    );
  }
}
