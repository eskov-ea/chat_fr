import 'dart:async';
import 'dart:io';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';
import '../../services/global.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.attachmentId,
    required this.fileName,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  final int attachmentId;
  final String fileName;
  final bool isMe;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {

  StreamSubscription? _mPlayerSubscription;
  String pos = '0:00';
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  final FlutterSoundPlayer player = FlutterSoundPlayer();
  bool isPlaying = false;
  File? file;
  bool _playerIsInited = false;
  bool _dataIsLoaded = false;
  late final AudioPlayer audioPlayer;
  bool isError = false;

  @override
  void dispose() {
    player.stopPlayer();
    cancelPlayerSubscriptions();
    player.closePlayer();
    super.dispose();
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    init().then((value) {
      setState(() {
        _playerIsInited = true;
      });
    }).catchError((err, stackTrace) {
      print("AUDIO ERROR:   $err, $stackTrace");
      setState(() {
        isError = true;
      });
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
    });

    super.initState();
  }

  Future<void> init() async {
    await player.openPlayer();
    print("INIT NEW AUDIO PLAYER");
    _mPlayerSubscription = player.onProgress!.listen((e) {
      print("subscription    ${e.position}");
      setState(() {
        pos = getAudioMessageDuration(e.position.inSeconds);
        position = e.position;
        duration = e.duration;
      });
    });
    player.setSubscriptionDuration(Duration(milliseconds: 100));
    print(_mPlayerSubscription);
    try {
      await decodeBase64File();
    } catch (err, stackTrace) {
      setState(() {
        isError = true;
      });
      final userId = await DataProvider().getUserId();
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: " [ USER ID: $userId ] \r\nError initializing audio widget / audio data");
    }
  }

  void play() async {
    print("PLAYAUDIO   ${file!.path}");
    if (position > Duration.zero) {
      await player.resumePlayer();
    } else {
      player.startPlayer(
          fromURI: file!.path,
          codec: Codec.aacMP4,
          whenFinished: () {
            reset();
          }
      );
    }
    setState(() {
      isPlaying = true;
    });
  }

  void pause() async {
    await player.pausePlayer();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> reset() async {
    // await player.stopPlayer();
    await player.seekToPlayer(const Duration(milliseconds: 0));
    setState(() {
      isPlaying = false;
      position = Duration.zero;
    });
    // return widget.player.seek(const Duration(milliseconds: 0));
  }

  // void playerStateListener(PlayerState state) async {
  //   if (state.processingState == ProcessingState.completed) {
  //     await reset();
  //   }
  // }

  Future<void> setSubscriptionDuration(double d) async {
    print('FuturesetSubscriptionDuration   $d');
    // _mSubscriptionDuration = d;
    setState(() {
      position = Duration(seconds: d.toInt());
    });
    await player.seekToPlayer(position);
    // await player.setSubscriptionDuration(
    //   Duration(milliseconds: d.floor()),
    // );
  }

  decodeBase64File() async {
    final rawFile = await loadFileAndSaveLocally(
        attachmentId: widget.attachmentId, fileName: widget.fileName);
    if (rawFile != null) {
      file = rawFile;
      await audioPlayer.setSourceDeviceFile(file!.path);
      final d = await audioPlayer.getDuration();
      setState(() {
        duration = d!;
        _dataIsLoaded = true;
      });
    }
  }

  void cancelPlayerSubscriptions() {
    if (player != null) {
      _mPlayerSubscription?.cancel();
      _mPlayerSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: fix it. It is temporary solution to have audio messaging feature.
    return audioWidgetWithData();
  }

  Widget _slider(duration, durationCallback) {
    print("SLIDER   $duration, $durationCallback");
    return SizedBox(
      width: 100,
      child: Slider(
        value: duration,
        min: 0.0,
        max: 10.0,
        onChanged: durationCallback,
        divisions: 1
      ),
    );
  }

  Widget audioWidgetWithData() {
    if(isError) {
      return Container(
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                init().then((value) {
                  setState(() {
                    _playerIsInited = true;
                  });
                  setState(() {
                    isError = false;
                  });
                }).catchError((_) {
                  setState(() {
                    isError = true;
                  });
                });
              },
              child: SizedBox(
                width: 30,
                height: 35,
                child: Image.asset("assets/images/download.png", fit: BoxFit.fitWidth),
              ),
            ),
            SizedBox(
              width: 150,
              height: 35,
              child: Image.asset("assets/images/voice-message.png", fit: BoxFit.fitWidth),
            ),
          ],
        ),
      );
    } else {
      return Container(
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _playerIsInited && _dataIsLoaded
                ? _controlButtons()
                : const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )
            ),
            SizedBox(
              width: 150,
              child: Slider(
                value: position.inSeconds.toDouble(),
                min: 0,
                max: duration.inSeconds.toDouble(),
                onChanged: setSubscriptionDuration,
                // divisions: 100
              ),
            ),
            Text(
              getAudioMessageDuration(duration.inSeconds),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            )
          ],
        )
      );
    }
  }

  Widget _controlButtons() {
    final color = isPlaying ? Colors.red : Colors.blue;
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () {
              if (isPlaying) {
                pause();
              } else {
                play();
              }
            },
            child: SizedBox(
              width: 30,
              height: 35,
              child: Icon(icon, color: color, size: 35),
            ),
          ),
        )
      ],
    );
  }
}

class AudioLoadingMessage extends StatelessWidget {
  const AudioLoadingMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:  EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.mic),
          ),
        ],
      ),
    );
  }
}

