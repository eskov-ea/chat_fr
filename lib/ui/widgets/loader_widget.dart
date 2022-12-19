import 'package:chat/view_models/loader/loader_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../navigation/main_navigation.dart';


class LoaderWidget extends StatelessWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoaderViewCubit, LoaderViewCubitState>(
      listenWhen: (prev, current) => current != LoaderViewCubitState.unknown,
      listener: onLoaderViewCubitStateChange,
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void onLoaderViewCubitStateChange(
      BuildContext context,
      LoaderViewCubitState state,
      ) {
    print('onLoaderViewCubitStateChange,   $state');
    final nextScreen = state == LoaderViewCubitState.authorized
        ? MainNavigationRouteNames.homeScreen
        : MainNavigationRouteNames.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute( builder: (BuildContext context)  => const OutgoingCallScreen() ) , (route) => false);
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute( builder: (BuildContext context)  => const TestWidget() ) , (route) => false);
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute( builder: (BuildContext context)  => const IncomingCall(user: "Andrey",) ) , (route) => false);
  }
}