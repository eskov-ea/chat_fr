import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogAvatar extends StatelessWidget {
  const DialogAvatar({
    required this.base64String,
    Key? key
}) : super(key: key);

  final String? base64String;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(base64String!.trim().isEmpty ? 4 :1), // Border radius
          child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: base64String!.trim().isEmpty
                  ? Image.asset('assets/images/no_avatar_group_version.png')
                  : Image.memory(base64Decode(base64String!)),
              )
          ),
        ),
      ),
    );
  }
}