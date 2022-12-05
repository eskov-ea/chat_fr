import 'package:flutter/material.dart';

Widget ImageOptionsDialogWidget({
  required context,
  required imageSaver,
}) {


  return Wrap(
    children: [
      Column(
        children: [
          OutlinedButton(
              onPressed: (){
                imageSaver();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Сохранить в галерею',
                style: TextStyle(color: Colors.black54, fontSize: 20),
              )
          ),
          const SizedBox(height: 1,),
          const Divider(
            color: Colors.transparent,
            thickness: 0,
          ),
          OutlinedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
              ),
              child: const Text(
                'Отменить',
                style: TextStyle(color: Colors.red, fontSize: 20),
              )
          ),
        ],
      )
    ],
  );
}


