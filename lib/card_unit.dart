import 'dart:math';

import 'package:animation_showcase/constants.dart';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  @override
  _FlipCardState createState() => _FlipCardState();
  final Color color1;
  final Color color2;

  FlipCard({
    Key key,
    @required this.color1,
    this.color2,
  }) : super(key: key);
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(end: 1, begin: 0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(pi * _animation.value),
        child: GestureDetector(
          onTap: () {
            if (_animationStatus == AnimationStatus.dismissed) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: _animation.value <= 0.5
              ? getCards(widget.color1, context)
              : getCards(widget.color2, context),
        ),
      ),
    );
  }
}
