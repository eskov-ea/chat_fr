import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/dialog_model.dart';
import '../../storage/data_storage.dart';


class DialogsProvider {
  final _secureStorage = DataProvider();

  Future<List<DialogData>?> getDialogs() async {
    final String? token = await _secureStorage.getToken();

    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/chat/chats'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> collection = jsonDecode(response.body)["data"];
      print("collection   $collection");
// for (var us in collection) {
      //   print("USERSSS  ${us["staff"]["firstname"]}");
      // }
      List<DialogData> dialogs = collection.map((dialog) => DialogData.fromJson(dialog)).toList();
      print("collection   $dialogs");
      return dialogs;
    } else {
      return null;
    }
  }



  Future<DialogData?> createDialog({required chatType, required users, required chatName, required chatDescription}) async {
    final String? token = await _secureStorage.getToken();
    final response = await http.post(
      Uri.parse('https://erp.mcfef.com/api/chat/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode( <String, dynamic>{
        'data': {
          'chat_type_id': chatType,
          'users': users,
          'name': chatName,
          'description': chatDescription
        }
      }),
    );
    print("CREATE DIALOG  -->  ${response.body}");
    if (response.statusCode == 200){
      DialogData dialog = DialogData.fromJson(jsonDecode(response.body)["data"]);
      return dialog;
    } else {
      return null;
    }
  }

  Future<DialogData?> joinDialog(userId, dialogId) async {
    final String? token = await _secureStorage.getToken();

    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/chat/join/$dialogId/$userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print("JOINDIALOG  ${response.body}");
  }

  Future<DialogData?> exitDialog(userId, dialogId) async {
    final String? token = await _secureStorage.getToken();

    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/chat/exit/$dialogId/$userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print("EXITDIALOG  ${response.body}");
  }

}