import 'package:chat/services/auth/auth_repo.dart';
import 'package:flutter/material.dart';
import '../../theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _emailTextFieldController = TextEditingController();
  bool isError = false;
  bool inProgress = false;
  String? errorMessage;
  bool isValidEmail(email) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Напомнить пароль'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Для смены пароля необходимо ввести Ваш рабочий email, который используется в качестве логина. Далее вам на почту придет новый пароль',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _emailTextFieldController,
                  autofocus: false,
                  style: const TextStyle(fontSize: 20, color: LightColors.mainText, decoration: TextDecoration.none),
                  decoration: const InputDecoration(
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: LightColors.mainText, width: 2.5, )
                    ),

                    labelText: 'Введите email',
                    labelStyle: TextStyle(fontSize: 22),
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Colors.blue,
                    focusColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 20,),
                isError
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.start,
                      ),
                  )
                  : SizedBox.shrink(),
                SizedBox(height: 20,),
                ElevatedButton(
                  child: inProgress
                    ? const CircularProgressIndicator()
                    : const Text(
                      'Сбросить пароль',
                      style: TextStyle(fontSize: 20),
                    ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () async {
                    print('SEND NEW PASSWORD');
                    setState(() {
                      inProgress = true;
                      isError = false;
                      errorMessage = '';
                    });
                    if (_emailTextFieldController.text != '' && isValidEmail(_emailTextFieldController.text)) {
                      await AuthRepository().resetPassword(_emailTextFieldController.text);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        isError = true;
                        errorMessage = 'Введите корректный email';
                        inProgress = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
