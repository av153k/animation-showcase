import 'package:flutter/material.dart';

class CardData {
  final Color color;
  final String name;

  CardData({
    @required this.color,
    this.name,
  });
}

final List<CardData> demoCards = [
  new CardData(color: Colors.red, name: "first"),
  new CardData(color: Colors.blue, name: "second"),
  new CardData(color: Colors.green, name: "third"),
  new CardData(color: Colors.purple, name: "fourth"),
  new CardData(color: Colors.deepOrange, name: "fifth"),
];
