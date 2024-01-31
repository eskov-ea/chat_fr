import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;


const passCode = "EA0000001CEC3501";

class PassScreen extends StatefulWidget {
  const PassScreen({super.key});

  @override
  State<PassScreen> createState() => _PassScreenState();
}

class _PassScreenState extends State<PassScreen> {

  NFCAvailability? availability;

  @override
  void initState() {
    FlutterNfcKit.nfcAvailability.then((value) {
      print("nfcAvailability  $value");
      setState(() {
        availability = value;
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
                child: _mapAvailabilityToWidget(),
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

  Widget _mapAvailabilityToWidget() {
    switch (availability!) {
      case NFCAvailability.not_supported:
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset("assets/icons/close.png", width: 40),
            ),
            Expanded(
              child: Text('Ваш телефон не поддерживает NFC, воспользуйтесь физическим пропуском.',
                style: TextStyle(fontSize: 12),
              )
            ),
            SizedBox(width: 20)
          ],
        );
      case NFCAvailability.disabled:
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset("assets/icons/close.png", width: 40),
            ),
            Expanded(
                child: Text('Включите доступ к NFC в настройках, чтобы использовать виртуальный пропуск',
                  style: TextStyle(fontSize: 12),
                )
            ),
            SizedBox(width: 20)
          ],
        );
      case NFCAvailability.available:
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset("assets/icons/success.png", width: 40),
            ),
            Expanded(
                child: Text('Воспользоваться виртуальным пропуском.',
                  style: TextStyle(fontSize: 12),
                )
            ),
            SizedBox(width: 20)
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(),
        body: Container(
          alignment: Alignment.center,
          child: availability == null ? const Center(
            child: CircularProgressIndicator()
          ) : _cardShapeContainer()
        ),
      ),
    );
  }
}
