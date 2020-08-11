import 'package:flutter/material.dart';

Widget getIcon(Color color, String text, double opacity, Duration duration) {
  return Material(
    color: Colors.transparent,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        //color: Colors.transparent,
        border: Border.all(
          color: color.withOpacity(opacity),
          width: 5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$text",
        style: TextStyle(
          color: color.withOpacity(opacity),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    ),
  );
}
