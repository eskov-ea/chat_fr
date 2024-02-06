import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;


const passCode = "EA0000001CEC3501";

class PassWidget extends StatefulWidget {
  final String name;
  const PassWidget({
    required this.name,
    super.key
  });

  @override
  State<PassWidget> createState() => _PassWidgetState();
}

class _PassWidgetState extends State<PassWidget> {

  NFCAvailability? nfcAvailability;
  bool isActive = false;

  @override
  void initState() {
    FlutterNfcKit.nfcAvailability.then((value) {
      print("nfcAvailability  $value");
      setState(() {
        nfcAvailability = value;
      });
    });
    super.initState();
  }

  Widget _cardShapeContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xfbd0d0d0),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(30, 15)
            ),
          ]
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Material(
              child: Ink(
                height: MediaQuery.of(context).size.width * 0.7,
                color: Color(0xFFE3E3E3),
                child: InkWell(
                  onTap: () async {
                    print("TApped");
                    var tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10),
                        iosMultipleTagMessage: "Multiple tags found!", iosAlertMessage: "Scan your tag");

                    print(jsonEncode(tag));
                    if (tag.type == NFCTagType.iso7816) {
                      var result = await FlutterNfcKit.transceive("00B0950000", timeout: const Duration(seconds: 5)); // timeout is still Android-only, persist until next change
                      print(result);
                    }
                  },
                  splashColor: Color(0xFFFFFFFF),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * 0.7 - 50 - 30, 30),
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Color(0xFFBE9B29)
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, MediaQuery.of(context).size.width * 0.7 - 10),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Color(0xfbd2d2d2),
                ),
                child: SizedBox(),
              ),
            ),
            Transform.translate(
              offset: Offset(0, MediaQuery.of(context).size.width * 0.9 - 10),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xfbff0000),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> nfcKeycardModalWidget(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Виртуальный пропуск'),
              content: Container(
                alignment: Alignment.topCenter,
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Image.asset("assets/icons/keycard.png", height: 150, width: 150),
                    const SizedBox(height: 10),
                    isActive ? LinearProgressIndicator(color: Colors.green.shade700,) : const SizedBox.shrink(),
                    const SizedBox(height: 30),
                    Text(widget.name)
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Открыть дверь'),
                  onPressed:() async {
                    setState(() {
                      isActive = true;
                    });
                    // await NfcEmulator.startNfcEmulator(
                    //     "EA0000001CEC3501");
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Готово'),
                  onPressed: () {
                    setState(() {
                      isActive = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (nfcAvailability == NFCAvailability.available && Platform.isAndroid) {
      return Material(
        color: Colors.transparent,
        child: Ink(
          height: 60,
          child: InkWell(
            onTap: () async {
              await nfcKeycardModalWidget(context);
            },
            splashColor: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text("Использовать пропуск", maxLines: 2,)
                ),
                Image.asset("assets/icons/keycard.png", height: 60, width: 60)
              ],
            ),
          ),
        )
      );
    } else if (nfcAvailability == NFCAvailability.disabled && Platform.isAndroid) {
      return Material(
          color: Colors.transparent,
          child: Ink(
            height: 60,
            child: InkWell(
              onTap: () async {
                await nfcKeycardModalWidget(context);
              },
              splashColor: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text("Включите NFC в настройках", maxLines: 2,)
                  ),
                  Image.asset("assets/icons/keycard-nv.png", height: 60, width: 60)
                ],
              ),
            ),
          )
      );
    } else {
      return Material(
          color: Colors.transparent,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 1)
            ),
            height: 60,
            child: InkWell(
              onTap: () async {
                await nfcKeycardModalWidget(context);
              },
              splashColor: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text("На вашем устройстве нет поддержки виртуального пропуска", maxLines: 2,)
                  ),
                  Image.asset("assets/icons/keycard-na.png", height: 60, width: 60)
                ],
              ),
            ),
          )
      );
    }
  }
}
