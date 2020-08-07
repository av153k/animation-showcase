import 'package:flutter/material.dart';

Widget getCards(Color color1) {
  return Draggable(
    affinity: Axis.horizontal,
    axis: Axis.horizontal,
    feedback: Card(
      elevation: 12,
      child: Center(
        child: Container(
          height: 300,
          width: 200,
        ),
      ),
    ),
    child: Container(
      height: 300,
      width: 200,
      child: Card(
        color: color1,
        elevation: 12,
        child: Center(
          child: Container(
            height: 300,
            width: 200,
          ),
        ),
      ),
    ),
  );
}
