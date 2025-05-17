import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BinChartData {
  final ValueNotifier<List<FlSpot>> filledSpots = ValueNotifier([]);
  final ValueNotifier<List<FlSpot>> emptySpots = ValueNotifier([]);
  final ValueNotifier<Map<int, String>> bottomTitles = ValueNotifier({});
  final ValueNotifier<Map<double, String>> leftTitles = ValueNotifier({});
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late StreamSubscription<QuerySnapshot> _historySubscription;

  BinChartData() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    _historySubscription = FirebaseFirestore.instance
        .collection('DustbinHistory')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      _processDocuments(snapshot.docs);
    });
  }

  void _processDocuments(List<QueryDocumentSnapshot> docs) {
    final filled = <FlSpot>[];
    final empty = <FlSpot>[];
    final times = <int, String>{};
    double maxYValue = 0;

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate().toLocal();

      final filledValue = (data['filled'] as num).toDouble();
      final emptyValue = (data['empty'] as num).toDouble();

      filled.add(FlSpot(i.toDouble(), filledValue));
      empty.add(FlSpot(i.toDouble(), emptyValue));

      times[i] = _timeFormat.format(timestamp);
      maxYValue = max(maxYValue, max(filledValue, emptyValue));
    }

    leftTitles.value = _calculateYAxisLabels(maxYValue);
    filledSpots.value = filled;
    emptySpots.value = empty;
    bottomTitles.value = times;
  }

  Map<double, String> _calculateYAxisLabels(double maxValue) {
    final step = (maxValue / 4).ceilToDouble();
    return {
      for (double i = 0; i <= 4; i++) i * step: (i * step).toStringAsFixed(0)
    };
  }

  void dispose() {
    _historySubscription.cancel();
    filledSpots.dispose();
    emptySpots.dispose();
    bottomTitles.dispose();
    leftTitles.dispose();
  }
}
