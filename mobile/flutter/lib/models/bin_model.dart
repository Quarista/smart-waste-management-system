import 'package:cloud_firestore/cloud_firestore.dart';

class Bin {
  final String id;
  final String name;
  final double fillLevel;
  final double gasLevel;
  final double humidity;
  final double temperature;
  final double precipitation;
  final bool fillStatus;
  final bool isClosed;
  final bool isControllerOnClosed;
  final String imageUrl;
  final String type;
  final double capacity;
  final bool isSub;
  final String? mainBin;
  final String location;
  final double latitude;
  final double longitude;
  final bool networkStatus;
  final bool isManual;

  Bin(
    this.mainBin, {
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.fillLevel,
    required this.gasLevel,
    required this.humidity,
    required this.temperature,
    required this.precipitation,
    required this.fillStatus,
    required this.isClosed,
    required this.isControllerOnClosed,
    required this.type,
    required this.capacity,
    required this.isSub,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.networkStatus,
    required this.isManual,
  });
  factory Bin.fromFirestore(DocumentSnapshot doc) {
    Map binData = doc.data() as Map;
    return Bin(
      binData['mainBin'] ?? '',
      id: doc.id,
      name: binData['name'] ?? 'Unknown Bin',
      imageUrl: binData['imageUrl'] ?? 'assets/images/Pagama.png',
      fillLevel: (binData['fillLevel'] ?? 0).toDouble(),
      gasLevel: (binData['gasLevel'] ?? 0).toDouble(),
      humidity: (binData['humidity'] ?? 0).toDouble(),
      temperature: (binData['temperature'] ?? 0).toDouble(),
      precipitation: (binData['precipitation'] ?? 0).toDouble(),
      fillStatus: binData['fillStatus'] ?? false,
      isClosed: binData['isClosed'] ?? false,
      isControllerOnClosed: binData['isControllerOnClosed'] ?? false,
      type: binData['type'] ?? 'Unknown',
      capacity: (binData['capacity'] ?? 0).toDouble(),
      isSub: binData['isSub'] ?? false,
      location: binData['location'] ?? '',
      latitude: (binData['latitude'] ?? 6.904946).toDouble(),
      longitude: (binData['longitude'] ?? 79.861151).toDouble(),
      networkStatus: binData['networkStatus'] ?? false,
      isManual: binData['isManual'] ?? true,
    );
  }
}
