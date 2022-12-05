import 'package:flutter/material.dart';

class IncomingCall extends StatelessWidget {
  const IncomingCall({
    required this.user,
    required this.acceptCallback,
    Key? key
  }) : super(key: key);

  final String user;
  final Function acceptCallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black87,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user, style: const TextStyle(color: Colors.white, fontSize: 24),),
            SizedBox(height: 100,),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: (){
                    print("Decline");
                  },
                  child: const Text('Decline'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    fixedSize: MaterialStateProperty.all(const Size(120, 70))
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    print("Accept");
                    acceptCallback();
                  },
                  child: const Text('Accept'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      fixedSize: MaterialStateProperty.all(const Size(120, 70))
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
