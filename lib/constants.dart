import 'package:animation_showcase/flip_card.dart';
import 'package:flutter/material.dart';

Widget getCards(Color color1, BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.6,
    width: MediaQuery.of(context).size.width * 0.8,
    child: Card(
      color: color1,
      elevation: 12,
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    ),
  );
}

Widget getIcon(Color color, String text) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 200),
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
  );
}

Widget getStack() {
  return Stack(alignment: Alignment.center, children: [
    Positioned(
      top: 500,
      child: getIcon(Colors.green, "LIKE"),
    ),
    FlipCard(color1: Colors.redAccent, color2: Colors.amberAccent)
  ]);
}
