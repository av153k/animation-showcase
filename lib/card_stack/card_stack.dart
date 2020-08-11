import 'package:animation_showcase/cards/draggable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../cards_choices/decisions.dart';
import '../cards/main_cards.dart';

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
  double _nextCardScale = 0.95;
  double _thirdCardScale = 0.9;
  double _thirdCardMargin = 0;
  double _backCardMargin = 20;
  double _frontCardMargin = 40;
  double iconOpacity = 0;

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

  Widget _buildThirdCard() {
    return new Transform(
      transform: new Matrix4.identity()
        ..scale(_thirdCardScale, _thirdCardScale),
      alignment: Alignment.center,
      child: new MainCard(
        name: widget.choiceEngine.thirdChoice.card.name,
      ),
    );
  }

  Widget _buildBackCard() {
    return new Transform(
      transform: new Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: new MainCard(
        name: widget.choiceEngine.nextChoice.card.name,
      ),
    );
  }

  Widget _buildFrontCard() {
    return new MainCard(
        key: _frontCard, name: widget.choiceEngine.currentChoice.card.name);
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

  void _onSlideUpdate(double distance, SlideDirection _slideDirection) {
    setState(() {
      _nextCardScale = 0.95 + (0.05 * (distance / 100.0)).clamp(0.0, 0.05);
      _thirdCardScale = 0.9 + (0.05 * (distance / 100.0)).clamp(0.0, 0.05);

      //slide out choice icon opacity control
      iconOpacity = 0.0 + (1 * (distance / 100)).clamp(0.0, 1);
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
      _nextCardScale = 0.95;
      _thirdCardScale = 0.9;
      iconOpacity = 0.0;
    });

    widget.choiceEngine.cycleChoice();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Positioned(
          top: _thirdCardMargin,
          child: DraggableCard(
            backCard: MainCard(name: "Back"),
            frontCard: _buildThirdCard(),
            isDraggable: false,
            isFrontCard: false,
          ),
        ),
        Positioned(
          top: _backCardMargin,
          child: DraggableCard(
            backCard: MainCard(name: "Back"),
            frontCard: _buildBackCard(),
            isDraggable: false,
            isFrontCard: false,
          ),
        ),
        Positioned(
          top: _frontCardMargin,
          child: DraggableCard(
            iconOpacity: iconOpacity,
            isFrontCard: true,
            backCard: MainCard(name: "Back"),
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
