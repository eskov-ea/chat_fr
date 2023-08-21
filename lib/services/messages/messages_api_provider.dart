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
  final _logger = Logger.getInstance();


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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.getMessages");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.getMessages");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.getMessages");
    } on AppErrorException{
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.getMessages", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.getMessages");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.getNewUpdatesOnResume");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.getNewUpdatesOnResume");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.getNewUpdatesOnResume");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      print("MessagesProvider err   $err");
      _logger.sendErrorTrace(message: "MessagesProvider.getNewUpdatesOnResume", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.getNewUpdatesOnResume");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.sendMessage");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.sendMessage");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.sendMessage");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.sendMessage", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.sendMessage");
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
      print(" RESPONSE UPDATE ${res.body}");
      //TODO: process 401 error
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.updateMessageStatuses", err: err.toString());
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.deleteMessage");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.deleteMessage");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.sendMessage");
    } on AppErrorException {
      rethrow;
    } catch(err) {
      _logger.sendErrorTrace(message: "MessagesProvider.deleteMessage", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.deleteMessage");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.createDialogAndSendMessage");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.createDialogAndSendMessage");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.createDialogAndSendMessage");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.createDialogAndSendMessage", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.createDialogAndSendMessage");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.loadAttachmentData");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.loadAttachmentData");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.loadAttachmentData");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.loadAttachmentData", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.loadAttachmentData");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.sendAudioMessage");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.sendAudioMessage");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.sendAudioMessage");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.sendAudioMessage", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.sendAudioMessage");
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
      print("base64file postData   $postData");
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
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.sendMessageWithFileBase64");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.sendMessageWithFileBase64");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.sendMessageWithFileBase64");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      _logger.sendErrorTrace(message: "MessagesProvider.sendMessageWithFileBase64", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "MessagesProvider.sendMessageWithFileBase64");
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
      print("RESPONSEIMAGE   ${response.body}");

      return response.body;
    } catch (err) {
      print("sendMessageWithFileBase64ForWeb $err");
      _logger.sendErrorTrace(message: "MessagesProvider.sendMessageWithFileBase64", err: err.toString());
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
