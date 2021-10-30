import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

const backgroundColor = Color(0xff57A0BE);
const primaryColor = Color(0xff78E3BC);
const secondaryColor = Color(0xff357293);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _stopWatchController;
  late AnimationController _playPauseController;
  @override
  void initState() {
    _stopWatchController =
        AnimationController(vsync: this, duration: const Duration(minutes: 2));
    _playPauseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    super.initState();
  }

  _stopTimer() {
    _stopWatchController.stop();
  }

  _startTimer() {
    _stopWatchController.reverse(
        from: _stopWatchController.value == 0.0
            ? 1.0
            : _stopWatchController.value);
  }

  String get duration {
    Duration duration =
        _stopWatchController.duration! * _stopWatchController.value;
    return "${duration.inMinutes.toString().padLeft(2, '0')} : ${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff57A0BE),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 400,
                child: AnimatedBuilder(
                  animation: _stopWatchController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          painter: StopWatch(
                            progressAnimation: _stopWatchController.value,
                            colorAnimation: _playPauseController,
                          ),
                          size: const Size(180, 180),
                        ),
                        MiddleChild(
                            animationController: _playPauseController,
                            time: duration,
                            startTimer: _startTimer,
                            stopTimer: _stopTimer),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const DummyUI()
            ],
          ),
        ),
        bottomNavigationBar: const PlaceHolderBottomNav());
  }
}

class DummyUI extends StatelessWidget {
  const DummyUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.all(2),
              height: index == 0 ? 30 : 25,
              width: index == 0 ? 30 : 25,
              decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: index == 0
                      ? Border.all(color: secondaryColor, width: 5)
                      : null),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          "Focus",
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600),
        ),
        const Text(
          "2 min",
          style: TextStyle(
              color: primaryColor, fontSize: 26, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class PlaceHolderBottomNav extends StatelessWidget {
  const PlaceHolderBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight,
      color: Colors.black.withOpacity(0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(
            Icons.home,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.settings,
            color: Colors.white,
            size: 30,
          )
        ],
      ),
    );
  }
}

class MiddleChild extends StatefulWidget {
  const MiddleChild({
    Key? key,
    required this.time,
    required this.startTimer,
    required this.stopTimer,
    required this.animationController,
  }) : super(key: key);
  final String time;
  final VoidCallback startTimer;
  final VoidCallback stopTimer;
  final AnimationController animationController;

  @override
  _MiddleChildState createState() => _MiddleChildState();
}

class _MiddleChildState extends State<MiddleChild> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: widget.animationController,
        builder: (context, value) {
          return Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  widget.animationController.forward();
                  widget.startTimer();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: ui.lerpDouble(
                          400, 0, widget.animationController.value),
                      color: Colors.white,
                    ),
                    Text(
                      widget.time,
                      style: TextStyle(
                        color: Color.lerp(Colors.black, Colors.white,
                            widget.animationController.value),
                        fontWeight: FontWeight.w600,
                        fontSize: ui.lerpDouble(
                            30, 80, widget.animationController.value),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: widget.animationController.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 200,
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.animationController.reverse(from: 1.0);
                          widget.stopTimer();
                        },
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class StopWatch extends CustomPainter {
  final double progressAnimation;
  final AnimationController colorAnimation;

  StopWatch({
    required this.progressAnimation,
    required this.colorAnimation,
  });
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final _paint = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //angle
    final angle = -((1.0 - progressAnimation) * 2 * pi);

    //Center Point
    final _center = Offset(size.width / 2, size.height / 2);

    //filledCircle
    canvas.drawCircle(
        _center,
        size.width,
        _paint
          ..color =
              Color.lerp(primaryColor, backgroundColor, colorAnimation.value)!
          ..style = PaintingStyle.fill);

    //Background Circle
    canvas.drawCircle(
        _center,
        size.width,
        _paint
          ..color = secondaryColor
          ..style = PaintingStyle.stroke);

    //Arc
    canvas.drawArc(
        Rect.fromCenter(
            center: _center, width: 2 * size.width, height: 2 * size.height),
        pi * 1.5,
        angle,
        false,
        _paint
          ..color =
              Color.lerp(Colors.white, primaryColor, colorAnimation.value)!
          ..style = PaintingStyle.stroke);

    //Calculating Points for thumb
    final xPoint = _center.dx + cos(angle - (pi / 2)) * size.width;
    final yPoint = _center.dy + sin(angle - ((pi / 2))) * size.width;

    //Drawing thumb
    canvas.drawCircle(
        Offset(xPoint, yPoint),
        15,
        Paint()
          ..color =
              Color.lerp(Colors.white, primaryColor, colorAnimation.value)!
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
