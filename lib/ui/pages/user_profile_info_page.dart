import 'package:chat/services/global.dart';
import 'package:chat/ui/widgets/user_profile_widget.dart';
import 'package:chat/ui/widgets/web_container_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../theme.dart';

class UserProfileInfoPage extends StatelessWidget {
  const UserProfileInfoPage({
    required this.user,
    required this.partnerId,
    Key? key
  }) : super(key: key);

  final UserContact user;
  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                padding: EdgeInsets.zero,
                child: IconButton(

                  icon: const Icon(CupertinoIcons.back, color: AppColors.secondary,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 35, bottom: 2),
                child: Text(
                  "Назад",
                  softWrap: false,
                  style: TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.w700)),
              )
            ],
          ),
        ),
        title: const Text(
            "О контакте",
          style: TextStyle(color: LightColors.mainText, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: WebContainerWrapper(
          child: ListView(
            children: [
              UserProfileWidget(
                user: user,
              ),
              const SizedBox(height: 30,),
            ],
          ),
        )
      ),
    );
  }
}

class UserProfileArguments {
  final UserContact user;
  final int partnerId;

  UserProfileArguments({required this.user, required this.partnerId});
}