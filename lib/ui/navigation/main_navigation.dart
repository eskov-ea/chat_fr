import 'package:chat/factories/screen_factory.dart';
import 'package:flutter/material.dart';
import '../pages/user_profile_info_page.dart';
import '../screens/running_call_screen.dart';
import '../screens/chat_screen.dart';
import '../widgets/pdf_viewer_widget.dart';

abstract class MainNavigationRouteNames {
  static const loaderWidget = '/';
  static const auth = '/auth';
  static const homeScreen = '/home_screen';
  static const chatPage = '/home_screen/chat_page';
  static const pdfViewPage = '/home_screen/chat_page/pdf_view';
  static const filePreviewPage = '/home_screen/chat_page/file_preview';
  static const foreignAppsFileViewPage = '/home_screen/chat_page/file_view';
  static const audioMessagePage = '/home_screen/chat_page/audio_message_view';
  static const imageViewPage = '/home_screen/chat_page/image_message_view';
  static const userProfileInfoPage = '/home_screen/chat_page/user_profile';
  static const groupChatInfoPage = '/home_screen/chat_page/group_chat_info_page';
  static const imageScreen = '/home_screen/image_screen';
  static const runningCallScreen = '/home_screen/running_call_screen';
  static const outgoingCallScreen = '/home_screen/outgoing_call_screen';
  static const incomingCallScreen = '/home_screen/incoming_call_screen';
}


class MainNavigation {

  static final _screenFactory = ScreenFactory();

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.loaderWidget: (_) => _screenFactory.makeLoaderWidget(),
    MainNavigationRouteNames.auth: (_) => _screenFactory.makeAuthScreen(),
    MainNavigationRouteNames.homeScreen: (_) => _screenFactory.makeHomeScreen(),
  };
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.chatPage:
        const String name = "/home_screen/chat_page";
        final arguments = settings.arguments as ChatPageArguments;
        return MaterialPageRoute(
          settings: const RouteSettings(name: name),
          builder: (BuildContext context) => _screenFactory.makeChatScreen(arguments)
        );
      case MainNavigationRouteNames.imageScreen:
        final arguments = settings.arguments as AttachmentViewPageArguments;
        const String name = MainNavigationRouteNames.imageViewPage;
        return MaterialPageRoute(
            builder: (BuildContext context) => _screenFactory.makeImageScreen(arguments)
        );
      case MainNavigationRouteNames.userProfileInfoPage:
        final arguments = settings.arguments as UserProfileArguments;
        return MaterialPageRoute(
            builder: (BuildContext context) => _screenFactory.makeUserProfileInfoPage(arguments)
        );
      case MainNavigationRouteNames.groupChatInfoPage:
        final arguments = settings.arguments as ChatPageArguments;
        const String name = MainNavigationRouteNames.groupChatInfoPage;
        return MaterialPageRoute(
          settings: const RouteSettings(name: name),
          builder: (BuildContext context) => _screenFactory.makeGroupChatInfoPage(arguments)
        );
      case MainNavigationRouteNames.runningCallScreen:
        final arguments = settings.arguments as CallScreenArguments;
        const String name = "/home_screen/running_call_screen";
        return MaterialPageRoute(
          settings: const RouteSettings(name: name),
          builder: (BuildContext context) => _screenFactory.makeRunningCallScreen(arguments)
        );
      case MainNavigationRouteNames.incomingCallScreen:
        final arguments = settings.arguments as CallScreenArguments;
        const String name = "/home_screen/incoming_call_screen";
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makeIncomingCallScreen(arguments)
        );
      case MainNavigationRouteNames.outgoingCallScreen:
        final arguments = settings.arguments as CallScreenArguments;
        const String name = MainNavigationRouteNames.outgoingCallScreen;
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makeOutgoingCallScreen(arguments)
        );
      case MainNavigationRouteNames.pdfViewPage:
        final arguments = settings.arguments as AttachmentViewPageArguments;
        const String name = MainNavigationRouteNames.pdfViewPage;
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makePdfViewPage(arguments)
        );
      case MainNavigationRouteNames.filePreviewPage:
        final arguments = settings.arguments as AttachmentViewPageArguments;
        const String name = MainNavigationRouteNames.filePreviewPage;
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makeFilePreviewPage(arguments)
        );
      case MainNavigationRouteNames.audioMessagePage:
        final arguments = settings.arguments as AttachmentViewPageArguments;
        const String name = MainNavigationRouteNames.audioMessagePage;
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makeAudioMessagePage(arguments)
        );
      case MainNavigationRouteNames.imageViewPage:
        final arguments = settings.arguments as AttachmentViewPageArguments;
        const String name = MainNavigationRouteNames.imageViewPage;
        return MaterialPageRoute(
            settings: const RouteSettings(name: name),
            builder: (BuildContext context) => _screenFactory.makeImageMessagePage(arguments)
        );
      default:
        const widget = Text('Navigation error!!!');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }

  static void resetNavigation(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainNavigationRouteNames.loaderWidget,
          (route) => false,
    );
  }
}
