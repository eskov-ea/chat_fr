import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:flutter/material.dart';

class UnauthenticatedWidget extends StatelessWidget {
  const UnauthenticatedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: UniqueKey(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 300,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color(0xFBEFEFEF),
          boxShadow: [
            BoxShadow(
                color: Color(0x336FADFF),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(10, 20)
            ),
            BoxShadow(
                color: Color(0xFB989898),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(3, 3)
            ),
            BoxShadow(
              color: Color(0xFBBDB9B9),
              spreadRadius: 3,
              blurRadius: 20,
              offset: Offset(5, 10)
            )
          ]
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Image.asset('assets/icons/key.png', height: 50,),
            SizedBox(height: 30),
            Expanded(
              child: Text('Вы не авторизованы. Необходимо авторизоваться в приложении. \r\nЛогин - корпоративная почта, привязанная к ЕRP. Пароль - пароль от ERP.',
                style: TextStyle(fontSize: 15), textAlign: TextAlign.justify,
              )
            ),
            SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              child: Ink(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Color(0xFB2D55FF),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.auth);
                  },
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  splashColor: Color(0xFB6A89FF),
                  child: Center(
                    child: Text('Авторизоваться', style: TextStyle(fontSize: 16, color: Colors.white))
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
