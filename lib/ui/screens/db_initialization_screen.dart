import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseInitializationScreen extends StatelessWidget {
  const DatabaseInitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: Colors.blueAccent.shade200,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 10,
              blurRadius: 10
            )
          ]
        ),
        child: BlocConsumer<DatabaseBloc, DatabaseBlocState>(
          listener: (context, state) {
            if (state is DatabaseBlocDBInitializedState) {
              Navigator.pushReplacementNamed(context, MainNavigationRouteNames.homeScreen);
            }
          },
          bloc: BlocProvider.of<DatabaseBloc>(context)..add(DatabaseBlocInitializeEvent()),
          builder: (context, state) {

            return Container(
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 15,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            );
          },
        )
      ),
    );
  }
}
