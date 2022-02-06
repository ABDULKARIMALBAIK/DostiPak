import 'package:flutter/material.dart';

void showScaffoldMessage({
  required BuildContext context,
  required String message,
  Color? bgcolor,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: TextStyle(fontSize: 18)),
    duration: duration ?? Duration(seconds: 4),
    backgroundColor: bgcolor ?? Theme.of(context).primaryColor,
  ));
}
