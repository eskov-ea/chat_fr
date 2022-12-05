import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum SlidableActionEnum { pin, delete }

class SlidableWidget extends StatelessWidget {

  const SlidableWidget({
    required this.child,
    required this.onDismissed,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Function(SlidableActionEnum action) onDismissed;

  @override
  Widget build(BuildContext context) => Slidable(
      key: UniqueKey(),
      child: child,
      endActionPane: ActionPane(
        extentRatio: 0.10,
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: (){ onDismissed(SlidableActionEnum.delete); }),
        children: <Widget>[
        SlidableAction(
          onPressed: (_){},
          backgroundColor: Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: (){ onDismissed(SlidableActionEnum.pin); }),
        children: <Widget>[
          SlidableAction(
            onPressed: (_){},
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.push_pin,
            label: 'Pin',
          ),
        ],
      ),
  );
}