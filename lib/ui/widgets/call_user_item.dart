// import 'package:chat/ui/widgets/avatar_widget.dart';
// import 'package:flutter/material.dart';
// import '../../models/contact_model.dart';
// import '../../services/global.dart';
//
// class CallUserItem extends StatelessWidget {
//   const CallUserItem({
//     Key? key,
//     required this.user
//   }) : super(key: key);
//
//   final UserContact user;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
//       child: GestureDetector(
//         onTap:() {
//           callNumber(context, user.id.toString());
//         },
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AvatarWidget(userId: user.id, size: 21),
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.lastname + " " + user.firstname,
//                       style: const TextStyle(fontSize: 16),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                       softWrap: false,
//                     ),
//                     Container(
//                       width: MediaQuery.of(context).size.width * 0.6,
//                       child: Row(
//                         children: const [
//                           Icon(Icons.phone, size: 20,),
//                           SizedBox(width: 10,),
//                           Text(
//                             "Входящий",
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(fontSize: 12),
//                             maxLines: 1,
//                             softWrap: false,
//                           ),
//                         ]
//                       ),
//                     ),
//                   ]
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }