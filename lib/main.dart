import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

const _width = 300.0;
const _height = 500.0;
const _durations = <Duration>[
  Duration(milliseconds: 100),
  Duration(milliseconds: 200),
  Duration(milliseconds: 300),
  Duration(milliseconds: 400),
  Duration(milliseconds: 500),
  Duration(milliseconds: 1000)
];
final _random = math.Random();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  final _controllers = <AnimationController>[];

  //Animation _animation;

  Color _getRandomColor() {
    return Color.fromARGB(
        255, _random.nextInt(255), _random.nextInt(255), _random.nextInt(255));
  }

  @override
  void initState() {
    super.initState();
    _durations.forEach((Duration d) {
      _controllers.add(AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
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

//  @override
//  void didUpdateWidget(Foo oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    _controller.duration = _duration;
//  }

  @override
  void dispose() {
    _controllers.forEach((AnimationController c) => c.dispose());
    super.dispose();
  }

  Widget _createAnimatedGlitterPiece() {
    final customController = _controllers[_random.nextInt(5)];

    final colorTween =
    ColorTween(begin: _getRandomColor(), end: Colors.transparent);
    final tweenAnimation = colorTween.animate(customController);

    final positionAnimation =
    CurveTween(curve: ElasticInCurve()).animate(customController);

    final pieceSize = 4.0;

    final topOffset = _random.nextDouble() * (_height - pieceSize);
    final leftOffset = _random.nextDouble() * (_width - pieceSize);


    return AnimatedBuilder(
      animation: customController,
      builder: (BuildContext context, Widget widget) {
        final piece = Container(
            width: pieceSize, height: pieceSize, color: tweenAnimation.value);

        return Positioned(
          top: topOffset + (positionAnimation.value * _random.nextInt(15)),
          left: leftOffset + (positionAnimation.value * _random.nextInt(15)),
          child: piece,
        );
      },
    );
  }

  Widget _createReverseAnimatedGlitterPiece() {
    final customController = _controllers[_random.nextInt(5)];

    final colorTween =
    ColorTween(begin: Colors.transparent, end: _getRandomColor());
    final animation = colorTween.animate(customController);
    final pieceSize = 5.0;
    final piece = AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget widget) {
        return Container(
            width: pieceSize, height: pieceSize, color: animation.value);
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

  Widget _createStaticGlitterPiece() {
    final pieceSize = 7.0;
    final piece = Container(
        width: pieceSize, height: pieceSize, color: _getRandomColor());
    final topOffset = _random.nextDouble() * (_height - pieceSize);
    final leftOffset = _random.nextDouble() * (_width - pieceSize);

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: piece,
    );
  }

  List<Widget> _createGlitterPieces(int numPieces) {
    final pieces = <Widget>[];
//    for (var i = 0; i < numPieces; i++) {
//      pieces.add(_createStaticGlitterPiece());
//    }
    for (var i = 0; i < numPieces; i++) {
      pieces.add(_createAnimatedGlitterPiece());
    }
//    for (var i = 0; i < numPieces; i++) {
//      pieces.add(_createReverseAnimatedGlitterPiece());
//    }
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
            child: Stack(children: _createGlitterPieces(1000)),
          )),
    );
  }
}