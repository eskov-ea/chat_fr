import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebContainerWrapper extends StatelessWidget {
  final Widget child;
  final Color color;
  const WebContainerWrapper({
    required this.child,
    this.color = Colors.white,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final currentW = MediaQuery.of(context).size.width;
    return Row(
      children: [
        if (currentW > 700) const Spacer(),
        Container(
            constraints: BoxConstraints(
                maxWidth: currentW > 700 ? 700 : currentW
            ),
          color: color,
          child: child,
        ),
        if (currentW > 700) const Spacer(),
      ],
    );
  }
}
