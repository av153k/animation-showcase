import 'package:flutter/material.dart';

Widget getIcon(Color color, String text, bool visibility, Duration duration) {
  return AnimatedOpacity(
    duration: duration,
    opacity: visibility ? 1.0 : 0.0,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: color,
          width: 5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$text",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
