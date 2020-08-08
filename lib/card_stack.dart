import 'package:animation_showcase/draggable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'flip_card.dart';

class CardStack extends StatefulWidget {
  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  double _nextCardScale;
  List<Widget> cardsList;

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

  void _onSlideUpdate(double distance){
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  Widget _buildBackCard(){
    return new Transform(
      transform: new Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: Card()
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
          child: DraggableCard(
            card: _flipCards[x],
          ),
        ),
      );
    }
    return cards;
  }
}
