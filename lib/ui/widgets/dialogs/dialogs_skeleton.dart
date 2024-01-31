import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogsSkeletonWidget extends StatelessWidget {
  const DialogsSkeletonWidget({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      child: ListView.builder(
        itemCount: 7,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, itemCount) =>
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: Color(0xFF878787),
                          shape: BoxShape.circle
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  color: Color(0xFF878787),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: 16,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  color: Color(0xFF878787),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                            )
                          ],
                        )
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Color(0xFF878787),
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                    )
                  ],
                ),
              ),
            ),
      ),
    );
  }
}