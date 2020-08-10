import 'package:animation_showcase/draggable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'decisions.dart';
import 'main_cards.dart';

class CardStack extends StatefulWidget {
  final ChoiceEngine choiceEngine;

  CardStack({
    this.choiceEngine,
  });

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  Key _frontCard;
  ChoiceClass _currentChoice;
  double _nextCardScale = 0.9;
  double _backCardMargin = 0;
  double _frontCardMargin = 50;

  @override
  void initState() {
    super.initState();
    widget.choiceEngine.addListener(_onChoiceEngineChange);

    _currentChoice = widget.choiceEngine.currentChoice;
    _currentChoice.addListener(_onChoiceChange);

    _frontCard = new Key(_currentChoice.card.name);
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.choiceEngine != oldWidget.choiceEngine) {
      oldWidget.choiceEngine.removeListener(_onChoiceEngineChange);
      widget.choiceEngine.addListener(_onChoiceEngineChange);
    }

    if (_currentChoice != null) {
      _currentChoice.removeListener(_onChoiceChange);
    }
    _currentChoice = widget.choiceEngine.currentChoice;
    if (_currentChoice != null) {
      _currentChoice.addListener(_onChoiceChange);
    }
  }

  @override
  void dispose() {
    if (_currentChoice != null) {
      _currentChoice.removeListener(_onChoiceChange);
    }

    widget.choiceEngine.removeListener(_onChoiceEngineChange);

    super.dispose();
  }

  void _onChoiceEngineChange() {
    setState(() {
      if (_currentChoice != null) {
        _currentChoice.removeListener(_onChoiceChange);
      }
      _currentChoice = widget.choiceEngine.currentChoice;
      if (_currentChoice != null) {
        _currentChoice.addListener(_onChoiceChange);
      }

      _frontCard = new Key(_currentChoice.card.name);
    });
  }

  void _onChoiceChange() {
    setState(() {});
  }

  Widget _buildBackCard() {
    return new Transform(
      transform: new Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: new MainCard(
        color: widget.choiceEngine.nextChoice.card.color,
      ),
    );
  }

  Widget _buildFrontCard() {
    return new MainCard(
      key: _frontCard,
      color: widget.choiceEngine.currentChoice.card.color,
    );
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.choiceEngine.currentChoice.choice) {
      case Choices.nope:
        return SlideDirection.left;
      case Choices.like:
        return SlideDirection.right;
      case Choices.superLike:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideComplete(SlideDirection direction) {
    ChoiceClass currentChoice = widget.choiceEngine.currentChoice;

    switch (direction) {
      case SlideDirection.left:
        currentChoice.nope();
        break;
      case SlideDirection.right:
        currentChoice.like();
        break;
      case SlideDirection.up:
        currentChoice.superLike();
        break;
    }

    setState(() {
      _nextCardScale = 0.9;
    });

    widget.choiceEngine.cycleChoice();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Positioned(
          top: _backCardMargin,
          child: DraggableCard(
            backCard: MainCard(color: Colors.amber),
            frontCard: _buildBackCard(),
            isDraggable: false,
            isFrontCard: false,
          ),
        ),
        Positioned(
          top: _frontCardMargin,
          child: DraggableCard(
            isFrontCard: true,
            backCard: MainCard(color: Colors.amber),
            frontCard: _buildFrontCard(),
            slideTo: _desiredSlideOutDirection(),
            onSlideUpdate: _onSlideUpdate,
            onSlideOutComplete: _onSlideComplete,
          ),
        ),
      ],
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
}
