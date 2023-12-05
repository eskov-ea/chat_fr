import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../models/dialog_model.dart';
import '../../models/message_model.dart';
import 'package:http/http.dart' as http;
import '../../storage/data_storage.dart';
import 'dart:ui' as UI;
import 'package:image/image.dart' as IMG;
import 'dart:typed_data' as typedData;
import 'dart:convert' as convert;
import '../logger/logger_service.dart';
import './icon_base64.dart';

class MessagesProvider {
  final _secureStorage = DataProvider();


  Future <List<MessageData>> getMessages(userId, dialogId, pageNumber) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<MessageData> messages = collection.map((message) => MessageData.fromJson(message)).toList();
        return messages;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber');
    } on AppErrorException{
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber');
    }
  }

  Future<Map<String, dynamic>?> getNewUpdatesOnResume() async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/pull/4000'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> collection = jsonDecode(response.body)["data"];
        return collection;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/pull/4000');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/pull/4000');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/pull/4000');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/pull/4000');
    }
  }

  Future<String> sendTextMessage({
    required dialogId,
    required messageText,
    required parentMessageId
  }) async {
    try {
      final String? token = await _secureStorage.getToken();
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '$messageText',
          'parent_id': parentMessageId
        }
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData
      );
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    }
  }

  Future<void> updateMessageStatuses({required int dialogId}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final res = await http.get(
          Uri.parse('https://erp.mcfef.com/api/chat/message/setchatred/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          }
      );
      //TODO: process 401 error
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> deleteMessage({
    required List<int> messageId,
  }) async {
    print('DELETING MESSAGE');
    try {
      final String? token = await _secureStorage.getToken();
      final List data = messageId.map((id) => {
        'id': id,
        'status_id': 5
      }).toList();
      final postData = jsonEncode(<String, Object>{
        'data': data
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/setstatuses'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: postData
      );
      print(response.body);
      if (response.statusCode == 200){
        return true;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/setstatuses');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/setstatuses');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/setstatuses');
    } on AppErrorException {
      rethrow;
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/setstatuses');
    }
  }

  Future<int?> createDialog ({required userId, required partnerId, required message}) async {
    try {
      final response = await http.post(
        Uri.parse('https://web-notifications.ru/api/dialogs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'partnerId': partnerId,
          'text': message
        }),
      );

      if (response.statusCode == 200) {
        DialogId dialog = DialogId.fromJson(jsonDecode(response.body));
        return dialog.dialogId;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://web-notifications.ru/api/dialogs');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://web-notifications.ru/api/dialogs');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://web-notifications.ru/api/dialogs');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://web-notifications.ru/api/dialogs');
    }
  }

  Future<MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/message/file/$attachmentId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        return MessageAttachmentsData.fromJson(jsonDecode(response.body)["data"]);
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/file/$attachmentId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/file/$attachmentId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/file/$attachmentId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/file/$attachmentId');
    }
  }

  Future<String> sendAudioMessage({
    required String? filename,
    required int dialogId,
    required String? messageText,
    required String? filetype,
    required int? parentMessageId,
    required String? content
  }) async {
    print('SENDING MESSAGE WITh AUDIO FILE');
    try {
      final String? token = await _secureStorage.getToken();
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '',
          'parent_id': parentMessageId,
          'file': {
            'name': '$filename.$filetype',
            'preview': base64icon,
            'content': content
          }
        }
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData);
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    }
  }

  Future<String> sendMessageWithFileBase64({
    required String? filename,
    required int dialogId,
    required String? messageText,
    required String? filetype,
    required int? parentMessageId,
    required Uint8List? bytes,
    required String? content
  }) async {
    print('SENDING MESSAGE WITh FILE');
    try {
      final String? token = await _secureStorage.getToken();
      final preview = resizeImage(bytes!);

      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '$messageText',
          'parent_id': parentMessageId,
          'file': {
            'name': '$filename.$filetype',
            'preview': preview ?? base64icon,
            'content': content
          }
        }
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData);
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/message/add/$dialogId');
    }
  }

  Future<String> sendMessageWithFileBase64ForWeb({
    required String base64,
    required int dialogId,
    required String filetype,
    required int? parentMessageId,
    required Uint8List? bytes
  }) async {
    print('SENDING MESSAGE WITh FILE WEB');
    try {
      final String? token = await _secureStorage.getToken();
      final uniq = DateTime.now().microsecondsSinceEpoch.toString();
      final preview = await resizeImageWeb(bytes);
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '',
          'parent_id': parentMessageId,
          'file': {
            'name': '$uniq.$filetype',
            'preview': preview ?? base64icon,
            'content': base64
          }
        }
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
            location: 'WEB:: https://erp.mcfef.com/api/chat/message/add/$dialogId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
            location: 'WEB:: https://erp.mcfef.com/api/chat/message/add/$dialogId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'WEB:: https://erp.mcfef.com/api/chat/message/add/$dialogId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'WEB:: https://erp.mcfef.com/api/chat/message/add/$dialogId');
    }
  }

}


Future<XFile> _compressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: 20,
  );


  return result!;
}

Future<File> createTemporaryFile() async {
  final dir = await getTemporaryDirectory();
  final file = File("${dir.absolute.path}/temporary_cropped_file.jpg");
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  return file;
}

/// file as bites
// Future<Uint8List?> testCompressFile(File file) async {
//   print("testCompressFile");
//   final result = await FlutterImageCompress.compressWithFile(
//     file.absolute.path,
//     minWidth: 2300,
//     minHeight: 1500,
//     quality: 50,
//     rotate: 180,
//   );
//   print(file.lengthSync());
//   print(result?.length);
//   return result;
// }

String? resizeImage(Uint8List data) {
  try {
    IMG.Image img = IMG.decodeImage(data)!;
    IMG.Image resized = IMG.copyResize(img, width: 8);
    final resizedData = IMG.encodeJpg(resized);
    final base64resizedData = base64Encode(resizedData);
    return base64resizedData;
  } catch(err) {
    print("Resize error --> $err");
    return null;
  }
}

resizeImageWeb(Uint8List? bytes) async {

  if (bytes == null) return "";
  var codec = await UI.instantiateImageCodec(bytes,
      targetHeight: 200, targetWidth: 200, allowUpscaling: false);
  var frameInfo = await codec.getNextFrame();
  UI.Image targetUiImage = frameInfo.image;

  ByteData? targetByteData =
  await targetUiImage.toByteData(format: UI.ImageByteFormat.png);
  print('resized image WxH size is ${targetUiImage.width}x${targetUiImage.width}');
  final Uint8List targetlUinit8List = targetByteData!.buffer.asUint8List();

  String resizedBase64Image = convert.base64Encode(targetlUinit8List);
  print('resized image base64 size is ${resizedBase64Image.length}');
  return resizedBase64Image;
}
