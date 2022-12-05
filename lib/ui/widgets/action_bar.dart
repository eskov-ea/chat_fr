import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/chats_builder_bloc/chats_builder_state.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/message_model.dart' as parseTime;
import 'package:chat/services/global.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../bloc/chats_builder_bloc/chats_builder_bloc.dart';
import '../../bloc/chats_builder_bloc/chats_builder_event.dart';
import '../../models/chat_builder_model.dart';
import '../../models/dialog_model.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../../services/messages/messages_api_provider.dart';
import '../../services/messages/messages_repository.dart';
import '../../theme.dart';
import '../pages/sending_image_object_options_page.dart';
import 'glowing_action_button.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audio_session/audio_session.dart';
import 'dart:typed_data';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';


typedef RecordCallback = void Function(String);


class ActionBar extends StatefulWidget {
  final int userId;
  int? dialogId;
  final int partnerId;
  final String username;
  final Function setDialogData;
  final Function cancelReplyMessage;
  final Widget rootWidget;
  final FocusNode focusNode;
  final int? replyedMessageId;
  final Function setRecording;
  final bool isRecording;
  final DialogData? dialogData;
  final DialogsViewCubit dialogCubit;
  final ParentMessage? parentMessage;

  ActionBar({
    required this.userId,
    required this.dialogId,
    required this.partnerId,
    required this.replyedMessageId,
    required this.setDialogData,
    required this.cancelReplyMessage,
    required this.rootWidget,
    required this.username,
    required this.focusNode,
    required this.setRecording,
    required this.isRecording,
    required this.dialogData,
    required this.dialogCubit,
    required this.parentMessage,
    Key? key,})
      : super(key: key);

  @override
  State<ActionBar> createState() => ActionBarState();
}

