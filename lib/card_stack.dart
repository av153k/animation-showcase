import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'card_unit.dart';

class CardStack extends StatefulWidget {
  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  List<Widget> cardsList;

  void _showNext(index) {
    setState(() {
      cardsList.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    cardsList = _stackCards();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: cardsList,
      ),
    );
  }

  List<Widget> _stackCards() {
    List<FlipCard> _flipCards = [
      FlipCard(color1: Colors.redAccent, color2: Colors.purpleAccent),
      FlipCard(color1: Colors.blueAccent, color2: Colors.tealAccent),
      FlipCard(color1: Colors.deepOrangeAccent, color2: Colors.limeAccent),
    ];
    List<double> margins = [5.0, 10.0, 15.0];

    List<Widget> cards = new List();

    for (int x = 0; x < _flipCards.length; x++) {
      cards.add(
        Positioned(
          top: margins[x],
          child: Draggable(
              onDragEnd: (drag) {
                _showNext(x);
              },
              childWhenDragging: Container(
                color: Colors.transparent,
              ),
              child: _flipCards[x],
              feedback: _flipCards[x]),
        ),
      );
    }
    return cards;
  }
}
