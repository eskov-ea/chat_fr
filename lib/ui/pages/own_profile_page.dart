import 'dart:io';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth/auth_repo.dart';
import '../navigation/main_navigation.dart';


class ProfilePage extends StatelessWidget {

  final bool isUpdateAvailable;

  const ProfilePage({
    required this.isUpdateAvailable,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, UserProfileState>(
      builder: (BuildContext context, state) {
        if (state is UserProfileLoadedState){
          return Scaffold(
            body: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            const SizedBox(height: 20,),
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(4), // Border radius
                                child: ClipOval(
                                    child: state.user?.image != null
                                        ? Image.network(state.user!.image!)
                                        : Image.asset('assets/images/no_avatar.png')
                                ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Text(state.user!.lastname + " " + state.user!.firstname + " " + state.user!.middlename,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 25,)
                            ),
                            const SizedBox(height: 5,),
                            Text(state.user!.company + ", " + state.user!.dept,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18,)
                            ),
                            Text(state.user!.position,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18,)
                            ),
                            const SizedBox(height: 5,),
                            SelectableText(
                              state.user!.phone,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18,),
                            ),
                            const SizedBox(height: 5,),
                            SelectableText(
                              state.user!.email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18,),
                            ),
                          ],
                        ),
                      ),
                      Platform.isAndroid
                          ? OutlinedButton(
                              onPressed: () async {
                                isUpdateAvailable ? downLoadNewAppVersion(state.user?.appSettings?.downloadUrlAndroid) : (){};
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isUpdateAvailable ? LightColors.profilePageButton : Colors.white10,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color:isUpdateAvailable ? Colors.black54 : Colors.black12, width: 2, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.zero),
                              ),
                              child: Text(
                                'Загрузить новую версию',
                                style: TextStyle(color: isUpdateAvailable ? Colors.black54 : Colors.black26, fontSize: 20, fontWeight: FontWeight.w300),
                              )
                            )
                          : SizedBox.shrink(),
                      OutlinedButton(
                          onPressed: () async {
                            await AuthRepository().logout();
                            //TODO: check if logout consistently works through add event
                            // BlocProvider.of<AuthViewCubit>(context).logout(context);
                            Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.auth);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: LightColors.profilePageButton,
                            minimumSize: const Size.fromHeight(50),
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                                borderRadius: BorderRadius.zero),
                          ),
                          child: const Text(
                            'Выйти из аккаунта',
                            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),
                          )
                      ),
                      SizedBox(height: 5,)
                    ]
                ),
              ),
            ),
          );
        } else {
          return Column(children: [
            const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                )),
            OutlinedButton(
                onPressed: () async {
                  await AuthRepository().logout();
                  //TODO: check if logout consistently works through add event
                  // BlocProvider.of<AuthViewCubit>(context).logout(context);
                  Navigator.of(context)
                      .pushReplacementNamed(MainNavigationRouteNames.auth);
                },
                style: ElevatedButton.styleFrom(
                  primary: LightColors.profilePageButton,
                  minimumSize: const Size.fromHeight(50),
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.black54,
                          width: 2,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.zero),
                ),
                child: const Text(
                  'Выйти из аккаунта',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                )),
          ]);
        }
      },
    );
  }

  downLoadNewAppVersion(String? url) async {
    print("download new version");
    if(url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
    // can't launch url
    }
  }
}
