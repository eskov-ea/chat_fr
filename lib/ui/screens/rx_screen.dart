// import 'dart:async';
//
// import 'package:chat/rx_repository/ws_repositor_interface.dart';
// import 'package:chat/rx_repository/ws_repository.dart';
// import 'package:chat/services/database/db_provider.dart';
// import 'package:flutter/material.dart';
//
// class RXScreen extends StatefulWidget {
//   const RXScreen({super.key});
//
//   @override
//   State<RXScreen> createState() => _RXScreenState();
// }
//
// class _RXScreenState extends State<RXScreen> {
//
//   final _br = const BorderRadius.all(Radius.circular(8));
//   final _repo = WebsocketRepository.instance;
//   WebsocketState state = WebsocketState.unconnected;
//   Map<String, dynamic>? lastEventData;
//   String? lastEventName;
//   final db = DBProvider.db;
//   late final StreamSubscription<WebsocketStatePayload> _stateSubscription;
//   late final StreamSubscription<WebsocketEventPayload> _eventSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _stateSubscription = _repo.state.listen((event) {
//       print('RX state::  $event');
//       setState(() {
//         state = event.state;
//       });
//     });
//     _eventSubscription = _repo.events.listen((event) {
//       print('RX event::  ${event.event}: ${event.data}');
//       setState(() {
//         lastEventData = event.data;
//         lastEventName = event.event.toString();
//       });
//     });
//
//
//     db.getDialogs().then((dialogs) {
//       print('We start connection');
//       _repo.connect(dialogs);
//     });
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             SizedBox(height: 100),
//             Container(
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: _br,
//                 color: Colors.black26
//               ),
//               child: Text('Websocket state: ${state.toString()}'),
//             ),
//             SizedBox(height: 100),
//             ElevatedButton(onPressed: () {
//               final repo = WebsocketRepository.instance;
//               print('Repo time creation:  ${repo.currentState}');
//             }, child: Text('Create repo'))
//           ],
//         ),
//       ),
//     );
//   }
// }
