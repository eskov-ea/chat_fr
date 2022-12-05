import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;




class SockerProvider {


  IOWebSocketChannel? channel = null;
  final String token = "145|p3JA4kcRwOuQkvsccB2pRN92EKshsoywQF03rVs9";
  late final String socketId;
  late final String authKey;
  var isGetSocketId = false;

  void connect() async {
    print("SockerProvider INITIALIZED");
    if (channel != null) {
      print("Channel exist");
      return;
    }
    channel = IOWebSocketChannel.connect("wss://erp.mcfef.com:6001/app/key?protocol=7&client=js&version=7.0.6&flash=false");
    // , headers: {'Connection': 'upgrade', 'Upgrade': 'websocket'}
    // final channel =  WebSocketChannel.connect(Uri.parse('wss://10.0.1.98:6001'), headers: {'Connection': 'upgrade', 'Upgrade': 'websocket'});
    // final channel =  WebSocketChannel.connect(Uri.parse('wss://erp.mcfef.com:6001'));

    // channel.stream.listen((message) {
    //   channel.sink.add('received!');
    //   channel.sink.close(status.goingAway);
    // });



    print(channel!.closeReason);
    channel!.stream.listen(
         (data) {
       print("data is $data");
       if (!isGetSocketId){
          socketId = jsonDecode(jsonDecode(data)["data"])["socket_id"];
          print(socketId);
          isGetSocketId = true;
        }
      },
     onError: (error) => print("error  $error"),
   );

  }

  sendPing(){
    channel!.sink.add('{"event":"pusher:ping","data":{}}');
  }

  auth() async
  {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://erp.mcfef.com/broadcasting/auth'));
    request.fields['socket_id'] = socketId;
    request.fields['channel_name'] = 'private-chat.2';
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    request.headers['Accept'] = '*/*';
    // request.files.add(file);

    final response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    authKey = jsonDecode(responseString)["auth"];
    print(jsonDecode(responseString));
  }
  subscribe() async {
    // channel!.sink.add('{"event":"pusher:subscribe","data":{"auth":"${authKey}","channel":"private-chatinfo"}}');
    channel!.sink.add('{"event":"pusher:subscribe","data":{"auth":"${authKey}","channel":"private-chat.2"}}');
    // channel!.sink.add('{"event":"pusher:subscribe","data":{"auth":"${authKey}","channel":"private-chat.3"}}');
    // channel!.sink.add('{"event":"pusher:subscribe","data":"{\\"auth\\":\\"$authKey\\",\\"channel\\":\\"private-chatinfo\\"}"}');
  }
}