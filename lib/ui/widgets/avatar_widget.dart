import 'dart:io';
import 'package:chat/services/global.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({
    required this.userId,
    this.size = 28,
    this.objKey,
    Key? key,
  }) : super(key: key);

  final int? userId;
  final double size;
  final ObjectKey? objKey;

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  File? image;

  @override
  void initState() {
    super.initState();
    fetchUserAvatar();
  }

  void fetchUserAvatar() async {
    File? file;
    file = await loadAndSaveLocallyUserAvatar(
        userId: widget.userId
    );

    try {
      if (file != null) {
        setState(() {
          image = file;
        });
      }
    } catch (err, stackTrace) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      key: widget.objKey,
      child: CircleAvatar(
        radius: widget.size,
        backgroundColor: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(image == null ? 4 : 1), // Border radius
          child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: image == null
                    ? Image.asset('assets/images/no_avatar.png')
                    : Image.file(image!, fit: BoxFit.cover,),
              )
          ),
        ),
      ),
    );
  }
}