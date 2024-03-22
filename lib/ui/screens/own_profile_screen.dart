import 'dart:io';
import 'package:chat/bloc/profile_bloc/profile_bloc.dart';
import 'package:chat/bloc/profile_bloc/profile_state.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/theme.dart';
import 'package:chat/types_extensions/String.dart';
import 'package:chat/types_extensions/String.dart';
import 'package:chat/types_extensions/String.dart';
import 'package:chat/ui/screens/db_screen.dart';
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
                              UserAvatarWidget(userId: state.profile?.user.id, size: 70,),
                              const SizedBox(height: 20,),
                              Text(state.profile!.user.lastname.toCapitalized() + " " + state.profile!.user.firstname.toCapitalized() + " " + state.profile!.user.middlename.toCapitalized(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 25,)
                              ),
                              const SizedBox(height: 5,),
                              Text(state.profile!.user.company + ", " + state.profile!.user.dept,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18,)
                              ),
                              Text(state.profile!.user.position,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18,)
                              ),
                              const SizedBox(height: 5,),
                              SelectableText(
                                state.profile!.user.phone,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18,),
                              ),
                              const SizedBox(height: 5,),
                              SelectableText(
                                state.profile!.user.email,
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
                        !kIsWeb && Platform.isAndroid
                          ? OutlinedButton(
                              onPressed: () async {
                                isUpdateAvailable ? downLoadNewAppVersion(state.profile?.appSettings?.downloadUrlAndroid, context) : (){};
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
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => DBScreen())
                            );
                            // await deleteAllDataAndCloseApp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUpdateAvailable ? LightColors.profilePageButton : Colors.white10,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color:isUpdateAvailable ? Colors.black54 : Colors.black12, width: 2, style: BorderStyle.solid),
                                borderRadius: BorderRadius.zero),
                          ),
                          child: Text(
                            'Удалить все данные',
                            style: TextStyle(color: isUpdateAvailable ? Colors.black54 : Colors.black26, fontSize: 20, fontWeight: FontWeight.w300),
                          )
                      ),
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

Future<void> deleteBD(BuildContext context) async {
  // final db = DBP
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

Future<void> deleteAllDataAndCloseApp(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Вы уверены, что хотите удалить все данные?'),
        content: const Text(
          'Все ранее загруженные данные будут удалены и приложение закрыто. При следующем запуске данные будут загружены по сети. Это может быть полезно, если синхронизация приложения с сервером была нарушена и часть данных утеряна или недополучена.',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Удалить'),
            onPressed: () async {
              PopupManager.showLoadingPopup(context);
              final db = DBProvider.db;
              await db.deleteDBFile();
              Navigator.of(context).pop();
              exit(0);
            },
          ),TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Назад'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
