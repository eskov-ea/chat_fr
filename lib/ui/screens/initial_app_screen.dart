import 'package:chat/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';

class InitialAppScreen extends StatefulWidget {
  const InitialAppScreen({Key? key}) : super(key: key);

  @override
  State<InitialAppScreen> createState() => _InitialAppScreenState();
}

class _InitialAppScreenState extends State<InitialAppScreen> {


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
