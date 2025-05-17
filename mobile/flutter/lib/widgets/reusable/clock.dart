import 'dart:async';
import 'package:flutter/material.dart';

class RealTimeClock extends StatefulWidget {
  final TextStyle style;
  final bool isClock;
  const RealTimeClock({super.key, required this.style, required this.isClock,});

  @override
  _RealTimeClockState createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatCurrentTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeString = _formatCurrentTime();
      });
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: widget.style,
    );
  }
}
