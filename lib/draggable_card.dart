import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery_dart2/layout.dart';

enum SlideDirection {
  left,
  right,
  up,
}

enum Decision {
  nope,
  like,
}

class DraggableCard extends StatefulWidget {
  final Widget card;
  final bool isDraggable;
  final SlideDirection slideTo;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection direction) onSlideOutComplete;

  DraggableCard(
      {this.card,
      this.isDraggable = true,
      this.slideTo,
      this.onSlideUpdate,
      this.onSlideOutComplete});

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  GlobalKey profileCardKey = new GlobalKey(debugLabel: 'profile_card_key');
  Decision decision;
  Offset cardOffset = const Offset(0.0, 0.0);
  Offset dragStart;
  Offset dragPosition;
  Offset slideBackStart;
  SlideDirection slideOutDirection;
  AnimationController slideBackAnimation;
  Tween<Offset> slideOutTween;
  AnimationController slideOutAnimation;

  @override
  void initState() {
    super.initState();

    slideBackAnimation = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..addListener(() => setState(() {
            cardOffset = Offset.lerp(slideBackStart, const Offset(0.0, 0.0),
                Curves.elasticOut.transform(slideBackAnimation.value));

            if (widget.onSlideUpdate != null) {
              widget.onSlideUpdate(cardOffset.distance);
            }
          }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideBackStart = null;
            dragPosition = null;
          });
        }
      });

    slideOutAnimation = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          cardOffset = slideOutTween.evaluate(slideOutAnimation);

          if (widget.onSlideUpdate != null) {
            widget.onSlideUpdate(cardOffset.distance);
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            dragPosition = null;
            slideOutTween = null;

            if (widget.onSlideOutComplete != null) {
              widget.onSlideOutComplete(slideOutDirection);
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.key != oldWidget.card.key) {
      cardOffset = const Offset(0.0, 0.0);
    }

    if (widget.isDraggable &&
        oldWidget.slideTo == null &&
        widget.slideTo != null) {
      switch (widget.slideTo) {
        case SlideDirection.left:
          _slideLeft();
          break;
        case SlideDirection.right:
          _slideRight();
          break;
        case SlideDirection.up:
          _slideUp();
          break;
      }
    }
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    super.dispose();
  }

  void _slideLeft() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
        begin: const Offset(0.0, 0.0), end: new Offset(-2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideRight() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
        begin: const Offset(0.0, 0.0), end: new Offset(2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideUp() async {
    final screenHeight = context.size.height;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
        begin: const Offset(0.0, 0.0), end: new Offset(0.0, -2 * screenHeight));
    slideOutAnimation.forward(from: 0.0);
  }

  Offset _chooseRandomDragStart() {
    final cardContext = profileCardKey.currentContext;
    final cardTopLeft = (cardContext.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0));
    final dragStartY = cardContext.size.height *
            (new Random().nextDouble() < 0.5 ? 0.25 : 0.75) +
        cardTopLeft.dy;
    return new Offset(cardContext.size.width / 2 + cardTopLeft.dx, dragStartY);
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isDraggable) {
      dragStart = details.globalPosition;
    }

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (widget.isDraggable) {
        dragPosition = details.globalPosition;
        cardOffset = dragPosition - dragStart;
      }
    });

    if (widget.onSlideUpdate != null) {
      widget.onSlideUpdate(cardOffset.distance);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset / cardOffset.distance;
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInTopRegion = (cardOffset.dy / context.size.width) < -0.40;

    setState(() {
      if (widget.isDraggable) {
        if (isInLeftRegion || isInRightRegion) {
          slideOutTween = new Tween(
              begin: cardOffset, end: dragVector * (2 * context.size.width));
          slideOutAnimation.forward(from: 0.0);

          slideOutDirection =
              isInLeftRegion ? SlideDirection.left : SlideDirection.right;
        } else if (isInTopRegion) {
          slideOutTween = new Tween(
              begin: cardOffset, end: dragVector * (2 * context.size.height));
          slideOutAnimation.forward(from: 0.0);
          slideOutDirection = SlideDirection.up;
        } else {
          slideBackStart = cardOffset;
          slideBackAnimation.forward(from: 0.0);
        }
      }
    });
  }

  double _rotation(Rect dragBounds) {
    if (dragStart != null) {
      final rotationCornerMultiplier =
          dragStart.dy >= dragBounds.top + (dragBounds.height / 2) ? -1 : 1;
      return (pi / 8) *
          (cardOffset.dx / dragBounds.width) *
          rotationCornerMultiplier;
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect dragBounds) {
    if (dragStart != null) {
      return dragStart - dragBounds.topLeft;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnchoredOverlay(
      showOverlay: true,
      child: new Center(),
      overlayBuilder: (BuildContext context, Rect anchorBounds, Offset anchor) {
        return CenterAbout(
          position: anchor,
          child: new Transform(
            transform:
                new Matrix4.translationValues(cardOffset.dx, cardOffset.dy, 0.0)
                  ..rotateZ(_rotation(anchorBounds)),
            origin: _rotationOrigin(anchorBounds),
            child: new Container(
              width: anchorBounds.width,
              height: anchorBounds.height,
              padding: const EdgeInsets.all(16.0),
              child: new GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: widget.card,
              ),
            ),
          ),
        );
      },
    );
  }
}
