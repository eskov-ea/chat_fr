import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/global.dart';

class AvatarWidget extends StatefulWidget {
  const AvatarWidget({
    required this.userId,
    double this.size = 28,
    Key? key,
  }) : super(key: key);

  final int? userId;
  final double size;

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  File? image;

  @override
  void initState() {
    fetchUserAvatar();
    super.initState();
  }

  void fetchUserAvatar() async {
    File? file;
    file = await loadAndSaveLocallyUserAvatar(
        userId: widget.userId
    );

    if (file != null) {
      setState(() {
        image = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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