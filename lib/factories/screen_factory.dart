import 'package:chat/ui/screens/call_logs_screen.dart';
import 'package:chat/ui/screens/db_initialization_screen.dart';
import 'package:chat/ui/screens/sip_connection_state_screen.dart';
import 'package:chat/ui/widgets/pass_widget.dart';
import 'package:chat/ui/screens/users_screen.dart';
import 'package:chat/ui/screens/dialogs_screen.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/ui/widgets/message/audioplayer_widget.dart';
import 'package:chat/ui/widgets/pdf_viewer_widget.dart';
import 'package:flutter/material.dart';
import '../ui/pages/call_info_page.dart';
import '../ui/pages/group_chat/group_chat_info_page.dart';
import '../ui/screens/own_profile_screen.dart';
import '../ui/pages/reset_password_page.dart';
import '../ui/pages/user_profile_info_page.dart';
import '../ui/screens/auth_screen.dart';
import '../ui/screens/incoming_call_screen.dart';
import '../ui/screens/running_call_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/image_screen.dart';
import '../ui/widgets/file_previewer_widget.dart';
import '../ui/widgets/loader_widget.dart';

class ScreenFactory {

  Widget makeMessagesPage(){
    return const MessagesPage();
  }

  Widget makeContactsPage() {
    return const ContactsPage();
  }

  Widget makeCallsPage() {
    return const CallsPage();
  }

  Widget makeProfilePage(bool isUpdateAvailable, String? currentVersion) {
    return ProfilePage(isUpdateAvailable: isUpdateAvailable, currentVersion: currentVersion);
  }

  Widget makeLoaderWidget() {
    return const LoaderWidget();
  }

  Widget makeAuthScreen() {
    return AuthScreen();
  }

  Widget makeHomeScreen() {
    return const HomeScreen();
  }

  Widget makeChatScreen(ChatPageArguments arguments) {
    return ChatScreen(
      dialogCubit: arguments.dialogCubit,
      users: arguments.users,
      dialogData: arguments.dialogData,
      username: arguments.username,
      userId: arguments.userId!,
      partnerId: arguments.partnerId,
    );
  }

  Widget makeUserProfileInfoPage(UserProfileArguments arguments) {
    return UserProfileInfoPage(
      user: arguments.user,
      partnerId: arguments.partnerId,
    );
  }

  Widget makeGroupChatInfoPage(ChatPageArguments arguments) {
    return GroupChatInfoPage(
      userId: arguments.userId,
      chatUsers: arguments.dialogData!.users,
      dialogData: arguments.dialogData!,
      users: arguments.users,
      dialogsViewCubit: arguments.dialogCubit,
    );
  }

  Widget makeRunningCallScreen(CallScreenArguments arguments) {
    return RunningCallScreen(userId: arguments.userId);
  }

  // Widget makeOutgoingCallScreen(CallScreenArguments arguments) {
  //   return OutgoingCallScreen(
  //       callerName: arguments.callerName
  //   );
  // }

  // Widget makeIncomingCallScreen(CallScreenArguments arguments) {
  //   return IncomingCallScreen(
  //       callerName: arguments.callerName
  //   );
  // }

  Widget makeImageScreen(ImageScreenArguments arguments) {
    return  ImageScreen(
      width: arguments.width ?? 0.4,
      fileBytesRepresentation: arguments.fileBytesRepresentation,
      localFileAttachment: arguments.localFileAttachment,
      fileName: arguments.fileName,
      saveImageFunction: arguments.saveCallback,
    );
  }

  Widget makePdfViewPage(AttachmentViewPageArguments arguments) {
    return PdfViewerWidget(attachmentId: arguments.attachmentId, fileName: arguments.fileName, fileExt: arguments.fileExt);
  }

  Widget makeFilePreviewPage(AttachmentViewPageArguments arguments) {
    return FilePreviewerWidget(attachmentId: arguments.attachmentId, fileName: arguments.fileName, fileExt: arguments.fileExt);
  }

  Widget makeAudioMessagePage(AttachmentViewPageArguments arguments) {
    return AudioPlayerWidget(key: UniqueKey(), attachmentId: arguments.attachmentId, fileName: arguments.fileName, isMe: arguments.isMe , messageTime: arguments.messageTime);
  }

  Widget makeCallInfoPage(CallRenderData arguments) {
    return CallInfoPage(callData: arguments);
  }

  Widget makeResetPasswordScreen() {
    return ResetPasswordScreen();
  }

  Widget makeDatabaseInitializationScreen() {
    return DatabaseInitializationScreen();
  }

  Widget makeSipConnectionScreen() {
    return const SipConnectionStateScreen();
  }

}