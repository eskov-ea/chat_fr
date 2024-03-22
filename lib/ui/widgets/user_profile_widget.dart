import 'package:chat/models/user_model.dart';
import 'package:chat/ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    required this.user,
    Key? key
  }) : super(key: key);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            UserAvatarWidget(userId: user.id, size: 70,),
            const SizedBox(height: 20,),
            Text(user.lastname + " " + user.firstname + " " + user.middlename,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25,)
            ),
            const SizedBox(height: 5,),
            Text(user.company + ", " + user.dept,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18,)
            ),
            Text(user.position,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18,)
            ),
            const SizedBox(height: 5,),
            SelectableText(user.phone, style: const TextStyle(fontSize: 18,),),
            const SizedBox(height: 5,),
            SelectableText(user.email, style: const TextStyle(fontSize: 18,),)
          ]
      ),
    );
  }
}
