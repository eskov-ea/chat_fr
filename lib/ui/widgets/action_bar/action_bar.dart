import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_events.dart';
import 'package:chat/bloc/messge_bloc/message_bloc.dart';
import 'package:chat/bloc/messge_bloc/message_event.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/client_error_handler.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/ui/screens/chat_screen.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/dialog_model.dart';
import '../../../services/dialogs/dialogs_api_provider.dart';
import '../../../services/helpers/message_sender_helper.dart';
import '../../../services/messages/messages_repository.dart';
import '../../../theme.dart';
import '../../pages/sending_image_object_options_page.dart';
import '../glowing_action_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audio_session/audio_session.dart';
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
  final Function setRecording;
  final bool isRecording;
  final DialogData? dialogData;
  final DialogsViewCubit dialogCubit;
  final RepliedMessage? parentMessage;
  final List<SelectedMessage> selected;
  final bool isSelectedMode;
  final Function() deleteMessages;
  final Function(List<SelectedMessage>) openForwardMessageMenu;
  final AnimationController animationController;
  final Animation animation;
  final String dirPath;

  ActionBar({
    required this.userId,
    required this.dialogId,
    required this.partnerId,
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
    required this.selected,
    required this.isSelectedMode,
    required this.deleteMessages,
    required this.openForwardMessageMenu,
    required this.animationController,
    required this.animation,
    required this.dirPath,
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
  Codec _codec = Codec.aacMP4;
  String _mPath = 'voice.mp4';
  bool _mRecorderIsInited = false;
  StreamSubscription? _recorderSubscription;
  int recordingDuration = 0;
  double dbLevel = 0;
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  final Logger _logger = Logger.getInstance();


  @override
  void initState() {
    init().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    if (widget.dialogId != null) {
      final earlierTypedText = DataProvider.storage.getMessageText(widget.dialogId!);
      if (earlierTypedText != null) _messageController.text = earlierTypedText;
    }
    super.initState();
  }
  @override
  void dispose() {
    stopRecorder(_mRecorder);
    cancelRecorderSubscriptions();
    _mRecorder.closeRecorder();
    if (widget.dialogId != null) {
      DataProvider.storage.setMessageText(widget.dialogId!, _messageController.text);
    }
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
    //   var status = await Permission.microphone.request();
    //   if (status != true) {
    //     throw RecordingPermissionException('Microphone permission not granted');
    //   }
    // }
    final path = await getTemporaryDirectory();
    _mPath = path.path + '/' + _mPath;
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
    print("INIT RECORDER");
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
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ClientErrorHandler.informErrorHappened(context, "Доступ к микрофону отключен. Включить доступ можно в настройках.");
      return;
    }

    await recorder!.startRecorder(codec: _codec, toFile: _mPath, audioSource: AudioSource.microphone);
    setState(() {});
  }

  _start(FlutterSoundRecorder? recorder) async {
    try {
      if (!_mRecorderIsInited) {
        return null;
      }
      record(recorder);
    } catch (err, stackTrace) {
      ClientErrorHandler.informErrorHappened(context, "Произошла ошибка при записи голосового сообщения. Попробуйте еще раз.", type: PopupType.warning);
      _logger.sendErrorTrace(stackTrace: stackTrace);
    }
  }

  Future<String?> _stop(FlutterSoundRecorder recorder) async {
    final result = await recorder.stopRecorder();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      height: 80,
      child: Stack(
        children: [
          Row(
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
                      openCameraOptions();
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
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
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
                    onTapOutside: (event) {
                      if(widget.focusNode.hasFocus) {
                        widget.focusNode.unfocus();
                      }
                    },
                    style: const TextStyle(fontSize: 16, color: LightColors.mainText),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black45,
                              width: 1
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                      ),
                      hintText: 'Напишите сообщение...',
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
                    if (kIsWeb) {
                        customToastMessage(context: context, message: 'Отправка голосового сообщения недоступна в браузере!');
                        return;
                    }
                      widget.setRecording(true);
                    if (sendButton == false) _start(_mRecorder);
                  },
                  onLongPressEnd: (details) async {
                    try {
                      final recordedAudioPath = await _stop(_mRecorder);
                      widget.setRecording(false);
                      final File record = File(recordedAudioPath!);
                      _sendAudioMessage(record, widget.parentMessage);
                    } catch (err, stackTrace) {
                      ClientErrorHandler.informErrorHappened(context, "Произошла ошибка при отправке голосового файла. Попробуйте еще раз. ");
                      _logger.sendErrorTrace(stackTrace: stackTrace);
                    }
                  },
                  child: GlowingActionButton(
                    color: isSendButtonDisabled ? Colors.grey : widget.isRecording ? Colors.red : AppColors.accent ,
                    icon: !kIsWeb
                        ? sendButton ? Icons.send_rounded : Icons.mic
                        : sendButton ? Icons.send_rounded : Icons.send_rounded,
                    onPressed: () async {
                        if (isSendButtonDisabled) {
                            customToastMessage(context: context, message: 'Пожалуйста подождите, обрабатывается запрос на создание диалога');
                            return;
                        }
                        if (_messageController.text.trim() == "" || !sendButton) return;
                        if (widget.dialogId != null) {
                        _sendMessage(widget.parentMessage);
                        widget.cancelReplyMessage();
                      } else {
                        try {
                          BlocProvider.of<MessageBloc>(context).add(MessageBlocFlushMessagesEvent());
                          createDialogAndSendMessage(
                              context, widget.rootWidget);
                          _sendMessage(widget.parentMessage);
                        } catch (err, stackTrace) {
                          ClientErrorHandler.informErrorHappened(context, "Произошла ошибка при создании диалога и отправке сообщения. Попробуйте еще раз. ");
                          _logger.sendErrorTrace(stackTrace: stackTrace);
                        }
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
          AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                child: Transform.translate(
                  offset: Offset(0,  80 - 80 * widget.animationController.value),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      border: Border(
                        top: BorderSide(width: 1.0, color: widget.animationController.value > 0 ? Colors.black54 : Colors.transparent),
                      ),
                      boxShadow: [
                        if (widget.animationController.value > 0) const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 15
                        )
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            widget.deleteMessages();
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            width: 100,
                            child: const Text('Удалить',
                              style: TextStyle(fontSize: 18, color: Colors.redAccent),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.openForwardMessageMenu(widget.selected);
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 100,
                            child: const Text('Переслать',
                              style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
          widget.animationController.value > 0 ? SizedBox.shrink() : Positioned(
            bottom: 0,
            left: 0,
            child: Transform.translate(
              offset: Offset(0,  widget.animationController.value > 0 ? 0 : 80),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: AppColors.backgroundLight,
                // decoration: const BoxDecoration(
                //     color: Color(0xFFF3F3F3),
                //     border: Border(
                //       top: BorderSide(width: 1.0, color: Colors.black54),
                //     ),
                // )
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _actionBarMessagesFunctions () {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: (){
            widget.deleteMessages();
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.blueAccent,
            size: 40,
          )
        )
      ],
    );
  }

  void openCameraOptions() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SendingObjectOptionsPage(
        context: context,
        dialogId: widget.dialogId,
        messageController: _messageController,
        username: widget.username,
        userId: widget.userId,
        createDialogFn: createDialogAndSendMessage,
        parentMessage: widget.parentMessage
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

  _sendMessage(RepliedMessage? parentMessage) async {
    BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocSendMessageEvent(dialogId: widget.dialogId!, messageText: _messageController.text,
        parentMessage: parentMessage, file: null));
    _messageController.clear();
  }

  _sendAudioMessage(File file, RepliedMessage? parentMessage) {
    BlocProvider.of<DatabaseBloc>(context).add(DatabaseBlocSendMessageEvent(dialogId: widget.dialogId!, messageText: _messageController.text,
        parentMessage: parentMessage, file: file));
  }


  createDialogAndSendMessage(context, rootWidget) async {
    /// we disable send button, create dialog and set it fot current session chat screen
    setState(() {
      isSendButtonDisabled = true;
    });
    final newDialog = await DialogsProvider().createDialog(chatType: 1, users: [widget.partnerId], chatName: "p2p", chatDescription: null, isPublic: false);
    setState(() {
      widget.dialogId = newDialog.dialogId;
    });
    if (newDialog != null) {
      widget.setDialogData(widget.rootWidget, newDialog);
    }
    setState(() {
      isSendButtonDisabled = false;
    });
  }

}