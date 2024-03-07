import 'dart:async';
import 'dart:io';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';
import '../../../services/global.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.attachmentId,
    required this.fileName,
    required this.isMe,
    required this.messageTime,
    Key? key,
  }) : super(key: key);

  final int attachmentId;
  final String fileName;
  final bool isMe;
  final String messageTime;

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
        pos = getAudioMessageDuration(e.position.inMilliseconds);
        position = e.position;
        duration = e.duration;
      });
    });
    player.setSubscriptionDuration(const Duration(milliseconds: 50));
    print('_mPlayerSubscription  $_mPlayerSubscription');
    try {
      await decodeBase64File();
    } catch (err, stackTrace) {
      print('PLAYER INITED:: error $err');
      setState(() {
        isError = true;
      });
      final userId = await DataProvider.storage.getUserId();
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: " [ USER ID: $userId ] \r\nError initializing audio widget / audio data");
    }
  }

  void play() async {
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
    await player.seekToPlayer(const Duration(milliseconds: 0));
    setState(() {
      isPlaying = false;
      position = Duration.zero;
    });
  }


  Future<void> setSubscriptionDuration(double d) async {
    setState(() {
      position = Duration(seconds: d.toInt());
    });
    await player.seekToPlayer(position);
  }
  decodeBase64File() async {
    file = await loadFileAndSaveLocally(
        attachmentId: widget.attachmentId, fileName: widget.fileName);
    if (file != null) {
      await audioPlayer.setSourceUrl(file!.path);
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
    if(isError) {
      return SizedBox(
        height: 40,
        width: 220,
        child: Row(
          mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                init().then((value) {
                  setState(() {
                    _playerIsInited = true;
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
            const SizedBox(width: 15),
            SizedBox(
              width: 150,
              height: 35,
              child: Image.asset("assets/images/voice-message.png", fit: BoxFit.fitWidth),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: SizedBox(
            height: 40,
            width: 220,
            child: Row(
              mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  child: _playerIsInited && _dataIsLoaded
                      ? _controlButtons()
                      : const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
                        strokeCap: StrokeCap.round,
                      )
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 135,
                  height: 20,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 10.0,
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.black12,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 5.0),
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: setSubscriptionDuration,
                      // divisions: 100
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 20,
                  child: Text(
                    getAudioMessageDuration(duration.inSeconds),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
        ),
      );
    }
  }


  Widget _controlButtons() {
    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          pause();
        } else {
          play();
        }
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: isPlaying ? Image.asset("assets/player/pause.png") : Image.asset("assets/player/play2.png")
      ),
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

