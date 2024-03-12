import 'dart:async';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/services/global.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseInitializationScreen extends StatefulWidget {
  const DatabaseInitializationScreen({super.key});

  @override
  State<DatabaseInitializationScreen> createState() => _DatabaseInitializationScreenState();
}

class _DatabaseInitializationScreenState extends State<DatabaseInitializationScreen> {

  late final StreamSubscription<DatabaseBlocState> _databaseStateSubscription;
  String message = 'Загружаем \r\n базу данных';
  double stepProgress = 0.55;
  AppErrorException? error;

  @override
  void initState() {
    super.initState();
    _databaseStateSubscription = BlocProvider.of<DatabaseBloc>(context).stream.listen((event) {
      print('_databaseStateSubscription  $event');
      if (event is DatabaseBlocInitializationInProgressState) {
        setState(() {
          message = event.message;
          stepProgress = event.progress;
        });
      } else if (event is DatabaseBlocDBInitializedState) {
        setState(() {
          message = 'Загрузка завершена';
          stepProgress = 1;
        });
        Navigator.pushReplacementNamed(context, MainNavigationRouteNames.homeScreen);
      } else if (event is DatabaseBlocDBFailedInitializeState) {
        setState(() {
          error = event.exception;
        });
      }
    });
    BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocInitializeEvent());
  }

  @override
  void dispose() {
    _databaseStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
          body: Container(
            color: Colors.red.shade50,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 250,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.red.shade100,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 0.0,
                        blurRadius: 20.0,
                        blurStyle: BlurStyle.outer,
                        color: Colors.red.shade400
                    )
                  ]
              ),
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 20,),
                      Text(mapErrorToMessage(error!),
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            borderRadius: const BorderRadius.all(Radius.circular(6))
                          ),
                          child: InkWell(
                            onTap: () {
                              BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocInitializeEvent());
                              setState(() {
                                error = null;
                              });
                            },
                            customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)
                            ),
                            splashColor: Colors.white70,
                            child: const Center(
                              child: Text('Обновить',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
                ),
              ),
            ),
          )
      );
    }
    return Scaffold(
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
                Text(message,
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
                      width: 200.0 * stepProgress,
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
    );
  }

  Widget _dbLoadingProgressWidget(BuildContext context, String message, stepProgress) {
    return Container(
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
              Text(message,
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
                    width: 200.0 * stepProgress,
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
    );
  }
}
