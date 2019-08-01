import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(GlitterApp());

const _width = 300.0;
const _height = 500.0;
const _durations = <Duration>[
  Duration(milliseconds: 200),
  Duration(milliseconds: 300),
  Duration(milliseconds: 500),
  Duration(milliseconds: 700),
  Duration(milliseconds: 1000),
  Duration(milliseconds: 1500),
  Duration(milliseconds: 1700),
  Duration(milliseconds: 2000),
];
final _random = math.Random();
final _randomPieceSize = () => _random.nextInt(4).toDouble() + 4;
final _randomCornerSize = () => _random.nextInt(3).toDouble();
final _randomDecoration = () => BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(_randomCornerSize()),
        topRight: Radius.circular(_randomCornerSize()),
        bottomLeft: Radius.circular(_randomCornerSize()),
        bottomRight: Radius.circular(_randomCornerSize()),
      ),
    );

class GlitterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glitter',
      home: Glitter(),
    );
  }
}

/// Glitter modeled off of this gif: https://giphy.com/gifs/pink-5K5oXc0CD7ghG
class Glitter extends StatefulWidget {
  Glitter({Key key}) : super(key: key);

  @override
  _GlitterState createState() => _GlitterState();
}

class _GlitterState extends State<Glitter> with TickerProviderStateMixin {
  final _controllers = <AnimationController>[];

  /// Gets pseudo-random color (leans more purple, less dark-green).
  ///
  /// Can also use a predefined palette of colors.
  Color _getRandomColor([int alpha]) {
    return Color.fromARGB(alpha ?? 255, _random.nextInt(155) + 100,
        _random.nextInt(255), _random.nextInt(150) + 55);
  }

  @override
  void initState() {
    super.initState();
    _durations.forEach((Duration d) {
      _controllers.add(AnimationController(
        vsync: this,
        duration: d,
      ));
    });

    for (final controller in _controllers) {
      controller.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
      controller.forward();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((AnimationController c) => c.dispose());
    super.dispose();
  }

  /// Glitter piece that animates between opaque and transparent, and also
  /// moves.
  Widget _createAnimatedGlitterPiece() {
    final customController = _controllers[_random.nextInt(5)];

    final colorTween =
        ColorTween(begin: _getRandomColor(), end: Colors.transparent);
    final tweenAnimation = colorTween.animate(customController);

    final positionAnimation =
        CurveTween(curve: ElasticInCurve()).animate(customController);

    final pieceSize = _randomPieceSize();

    final topOffset = _random.nextDouble() * (_height - pieceSize);
    final leftOffset = _random.nextDouble() * (_width - pieceSize);

    return AnimatedBuilder(
      animation: customController,
      builder: (BuildContext context, Widget widget) {
        final piece = Container(
          width: pieceSize,
          height: pieceSize,
          decoration: _randomDecoration().copyWith(color: tweenAnimation.value),
        );

        return Positioned(
          top: topOffset + (positionAnimation.value * _random.nextInt(30) - 15),
          left:
              leftOffset + (positionAnimation.value * _random.nextInt(30) - 15),
          child: piece,
        );
      },
    );
  }

  /// Glitter piece that animates between transparent and opaque.
  Widget _createReverseAnimatedGlitterPiece() {
    final customController = _controllers[_random.nextInt(5)];

    final colorTween =
        ColorTween(begin: Colors.transparent, end: _getRandomColor());
    final animation = colorTween.animate(customController);
    final pieceSize = _randomPieceSize();
    final piece = AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget widget) {
        return Container(
          decoration: _randomDecoration().copyWith(color: animation.value),
          width: pieceSize,
          height: pieceSize,
        );
      },
    );
    final topOffset = _random.nextDouble() * (_height - pieceSize);
    final leftOffset = _random.nextDouble() * (_width - pieceSize);

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: piece,
    );
  }

  /// Static glitter piece.
  Widget _createStaticGlitterPiece() {
    final pieceSize = _randomPieceSize();
    final piece = Container(
      decoration: _randomDecoration().copyWith(color: _getRandomColor(170)),
      width: pieceSize,
      height: pieceSize,
    );
    final topOffset = _random.nextDouble() * _height;
    final leftOffset = _random.nextDouble() * _width;

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: piece,
    );
  }

  /// T-shaped sparkle.
  Widget _createSparkle() {
    final customController = _controllers[_random.nextInt(_durations.length)];
    final colorTween = ColorTween(begin: Colors.transparent, end: Colors.white);
    final animation = colorTween.animate(customController);
    final sparkleSize = _random.nextInt(80).toDouble() + 20;
    final piece = AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget widget) {
        final decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          backgroundBlendMode: BlendMode.colorDodge,
          gradient: RadialGradient(
            colors: [Colors.white, Colors.transparent],
            stops: [-.1, .1],
            radius: sparkleSize,
          ),
          color: animation.value,
        );
        final vertical = Container(
          width: 4,
          height: sparkleSize,
          decoration: decoration,
        );
        final horizontal = Container(
          width: sparkleSize,
          height: 4,
          decoration: decoration,
        );
        return Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: sparkleSize / 2 - 2),
              child: vertical,
            ),
            Padding(
              padding: EdgeInsets.only(top: sparkleSize / 2 - 2),
              child: horizontal,
            ),
          ],
        );
      },
    );
    final topOffset = _random.nextDouble() * _height;
    final leftOffset = _random.nextDouble() * _width;

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: piece,
    );
  }

  /// Creates a nice mix of various glitter pieces.
  List<Widget> _createGlitterPieces(int numPieces) {
    final pieces = <Widget>[];

    for (var i = 0; i < numPieces; i++) {
      pieces.add(_createStaticGlitterPiece());

      if (i % 16 == 0) {
        pieces.add(_createAnimatedGlitterPiece());
      }

      if (i % 2 == 0) {
        pieces.add(_createReverseAnimatedGlitterPiece());
      }

      if (i % 30 == 0) {
        pieces.add(_createSparkle());
      }
    }

    return pieces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        height: _height,
        width: _width,
        color: Colors.pink[100],
        // 10000 is a bad idea!
        child: Stack(children: _createGlitterPieces(1200)),
      )),
    );
  }
}
