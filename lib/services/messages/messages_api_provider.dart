import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/dialog_model.dart';
import '../../models/message_model.dart';
import 'package:http/http.dart' as http;
import '../../storage/data_storage.dart';
import 'dart:ui' as UI;
import 'package:image/image.dart' as IMG;
import 'dart:typed_data' as typedData;
import 'dart:convert' as convert;
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
        // TODO: implement logout
        return <MessageData>[];
      } else {
        return <MessageData>[];
      }
    } catch (err) {
      print(err);
      return <MessageData>[];
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
        // print("update collection     -.   $collection");
        return collection;
      } else if (response.statusCode == 401) {
        // TODO: implement logout
        throw Exception("Необходимо авторизоваться");
      } else {
        throw Exception("Произошла ошибка при отправке сообщения, повторите еще раз");
      }
    } catch (err) {
      print(err);
      throw Exception("Произошла ошибка при отправке сообщения, повторите еще раз");
    }
  }

  Future<String> sendMessage({
    required dialogId,
    required messageText,
    required parentMessageId
  }) async {
    print('SENDING MESSAGE parent  $parentMessageId');
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
    return response.body;
  }

  Future<void> updateMessageStatuses({required int dialogId}) async {
    final String? token = await _secureStorage.getToken();
    final res = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/message/setchatred/$dialogId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        }
    );
    print(" RESPONSE UPDATE ${res.body}");
    //TODO: process 401 error
  }

  Future<bool> deleteMessage({
    required List<int> messageId,
  }) async {
    print('DELETING MESSAGE');
    final String? token = await _secureStorage.getToken();
    final List data = messageId.map((id) => {
      'id': id,
      'status_id': 5
    }).toList();
    final postData = jsonEncode(<String, Object>{
      'data': data
    });
    print("DELETING MESSAGE data  $postData");
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
    } else {
      return false;
    }
  }

  Future<int?> createDialogAndSendMessage ({required userId, required partnerId, required message}) async {
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

    if (response.statusCode == 200){
      DialogId dialog = DialogId.fromJson(jsonDecode(response.body));
      return dialog.dialogId;
    } else {
      return null;
    }
  }

  Future<MessageAttachmentsData?> loadAttachmentData({required String attachmentId}) async {
    final String? token = await _secureStorage.getToken();
    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/chat/message/file/$attachmentId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    print("decoded file   ${response.body}");
    if (response.statusCode == 200) {
      return MessageAttachmentsData.fromJson(jsonDecode(response.body)["data"]);
    } else {
      return null;
    }
  }

  Future sendAudioMessage({
    required filePath,
    required userId,
    required dialogId,
    required filetype,
    required parentMessageId
  }) async {
    print('SENDING MESSAGE WITh AUDIO FILE');
    try {
      final String? token = await _secureStorage.getToken();
      final bytes = File(filePath).readAsBytesSync();
      String base64file = base64Encode(bytes);
      final uniq = DateTime.now().microsecondsSinceEpoch.toString();
      print(base64file);
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '',
          'parent_id': parentMessageId,
          'file': {
            'name': '$uniq.$filetype',
            'preview': base64icon,
            'content': base64file
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
      print("AUDIORESPONSE    ${response.body}");
      return response.body;
    } catch (err) {
      print("sendAudioMessage $err");
      throw Exception('Error sending audio message');
    }
  }

  Future<String> sendMessageWithFileBase64({
    required filePath,
    required dialogId,
    required messageText,
    required filetype,
    required parentMessageId
  }) async {
    print('SENDING MESSAGE WITh FILE');
    final String? token = await _secureStorage.getToken();
    final bytes = File(filePath.path).readAsBytesSync();
    final uniq = DateTime.now().microsecondsSinceEpoch.toString();
    String base64Image = base64Encode(bytes);
    final preview = resizeImage(bytes);
    print("base64file   $base64Image");

    final postData = jsonEncode(<String, Object>{
      'data': {
        'message': '$messageText',
        'parent_id': parentMessageId,
        'file': {
          'name': '$uniq.$filetype',
          'preview': preview ?? base64icon,
          'content': base64Image
        }
      }
    });
    print("base64file postData   $postData");
    try {
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData);
      print(response.body);
      return response.body;
    } catch (err) {
      print("sendMessageWithFileBase64 $err");
      throw Exception('Error sending file base64 message');
    }
  }

  Future<String> sendMessageWithFileBase64ForWeb({
    required String base64,
    required int dialogId,
    required String filetype,
    required int parentMessageId,
    required Uint8List? bytes
  }) async {
    print('SENDING MESSAGE WITh FILE WEB');
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
    try {
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData);
      print("RESPONSEIMAGE   ${response.body}");

      return response.body;
    } catch (err) {
      print("sendMessageWithFileBase64ForWeb $err");
      throw Exception('Error sending file base64 message on web');
    }
  }

}



Future<File> _compressAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: 20,
  );

  print(file.lengthSync());
  print(result?.lengthSync());

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
Future<Uint8List?> testCompressFile(File file) async {
  print("testCompressFile");
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 2300,
    minHeight: 1500,
    quality: 50,
    rotate: 180,
  );
  print(file.lengthSync());
  print(result?.length);
  return result;
}

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



/** DEPRECATED */
// Future<String> sendMessageWithImageFileBase64({
//   required file,
//   required dialogId,
//   required messageText,
//   required filetype,
//   required parentMessageId
// }) async {
//   print('SENDING MESSAGE WITh FILE');
//   try {
//     final String? token = await _secureStorage.getToken();
//     final tmpFileCompressed = await createTemporaryFile();
//     final compressedFile =
//         await _compressAndGetFile(file, tmpFileCompressed.path);
//     final bytesCompressed = File(compressedFile.path).readAsBytesSync();
//     final preview = resizeImage(bytesCompressed);
//     final uniq = DateTime.now().microsecondsSinceEpoch.toString();
//     String base64Image = base64Encode(bytesCompressed);
//
//     final postData = jsonEncode(<String, Object>{
//       'data': {
//         'message': '$messageText',
//         'parent_id': parentMessageId,
//         'file': {
//           'name': '$uniq.$filetype',
//           'preview': preview,
//           'content': base64Image
//         }
//       }
//     });
//     final response = await http.post(
//         Uri.parse('https://erp.mcfef.com/api/chat/message/add/$dialogId'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': 'Bearer $token'
//         },
//         body: postData);
//     print("RESPONSEIMAGE   ${response.body}");
//
//     compressedFile.delete();
//     return response.body;
//   } catch (err) {
//     print("sendMessageWithImageFileBase64 $err");
//     throw Exception('Error sending image base64 message');
//   }
// }