class ActionBarState extends State<ActionBar> {
  final messagesRepository = MessagesRepository();
  final TextEditingController _messageController = TextEditingController();
  bool sendButton = false;
  bool isSendButtonDisabled = false;
  // final _audioRecorder = Record();
  final _audioRecorder = FlutterSoundRecorder();
  Codec _codec = Codec.aacMP4;
  String _mPath = 'voice.mp4';
  bool _mRecorderIsInited = false;
  double _mSubscriptionDuration = 0;
  StreamSubscription? _recorderSubscription;
  int recordingDuration = 0;
  double dbLevel = 0;
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }
  @override
  void dispose() {
    stopRecorder(_mRecorder);
    cancelRecorderSubscriptions();

    // Be careful : you must `close` the audio session when you have finished with it.
    _mRecorder.closeRecorder();

    super.dispose();
  }
  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }
  Future<void> openTheRecorder() async {
    // if (!kIsWeb) {
      // var status = await Permission.microphone.request();
      // var status = true;
      // if (status != true) {
        // throw RecordingPermissionException('Microphone permission not granted');
      // }
    // }
    final path = await getTemporaryDirectory();
    _mPath = path.path + '/' + _mPath;
    print("_mPath   -->  $_mPath");
    await _mRecorder.openRecorder();
    if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
      // _codec = Codec.opusWebM;
      if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }
  Future<void> init() async {
    print("INIR RECORDER");
    await openTheRecorder();
    _mRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorderSubscription = _mRecorder.onProgress!.listen((e) {
      setState(() {
        recordingDuration = e.duration.inSeconds;
        if (e.decibels != null) {
          dbLevel = e.decibels as double;
        }
      });
    });
  }
  Future<void> stopRecorder(FlutterSoundRecorder recorder) async {
    await recorder.stopRecorder();
  }
  void record(FlutterSoundRecorder? recorder) async {
    await recorder!.startRecorder(codec: _codec, toFile: _mPath);
    setState(() {});
  }

  _start(FlutterSoundRecorder? recorder) async {
    try {
      if (!_mRecorderIsInited) {
        return null;
      }
      record(recorder);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _stop(FlutterSoundRecorder recorder) async {
    final result = await recorder.stopRecorder();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      color: AppColors.backgroundLight,
      child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 3.0),
                    child: GestureDetector(
                      onTap: (){
                        // TODO: implement taking/ sending pictures/ files functionality
                        openCameraOptions(createDialogAndSendMessage);
                      },
                      child: widget.isRecording
                        ? Text(
                            getAudioMessageDuration(recordingDuration),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : const Icon(
                        CupertinoIcons.paperclip, color: AppColors.secondary, size: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 10.0, bottom:  10.0),
                    child: TextFormField(
                      maxLines: 10,
                      minLines: 1,
                      focusNode: widget.focusNode,
                      controller: _messageController,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            sendButton = true;
                          });
                        } else {
                          setState(() {
                            sendButton = false;
                          });
                        }
                      },
                      style: const TextStyle(fontSize: 16, color: LightColors.mainText),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black45,
                            width: 1
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        hintText: 'Type something...',
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black45,
                                width: 1
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 24.0,
                  ),
                  child: GestureDetector(
                    onLongPressStart: (details){
                      print('START LONG PRESS');
                      // TODO: implement recording voice messages functionality
                      widget.setRecording(true);
                      if (sendButton == false) _start(_mRecorder);
                    },
                    onLongPressEnd: (details) async {
                      print('END LONG PRESS');
                      final recordedAudio = await _stop(_mRecorder);
                      widget.setRecording(false);
                      final File file = File(_mPath!);
                      final String filetype = file.path.split('.').last;
                      print("recordedAudio  --> $recordedAudio");
                      _sendAudioMessage(file.path, widget.userId, widget.dialogId, filetype );
                      },
                    child: GlowingActionButton(
                      color: isSendButtonDisabled ? Colors.grey : widget.isRecording ? Colors.red : AppColors.accent ,
                      icon: !kIsWeb
                          ? sendButton ? Icons.send_rounded : Icons.mic
                          : sendButton ? Icons.send_rounded : Icons.send_rounded,
                      onPressed: () async {
                        if (isSendButtonDisabled || !sendButton || _messageController.text.trim() == "") return;
                        if (widget.dialogId != null) {
                          _sendMessage(context, widget.parentMessage);
                          widget.cancelReplyMessage();
                        } else {
                          await createDialogAndSendMessage(context, widget.rootWidget);
                          _sendMessage(context, widget.parentMessage);
                          widget.cancelReplyMessage();
                        }
                        setState(() {
                          sendButton = false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void openCameraOptions(createDialogFn) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SendingObjectOptionsPage(
        context: context,
        dialogId: widget.dialogId,
        messageController: _messageController,
        username: widget.username,
        userId: widget.userId,
        createDialogFn: createDialogFn,
        parentMessageId: widget.replyedMessageId
      ),
    );
  }
  void openAudioMessageOptions(BuildContext context, path){
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(),
    );
  }

  _sendMessage(context, ParentMessage? parentMessage) async {
    try {
      final messageText = _messageController.text;
      _messageController.clear();
      final localMessage = createLocalMessage(replyedMessageId: widget.replyedMessageId,
          dialogId: widget.dialogId!, messageText: messageText, parentMessage: widget.parentMessage, userId: widget.userId);
      print("localMessage  $localMessage");
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderAddMessageEvent(message: localMessage, dialog: widget.dialogId!)
      );
      // TODO: if response status code is 200 else ..
      final sentMessage = await MessagesRepository().sendMessage(dialogId: widget.dialogId!, messageText: messageText, parentMessageId: widget.replyedMessageId);
      print("sentMessage  $sentMessage");
      final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
      BlocProvider.of<ChatsBuilderBloc>(context).add(
          ChatsBuilderUpdateLocalMessageEvent(message: message, dialogId: widget.dialogId!, messageId: localMessage.messageId)
      );
      widget.dialogCubit.updateLastDialogMessage(localMessage);
    } catch (err) {
      print(err);
    }
    BlocProvider.of<ChatsBuilderBloc>(context).add(ChatsBuilderUpdateStatusMessagesEvent(dialogId: widget.dialogId!));
    setState(() {
      isSendButtonDisabled = false;
    });
  }
  void _sendAudioMessage (String filePath, userId, dialogId, String filetype) async {
    if (dialogId == null) {
      await createDialogAndSendMessage(context, widget.rootWidget);
      dialogId = widget.dialogId;
    }
    final sentMessage = await MessagesProvider().sendAudioMessage(
        filePath: filePath,
        userId: userId,
        dialogId: dialogId,
        filetype: filetype,
        parentMessageId: widget.replyedMessageId
    );
    final message = MessageData.fromJson(jsonDecode(sentMessage)["data"]);
    print("SENTMESSAGE  -->  ${message.file}");
    BlocProvider.of<ChatsBuilderBloc>(context).add(
        ChatsBuilderAddMessageEvent(message: message, dialog: widget.dialogId!)
    );

  }
  createDialogAndSendMessage(context, rootWidget) async {
    print("CREATE DIALOG");
    //TODO: optimize two sending message and create dialog-sending message methods  ---- first need to create dialog and then send message
    setState(() {
      isSendButtonDisabled = true;
    });
    try {
      final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [widget.partnerId], chatName: "p2p", chatDescription: null);
      setState(() {
        widget.dialogId = newDialog?.dialogId;
      });
      final chatsBuilderBloc = BlocProvider.of<ChatsBuilderBloc>(context);
      final initLength = chatsBuilderBloc.state.chats.length;
      whenFinishAddingDialog(Stream<ChatsBuilderState> source) async {
        chatsBuilderBloc.add(ChatsBuilderLoadMessagesEvent(dialogId: widget.dialogId!));
        await for (var value in source) {
          if (value.chats.length > initLength) {
            return;
          }
        }
      }
      await whenFinishAddingDialog(chatsBuilderBloc.stream);
      if (newDialog!= null) {
        widget.setDialogData(widget.rootWidget, newDialog);
      }
      // _sendMessage(context);
    } catch(err) {
      print(err);
    }
    setState(() {
      isSendButtonDisabled = false;
    });
  }

}