import 'package:animation_showcase/card_contents.dart';
import 'package:flutter/widgets.dart';

class ChoiceEngine extends ChangeNotifier {
  final List<ChoiceClass> _choices;
  int _currentChoiceIndex;
  int _nextChoiceIndex;

  ChoiceEngine({
    List<ChoiceClass> choices,
  }) : _choices = choices {
    _currentChoiceIndex = 0;
    _nextChoiceIndex = 1;
  }

  ChoiceClass get currentChoice => _choices[_currentChoiceIndex];
  ChoiceClass get nextChoice => _choices[_nextChoiceIndex];

  void cycleChoice() {
    if (currentChoice.choice != Choices.undecided) {
      currentChoice.reset();

      _currentChoiceIndex = _nextChoiceIndex;
      _nextChoiceIndex =
          _nextChoiceIndex < _choices.length - 1 ? _nextChoiceIndex + 1 : 0;
      notifyListeners();
    }
  }
}

class ChoiceClass extends ChangeNotifier {
  final CardData card;
  Choices choice = Choices.undecided;

  ChoiceClass({
    this.card,
  });

  void like() {
    if (choice == Choices.undecided) {
      choice = Choices.nope;
      notifyListeners();
    }
  }

  void nope() {
    if (choice == Choices.undecided) {
      choice = Choices.like;
      notifyListeners();
    }
  }

  void superLike() {
    if (choice == Choices.undecided) {
      choice = Choices.superLike;
      notifyListeners();
    }
  }

  void reset() {
    if (choice != Choices.undecided) {
      choice = Choices.undecided;
      notifyListeners();
    }
  }
}

enum Choices {
  undecided,
  nope,
  like,
  superLike,
}
