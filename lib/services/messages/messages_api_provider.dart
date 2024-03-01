import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat/services/helpers/file_types_helper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../models/message_model.dart';
import 'package:http/http.dart' as http;
import '../../storage/data_storage.dart';
import 'dart:ui' as UI;
import 'package:image/image.dart' as IMG;
import 'dart:convert' as convert;
import '../helpers/http_error_handler.dart';
import '../logger/logger_service.dart';
import './icon_base64.dart';




class MessagesProvider {
  final _secureStorage = DataProvider.storage;


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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<MessageData> messages = collection.map((message) => MessageData.fromJson(message)).toList();
      return messages;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/pagepull/$dialogId/$pageNumber ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException{
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      Map<String, dynamic> collection = jsonDecode(response.body)["data"];
      return collection;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/pull/4000 ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return response.body;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/add/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<void> updateMessageStatuses({required int dialogId}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
          Uri.parse('https://erp.mcfef.com/api/chat/message/setchatred/$dialogId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          }
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/setchatred/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return true;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/setstatuses ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<MessageAttachmentData?> loadAttachmentData({required String attachmentId}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/message/file/$attachmentId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return MessageAttachmentData.fromJson(jsonDecode(response.body)["data"]);
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/file/$attachmentId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return response.body;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/add/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
    try {
      String? preview;
      final String? token = await _secureStorage.getToken();

      if (GraphicTypes.contains(filetype) && bytes != null) {
        preview = resizeImage(bytes);
      }

      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '$messageText',
          'parent_id': parentMessageId,
          'file': {
            'name': '$filename.$filetype',
            'preview': preview ?? '',
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return response.body;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/add/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<String> forwardMessage({
    required String? filename,
    required int dialogId,
    required String? messageText,
    required String? filetype,
    required String? preview,
    required String? content
  }) async {
    try {
      String? preview;
      final String? token = await _secureStorage.getToken();

      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': '$messageText',
          'parent_id': null,
          'file': {
            'name': '$filename.$filetype',
            'preview': preview ?? '',
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
      log("FORWARD:: ${response.body}");
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return response.body;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/add/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<String> sendMessageWithFileBase64ForWeb({
    required String base64,
    required int dialogId,
    required String filetype,
    required int? parentMessageId,
    required Uint8List? bytes
  }) async {
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

      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return response.body;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/add/$dialogId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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



// Future<int?> createDialog ({required userId, required partnerId, required message}) async {
//   try {
//     final response = await http.post(
//       Uri.parse('https://web-notifications.ru/api/dialogs'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'userId': userId,
//         'partnerId': partnerId,
//         'text': message
//       }),
//     );
//
//     HttpErrorHandler.handleHttpResponse(response);
//     DialogId dialog = DialogId.fromJson(jsonDecode(response.body));
//     return dialog.dialogId;
//   } on SocketException catch(err, stackTrace) {
//     Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
//         "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/message/setstatuses ]");
//     throw AppErrorException(AppErrorExceptionType.network);
//   } on AppErrorException {
//     rethrow;
//   } catch (err, stackTrace) {
//     Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
//     throw AppErrorException(AppErrorExceptionType.other);
//   }
// }
