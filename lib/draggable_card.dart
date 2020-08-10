import 'dart:math';

import 'package:animation_showcase/constants.dart';
import 'package:flutter/material.dart';

import 'card_stack.dart';

class DraggableCard extends StatefulWidget {
  final Widget frontCard;
  final Widget backCard;
  final bool isDraggable;
  final SlideDirection slideTo;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection direction) onSlideOutComplete;
  final bool isFrontCard;

  DraggableCard({
    this.frontCard,
    this.backCard,
    this.isDraggable = true,
    this.slideTo,
    this.onSlideUpdate,
    this.onSlideOutComplete,
    this.isFrontCard,
  });

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  GlobalKey globalKey = GlobalKey(debugLabel: 'draggable_global_key');
  Offset cardOffset = const Offset(0.0, 0.0);
  Offset dragStart;
  Offset dragPosition;
  Offset slideBackStart;
  SlideDirection slideOutDirection;
  AnimationController slideBackAnimation;
  Tween<Offset> slideOutTween;
  AnimationController slideOutAnimation;
  AnimationController _flipAnimationController;
  Animation _flipAnimationValue;
  AnimationStatus _flipAnimationStatus = AnimationStatus.dismissed;
  bool _isGoingLeft;
  bool _decisionVisibility;

  @override
  void initState() {
    super.initState();
    _isGoingLeft = false;
    _decisionVisibility = false;

    _flipAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _flipAnimationValue =
        Tween<double>(end: 1, begin: 0).animate(_flipAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            _flipAnimationStatus = status;
          });

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

    if (widget.frontCard.key != oldWidget.frontCard.key) {
      cardOffset = const Offset(0.0, 0.0);
    }

    if (widget.isDraggable &&
        oldWidget.slideTo == null &&
        widget.slideTo != null) {
      switch (widget.slideTo) {
        case SlideDirection.left:
          _slideLeft();
          setState(() {
            _isGoingLeft = true;
            _decisionVisibility = true;
          });
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
    _flipAnimationController.dispose();
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
    final cardContext = globalKey.currentContext;
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
    return Container(
      key: globalKey,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OverlayBuilder(
            showOverlay: true,
            overlayBuilder: (BuildContext overlayContext) {
              RenderBox box = context.findRenderObject() as RenderBox;
              final topLeft = box.size.topLeft(box.localToGlobal(cardOffset));
              final bottomRight =
                  box.size.bottomRight(box.localToGlobal(cardOffset));
              final Rect anchorBounds = new Rect.fromLTRB(
                topLeft.dx,
                topLeft.dy,
                bottomRight.dx,
                bottomRight.dy,
              );
              final anchorCenter = box.size.center(topLeft);
              return Positioned(
                left: anchorCenter.dx,
                top: anchorCenter.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Transform(
                    transform: new Matrix4.translationValues(
                        cardOffset.dx, cardOffset.dy, 0.0)
                      ..rotateZ(_rotation(anchorBounds)),
                    origin: _rotationOrigin(anchorBounds),
                    child: new Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(pi * _flipAnimationValue.value),
                      child: Container(
                        width: anchorBounds.width,
                        height: anchorBounds.height,
                        padding: const EdgeInsets.all(16.0),
                        child: new GestureDetector(
                          onTap: () {
                            if (widget.isFrontCard) {
                              if (_flipAnimationStatus ==
                                  AnimationStatus.dismissed) {
                                _flipAnimationController.forward();
                              } else {
                                _flipAnimationController.reverse();
                              }
                            }
                          },
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: createCard(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Center(),
          );
        },
      ),
    );
  }

  Widget _flipControl() {
    if (!widget.isFrontCard) {
      return widget.frontCard;
    } else {
      return _flipAnimationValue.value <= 0.5
          ? widget.frontCard
          : widget.backCard;
    }
  }

  Widget createCard() {
    Color color = _isGoingLeft ? Colors.green : Colors.red;
    String text = _isGoingLeft ? "Like" : "Nope";
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        _flipControl(),
        Positioned(
          left: 50,
          top: 200,
          child: getIcon(
            color,
            text,
            _decisionVisibility,
            Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext) overlayBuilder;
  final Widget child;

  OverlayBuilder({
    key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  _OverlayBuilderState createState() => new _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    if (overlayEntry == null) {
      // Create the overlay.
      overlayEntry = new OverlayEntry(
        builder: widget.overlayBuilder,
      );
      addToOverlay(overlayEntry);
    } else {
      // Rebuild overlay.
      buildOverlay();
    }
  }

  void addToOverlay(OverlayEntry entry) async {
    Overlay.of(context).insert(entry);
  }

  void hideOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    overlayEntry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => buildOverlay());

    return widget.child;
  }
}
