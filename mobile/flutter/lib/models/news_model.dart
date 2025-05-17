import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:string_2_icon/string_2_icon.dart';

class DeveloperNews {
  final String title;
  final String content;
  final DateTime date;
  final IconData icon;
  final String id;

  DeveloperNews({
    required this.title,
    required this.content,
    required this.date,
    required this.icon,
    required this.id,
  });

  factory DeveloperNews.fromFirestore(DocumentSnapshot doc) {
    Map newsData = doc.data() as Map;

    return DeveloperNews(
      id: doc.id,
      title: newsData['title'],
      content: newsData['content'],
      date: (newsData['date'] as Timestamp).toDate(),
      icon: String2Icon.getIconDataFromString(newsData['icon']) ??
          Icons.format_list_bulleted_rounded,
    );
  }
}
