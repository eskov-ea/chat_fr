import 'package:flutter/material.dart';
import '../../models/contact_model.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    required this.user,
    Key? key
  }) : super(key: key);

  final UserContact user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(4), // Border radius
                child: ClipOval(
                    child: user.image != null
                        ? Image.network(user.image!)
                        : Image.asset('assets/images/no_avatar.png')
                ),
              ),
            ),
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
