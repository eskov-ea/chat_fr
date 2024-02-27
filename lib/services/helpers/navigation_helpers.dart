import 'package:chat/models/contact_model.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/navigation/main_navigation.dart';
import '../../ui/pages/user_profile_info_page.dart';
import '../../ui/screens/chat_screen.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';

import '../../view_models/user/users_view_cubit.dart';

void openChatScreen({
  required BuildContext context,
  required userId,
  required partnerId,
  required dialogData,
  required username
}) {
  Navigator.of(context).pushNamed(
    MainNavigationRouteNames.chatPage,
    arguments: ChatPageArguments(
      userId: userId,
      dialogCubit: BlocProvider.of<DialogsViewCubit>(context),
      partnerId: partnerId,
      dialogData: dialogData,
      username: username,
      usersCubit: BlocProvider.of<UsersViewCubit>(context)
    ),
  );
}

void openUserProfileInfoPage({
  required BuildContext context,
  required UserModel? user,
  required partnerId
}) {
  if (user == null) {
    PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Ошибка! Не удалось загрузить данные пользователя");
    Logger.getInstance().sendDebugMessage(message: "Error openning partner profile info. The data was: partnerId: $partnerId, user: $user", operation: "openUserProfileInfoPage");
  } else {
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.userProfileInfoPage,
        arguments: UserProfileArguments(user: user, partnerId: partnerId));
  }
}

void openGroupChatInfoPage({
  required BuildContext context,
  required usersCubit,
  required username,
  required dialogData,
  required partnerId,
  required userId,
  required dialogCubit
}) {
  Navigator.of(context).pushNamed(
      MainNavigationRouteNames.groupChatInfoPage,
      arguments: ChatPageArguments(
        usersCubit: usersCubit,
        username: username,
        dialogData: dialogData,
        partnerId: partnerId,
        userId: userId,
        dialogCubit: dialogCubit,
      )
  );
}

void openImageScreen({
  required BuildContext context,
  required String image
}) {
  Navigator.of(context).pushNamed(
    MainNavigationRouteNames.imageScreen,
    arguments: image);
}