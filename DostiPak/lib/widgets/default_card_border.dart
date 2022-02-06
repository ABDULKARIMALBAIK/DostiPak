import 'package:flutter/material.dart';


/// Default Card border
RoundedRectangleBorder defaultCardBorder() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(28.0),
    topRight: Radius.circular(28.0),
    topLeft: Radius.circular(8.0),
    bottomRight: Radius.circular(8.0),
  ));
}
