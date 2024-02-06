import 'dart:io';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_event.dart';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_events.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/services/global.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/widgets/pass_widget.dart';
import 'package:chat/ui/widgets/unauthenticated_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/user_bloc/user_event.dart';
import '../../bloc/ws_bloc/ws_event.dart';
import '../../services/auth/auth_repo.dart';
import '../../services/logger/logger_service.dart';
import '../../view_models/dialogs_page/dialogs_view_cubit.dart';
import '../../view_models/user/users_view_cubit.dart';
import '../../view_models/websocket/websocket_view_cubit.dart';
import '../navigation/main_navigation.dart';
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
    print("currentVersion:  $currentVersion");
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: BlocBuilder<ProfileBloc, UserProfileState>(
            builder: (BuildContext context, state) {
              if (state is UserProfileErrorState) {
                return Center(
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
                        Container(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          alignment: Alignment.centerLeft,
                          child: Text("Текущая версия:  ${currentVersion ?? ""}",
                            style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                          ),
                        ),
                        Platform.isAndroid
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 56),
                    UnauthenticatedWidget()
                  ],
                );
              } else {
                return Column(children: [
                  const Expanded(
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
  print("download new version");
  if(url == null) return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    customToastMessage(context: context, message: "Не удалось обработать ссылку");
  }
}
