import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// void connect() {
//   IO.Socket socket = IO.io('https://web-notifications.ru', <String, dynamic> {
//     "transports": ["websocket"],
//     "autoConnect": false
//   });
//   socket.connect();
//   socket.onConnect((_) {
//     print("=============================================================================================================================================");
//     print('websocket connected');
//     socket.emit('SIGNIN', '62676910fb282aa9270e9d1a');
//     // socket.emit('msg', 'test');
//   });
//   socket.on('SERVER:NEW_MESSAGE', (data) => print(data));
// }

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    // connect();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Text('Truing to connect to websocket');
  }
}
