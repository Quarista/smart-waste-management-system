import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:string_2_icon/string_2_icon.dart';
import 'package:swms_administration/models/news_model.dart';

class NewsServices extends ChangeNotifier {
  final List<DeveloperNews> _allNews = [];
  final Map<String, DeveloperNews> _newsMap = {};

  List<DeveloperNews> get allNews => _allNews;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String? error;
  StreamSubscription<QuerySnapshot>? _newsSubscription;

  // Constructor to start listening to Firestore
  NewsServices() {
    _setupNewsListener();
  }

  DeveloperNews? getNewsByDocumentId(String documentId) => _newsMap[documentId];
  // Setup a real-time listener for bin data
  void _setupNewsListener() {
    isLoading = true;
    error = null;
    notifyListeners();

    // Cancel any existing subscription
    _newsSubscription?.cancel();

    // Listen to the Dustbins collection
    _newsSubscription =
        _firestore.collection("DeveloperNews").snapshots().listen((snapshot) {
      // Clear existing bins
      allNews.clear();

      // Process each document
      for (var doc in snapshot.docs) {
        Map<String, dynamic> newsData = doc.data() as Map<String, dynamic>;
        // Create a Bin object from the Firestore data
        DeveloperNews news = DeveloperNews(
          id: doc.id,
          title: newsData['title'],
          content: newsData['content'],
          date: (newsData['date'] as Timestamp).toDate(),
          icon: String2Icon.getIconDataFromString(newsData['icon']) ??
              Icons.newspaper_rounded,
        );

        allNews.add(news);
      }

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error in news listener: $error');
      isLoading = false;
      this.error = error.toString();
      _populateDefaultNews();
      notifyListeners();
    });
  }

  // Clean up resources when no longer needed
  void dispose() {
    _newsSubscription?.cancel();
    super.dispose();
  }

  // Fallback method to populate with default data in case of errors
  void _populateDefaultNews() {
    allNews.clear();
    for (int i = 0; i < 5; i++) {
      allNews.add(
        DeveloperNews(
          title: 'Welcome to EquaBin!',
          content:
              'Hope you will have a great journey with EquaBin in the Future!',
          date: DateTime.now(),
          icon: Icons.widgets,
          id: i.toString(),
        ),
      );
    }
  }

  // Method to refresh data manually
  void refreshNews() {
    _setupNewsListener();
  }

  // Method to get a specific bin by ID
  DeveloperNews? getNewsById(int id) {
    try {
      return allNews.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to search bins by name, type, or location
  List<DeveloperNews> searchBins(String query) {
    if (query.isEmpty) {
      return allNews;
    }

    return allNews
        .where(
          (bin) =>
              bin.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              bin.content.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
        )
        .toList();
  }
}
