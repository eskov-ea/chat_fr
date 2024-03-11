import 'package:chat/services/database/db_provider.dart';
import 'package:chat/view_models/loader/loader_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../navigation/main_navigation.dart';


class LoaderWidget extends StatefulWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget> {

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoaderViewCubit, LoaderViewCubitState>(
      listenWhen: (prev, current) => current != LoaderViewCubitState.unknown,
      listener: onLoaderViewCubitStateChange,
      // bloc: BlocProvider.of<LoaderViewCubit>(context).start(),
      child: Scaffold(
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.black12,
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 0.0,
                      blurRadius: 20.0,
                      blurStyle: BlurStyle.outer,
                      color: Colors.black54
                  )
                ]
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.purple.shade300,
                      strokeWidth: 12.0,
                      backgroundColor: Colors.purple.shade800,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Загрузка \r\n приложения',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomLeft,

                    children: [
                      SizedBox(
                        width: 200.0,
                        height: 10,
                        child: Container(
                            color: Colors.purple.shade300
                        ),
                      ),
                      SizedBox(
                        width: 200.0 * 0.1,
                        height: 10,
                        child: Container(
                            color: Colors.purple.shade800
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  Future<void> checkAuthentication() async {
    final db = DBProvider.db;
    final token = await db.getToken();
    final nextScreen = token != null
      ? MainNavigationRouteNames.dbInitializationScreen
      : MainNavigationRouteNames.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }

  void onLoaderViewCubitStateChange(
      BuildContext context,
      LoaderViewCubitState state,
      ) {
    print('onLoaderViewCubitStateChange,   $state');
    final nextScreen = state == LoaderViewCubitState.authorized
        ? MainNavigationRouteNames.dbInitializationScreen
        : MainNavigationRouteNames.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}