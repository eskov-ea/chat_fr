import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/data_storage.dart';
import '../../theme.dart';
import '../navigation/main_navigation.dart';
import 'package:chat/view_models/auth/auth_view_cubit.dart';
import 'package:chat/view_models/auth/auth_view_state.dart';
import 'dart:io' show Platform;


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  static const methodChannel = MethodChannel("com.application.chat/method");
  final DataProvider _dataProvider = DataProvider();
  String deviceToken = '';
  late String os;
  late final platformSipStream ;
  final _loginTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final _loginFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _hidePassword = true;
  final bool isError = false;
  late String errorMessage;

  bool flag = true;

  Future<void> _checkDeviceToken() async {
    // if ( await _dataProvider.getDeviceID() != null) return;
    try {
      //TODO: refactor with safe bool getters
      try{
        os = Platform.operatingSystem;
      } catch (e) {
        os = "Browser";
      }
      print('requesting token');
      if (!kIsWeb) {
        deviceToken = await methodChannel.invokeMethod('getDeviceToken');
        _dataProvider.setDeviceID(deviceToken);
      }
      _dataProvider.setOs(os);
    } on PlatformException catch (e) {
      await Future.delayed(const Duration(seconds: 2), (){
        if (!kIsWeb) _checkDeviceToken();
      });
      print(e);
    } catch (err) {
      print(err);
    }
  }

  @override
  void dispose() {
    _loginTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkDeviceToken();
  }

  // @override
  void _onNextFieldFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AuthViewCubit>();
    return  BlocListener<AuthViewCubit, AuthViewCubitState>(
        listener: _onAuthViewCubitStateChange,
        child:  Scaffold(
          // backgroundColor: Color(0xFF1B1E1F),
          body: SafeArea(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Column(
                      children: [
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Image.asset(
                                'assets/images/DV-rybak-logo-cropped.png',
                                height: 150,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                          child: LoginFormWidget(context, cubit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        )
          );
        }

  Widget LoginFormWidget(context, cubit) {
    return Form(
      child: Column(children: [
        if (cubit.state is AuthViewCubitErrorState)
          Text(cubit.state.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.red),),
        TextFormField(
          controller: _loginTextFieldController,
          focusNode: _loginFocus,
          autofocus: true,
          onFieldSubmitted: (_) {
            _onNextFieldFocus(context, _loginFocus, _passwordFocus);
          },
          style: const TextStyle(fontSize: 20, color: LightColors.mainText, decoration: TextDecoration.none),
          decoration: const InputDecoration(
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: LightColors.mainText, width: 2.5, )
            ),

            labelText: 'Логин',
            labelStyle: TextStyle(fontSize: 22),
            prefixIcon: Icon(Icons.person),
            prefixIconColor: Colors.blue,
            focusColor: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordTextFieldController,
          focusNode: _passwordFocus,
          obscureText: _hidePassword,
          style: const TextStyle(fontSize: 20, color: LightColors.mainText, decoration: TextDecoration.none),
          decoration: InputDecoration(
            labelText: 'Пароль',
            labelStyle: const TextStyle(fontSize: 22),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: GestureDetector(
              child:
                  Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
              onTap: () {
                setState(() {
                  _hidePassword = !_hidePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          child: cubit.state is AuthViewCubitAuthProgressState
            ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : const Text(
              'Логин',
              style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
            minimumSize: const Size.fromHeight(45),
          ),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _login(_loginTextFieldController.text,
              _passwordTextFieldController.text, context,
              os, deviceToken
            );
          },
        ),
      ]),
    );
  }
}

void _onAuthViewCubitStateChange (
  BuildContext context,
  AuthViewCubitState state
  ) {
  if (state is AuthViewCubitSuccessAuthState) {
    Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.homeScreen);
  }
}


void _login(username, pass, context, platform, token) async {
  BlocProvider.of<AuthViewCubit>(context).auth(email:username, password:pass, platform: platform, token: token);
}