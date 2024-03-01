import 'dart:io';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/services/global.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/unauthenticated_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/avatar_widget.dart';


class ProfilePage extends StatelessWidget {

  final bool isUpdateAvailable;
  final String? currentVersion;


  const ProfilePage({
    required this.isUpdateAvailable,
    required this.currentVersion,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: BlocBuilder<ProfileBloc, UserProfileState>(
            builder: (BuildContext context, state) {
              if (state is UserProfileErrorState) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Произошла ошибка при загрузке данных. Попробуйте перезагрузить приложение",
                        style: TextStyle(fontSize: 18, color: Colors.black87,),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                );
              } else if (state is UserProfileLoadedState){
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomSizeContainer(
                          ListView(
                            children: [
                              const SizedBox(height: 20,),
                              UserAvatarWidget(userId: state.user?.id, size: 70,),
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
                          ), context),
                        ),
                        if (currentVersion != null) Container(
                          padding: const EdgeInsets.only(left: 10, bottom: 2),
                          alignment: Alignment.centerLeft,
                          child: Text("Текущая версия:  $currentVersion",
                            style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                          ),
                        ),
                      if (kIsWeb) Container(
                        padding: const EdgeInsets.only(left: 10, bottom: 2),
                        alignment: Alignment.centerLeft,
                        child: const Text("Текущая версия:  1.0.30",
                          style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                        ),
                      ),
                        !kIsWeb && Platform.isAndroid
                          ? OutlinedButton(
                              onPressed: () async {
                                isUpdateAvailable ? downLoadNewAppVersion(state.user?.appSettings?.downloadUrlAndroid, context) : (){};
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
                            logoutHelper(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.profilePageButton,
                            minimumSize: const Size.fromHeight(50),
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black54, width: 2, style: BorderStyle.solid),
                                borderRadius: BorderRadius.zero),
                          ),
                          child: const Text(
                            'Выйти из аккаунта',
                            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600),
                          )
                      )
                    ]
                  ),
                );
              } else if (state is UserProfileLoggedOutState) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 56),
                    UnauthenticatedWidget()
                  ],
                );
              } else {
                return const Column(children: [
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
                ]);
              }
            },
          ),
        ),
      ),
    );
  }
}

void downLoadNewAppVersion(String? url, BuildContext context) async {
  if(url == null) return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    customToastMessage(context: context, message: "Не удалось обработать ссылку");
  }
}
