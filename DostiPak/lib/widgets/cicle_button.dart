import 'package:flutter/material.dart';

Widget cicleButton(
    {required Widget icon,
    required Color bgColor,
    required Function()? onTap,
    double? padding}) {
  return GestureDetector(
    child: Container(
        padding: EdgeInsets.all(padding ?? 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
        ),
        child: icon),
    onTap: onTap,
  );
}
