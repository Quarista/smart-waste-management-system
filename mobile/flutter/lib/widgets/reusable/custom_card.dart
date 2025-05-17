import 'package:flutter/material.dart';
import 'package:swms_administration/constants/colours.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CustomCard({super.key, this.color, this.padding, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColours().mainBlackColour.withOpacity(0.1),
              offset: Offset(
                0,
                0,
              ),
              blurRadius: 8),
        ],
        color: color ?? AppColours().mainWhiteColour,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
