import 'package:flutter/material.dart';

// Badge type
//enum BadgeType { circle, rectangle }

class Badge extends StatelessWidget {
  // Variables
  final Widget? icon;
  final String? text;
  final TextStyle? textStyle;
  final Color? bgColor;
  final EdgeInsetsGeometry? padding;
  const Badge({this.icon, this.text, this.bgColor, this.textStyle, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,  //bgColor ?? Theme.of(context).primaryColor
            borderRadius: BorderRadius.circular(15.0)),
        padding: padding ?? EdgeInsets.all(6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? Container(width: 0, height: 0),
            icon != null ? SizedBox(width: 5) : Container(width: 0, height: 0),
            Text(text ?? "", style: textStyle ?? TextStyle(color: Colors.white)),
          ],
        ));
  }
}
