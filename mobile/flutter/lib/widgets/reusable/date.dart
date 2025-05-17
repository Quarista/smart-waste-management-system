import 'dart:async';
import 'package:flutter/material.dart';

class RealTimeDate extends StatefulWidget {
  final TextStyle style;
  const RealTimeDate({super.key, required this.style});

  @override
  _RealTimeDateState createState() => _RealTimeDateState();
}

class _RealTimeDateState extends State<RealTimeDate> {
  late String _dateString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _dateString = _formatCurrentDate();
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
        _dateString = _formatCurrentDate();
      });
    });
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _dateString,
      style: widget.style,
    );
  }
}
