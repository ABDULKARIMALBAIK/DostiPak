import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  // Variables
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  DefaultButton(
      {required this.child, required this.onPressed, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        child: child,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(color: Colors.white)
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            )
          )
        ),
        onPressed: onPressed,
      ),
    );
  }
}
