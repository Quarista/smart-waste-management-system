import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String category;
  final String overview;
  final String approach;
  final String thumbnail;
  final List<dynamic>? subImages;
  final String id;
  final Timestamp? timestamp;

  Post(
    this.subImages,
    this.timestamp, {
    required this.title,
    required this.category,
    required this.overview,
    required this.approach,
    required this.thumbnail,
    required this.id,
  });
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map postData = doc.data() as Map;

    return Post(
      id: doc.id,
      title: postData['title'] ?? 'Unknown Post',
      category: postData['category'] ?? 'Unknown',
      overview: postData['overviewText'] ?? '',
      approach: postData['approachText'] ?? '',
      thumbnail: postData['src'] ??
          'https://i.ibb.co/C51TLWKG/Screenshot-2025-03-09-192257.png',
      postData['smallImages'] ?? [],
      postData['timestamp'],
    );
  }
}
