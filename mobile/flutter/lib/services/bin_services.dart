// import 'package:swms_administration/models/bin_model.dart';

// class BinServices {
//   final List<Bin> allBins = [
//     Bin(
//         capacity: 45,
//         id: 1,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Major',
//         name: 'Pagama 1',
//         fillLevel: 0,
//         gasLevel: 0.2,
//         fillStatus: false,
//         isClosed: false,
//         isSub: false,
//         '',
//         location:
//             'https://www.google.com/maps/place/Kubuka+Rd,+Gonapola,+Sri+Lanka/@6.7260173,80.0143775,17z/data=!3m1!4b1!4m15!1m8!3m7!1s0x3ae24bf9820ee46d:0x55d546eb49295f88!2sRaigama+North,+Sri+Lanka!3b1!8m2!3d6.7266167!4d80.0164621!16s%2Fg%2F1hhws5xrd!3m5!1s0x3ae24bfa3522767b:0x21454d8fa01a9c1!8m2!3d6.726012!4d80.0169524!16s%2Fg%2F11y9n2fctt?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 80,
//         id: 4,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Mannar 2',
//         fillLevel: 20,
//         gasLevel: 0.4,
//         fillStatus: false,
//         isClosed: true,
//         isSub: true,
//         'Mannar 1',
//         location:
//             'https://www.google.com/maps/place/Pahalagama,+Sri+Lanka/@6.7097664,80.5100008,14z/data=!3m1!4b1!4m6!3m5!1s0x3ae394650d44c2e3:0x18983eb9262961aa!8m2!3d6.7097244!4d80.5306005!16s%2Fg%2F11bzv7qdwt?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 50,
//         id: 2,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Major',
//         name: 'Pagama 2',
//         fillLevel: 50,
//         gasLevel: 0.2,
//         fillStatus: true,
//         isClosed: true,
//         isSub: false,
//         '',
//         location:
//             'https://www.google.com/maps/place/Ragama,+Sri+Lanka/@7.0306946,79.9113572,14z/data=!3m1!4b1!4m6!3m5!1s0x3ae2f9cdbed9d9b1:0xedfad658ec11530!8m2!3d7.0280037!4d79.923!16s%2Fm%2F04fzp49?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 42,
//         id: 3,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Major',
//         name: 'Pagama 3',
//         fillLevel: 40,
//         gasLevel: 0.8,
//         fillStatus: false,
//         isClosed: false,
//         isSub: false,
//         '',
//         location:
//             'https://www.google.com/maps/place/Narangoda+Paluwa,+Sri+Lanka/@7.0386602,79.9193282,15z/data=!3m1!4b1!4m9!1m2!2m1!1sHotels!3m5!1s0x3ae2f9c63ca24173:0x9722ee6d32018849!8m2!3d7.0386393!4d79.9377823!16s%2Fg%2F11cs6gbqqh?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 80,
//         id: 4,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Mannar 2',
//         fillLevel: 20,
//         gasLevel: 0.4,
//         fillStatus: false,
//         isClosed: true,
//         isSub: true,
//         'Mannar 1',
//         location:
//             'https://www.google.com/maps/place/Kendaliyeddapaluwa+West,+Sri+Lanka/@7.0325117,79.9055869,14z/data=!3m1!4b1!4m15!1m8!3m7!1s0x3ae2f9cdbed9d9b1:0xedfad658ec11530!2sRagama,+Sri+Lanka!3b1!8m2!3d7.0280037!4d79.923!16s%2Fm%2F04fzp49!3m5!1s0x3ae2f9b5e30e550b:0x61a0d8f52fe98185!8m2!3d7.0313746!4d79.9430537!16s%2Fg%2F11fn1s24g4?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 80,
//         id: 4,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Major',
//         name: 'Mannar 1',
//         fillLevel: 20,
//         gasLevel: 0.4,
//         fillStatus: false,
//         isClosed: true,
//         isSub: false,
//         '',
//         location:
//             'https://www.google.com/maps/place/Narangoda+Paluwa,+Sri+Lanka/@7.0386602,79.9193282,15z/data=!3m1!4b1!4m9!1m2!2m1!1sHotels!3m5!1s0x3ae2f9c63ca24173:0x9722ee6d32018849!8m2!3d7.0386393!4d79.9377823!16s%2Fg%2F11cs6gbqqh?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 50,
//         id: 5,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Minor',
//         name: 'Ragama 1',
//         fillLevel: 50,
//         gasLevel: 0.6,
//         fillStatus: true,
//         isClosed: false,
//         isSub: false,
//         '',
//         location:
//             'https://www.google.com/maps/place/Spice+Island+Restaurant+%26+Takeaway/@51.524453,-3.162112,14z/data=!4m10!1m2!2m1!1sRestaurants!3m6!1s0x486e1d0ed8d22ac9:0x8add09c34e373f30!8m2!3d51.5091646!4d-3.1317721!15sCgtSZXN0YXVyYW50c1oNIgtyZXN0YXVyYW50c5IBEWluZGlhbl9yZXN0YXVyYW504AEA!16s%2Fg%2F1xtf0_k2?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoJLDEwMjExNDUzSAFQAw%3D%3D'),
//     Bin(
//         capacity: 42,
//         id: 3,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Pagama 6',
//         fillLevel: 40,
//         gasLevel: 0.8,
//         fillStatus: false,
//         isClosed: false,
//         isSub: true,
//         'Pagama 2',
//         location:
//             'https://www.google.com/maps/place/Spice+Island+Restaurant+%26+Takeaway/@51.524453,-3.162112,14z/data=!4m10!1m2!2m1!1sRestaurants!3m6!1s0x486e1d0ed8d22ac9:0x8add09c34e373f30!8m2!3d51.5091646!4d-3.1317721!15sCgtSZXN0YXVyYW50c1oNIgtyZXN0YXVyYW50c5IBEWluZGlhbl9yZXN0YXVyYW504AEA!16s%2Fg%2F1xtf0_k2?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoJLDEwMjExNDUzSAFQAw%3D%3D'),
//     Bin(
//         capacity: 50,
//         id: 5,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Pagama 7',
//         fillLevel: 50,
//         gasLevel: 0.6,
//         fillStatus: true,
//         isClosed: false,
//         isSub: true,
//         'Pagama 2',
//         location:
//             'https://www.google.com/maps/place/Pagama+Island/@-1.8190721,126.3511185,12.25z/data=!4m6!3m5!1s0x2d7a6f744e9c06ed:0xbc1a17f788713468!8m2!3d-1.8171493!4d126.4310251!16s%2Fg%2F11c533r9r1?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 45,
//         id: 1,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Pagama 4',
//         fillLevel: 30,
//         gasLevel: 0.2,
//         fillStatus: false,
//         isClosed: false,
//         isSub: true,
//         'Pagama 1',
//         location:
//             'https://www.google.com/maps/place/Pagama+Island/@-1.8190721,126.3511185,12.25z/data=!4m6!3m5!1s0x2d7a6f744e9c06ed:0xbc1a17f788713468!8m2!3d-1.8171493!4d126.4310251!16s%2Fg%2F11c533r9r1?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//     Bin(
//         capacity: 50,
//         id: 2,
//         imageUrl: 'assets/images/Pagama.png',
//         type: 'Branch',
//         name: 'Pagama 5',
//         fillLevel: 50,
//         gasLevel: 0.2,
//         fillStatus: true,
//         isClosed: true,
//         isSub: true,
//         'Pagama 2',
//         location:
//             'https://www.google.com/maps/place/Pagama+Island/@-1.8190721,126.3511185,12.25z/data=!4m6!3m5!1s0x2d7a6f744e9c06ed:0xbc1a17f788713468!8m2!3d-1.8171493!4d126.4310251!16s%2Fg%2F11c533r9r1?entry=ttu&g_ep=EgoyMDI1MDMxMi4wIKXMDSoASAFQAw%3D%3D'),
//   ];
// }

//here is the for loop method to Firestore

// import 'package:swms_administration/models/bin_model.dart';

// class BinServices {
//   final List<Bin> allBins = [];

//   // Constructor to create and populate allBins
//   BinServices() {
//     // Create the same Bin 50 times and add them to the list
//     for (int i = 0; i < 50; i++) {
//       allBins.add(
//         Bin(
//           capacity: 45,
//           id: i + 1, // To make each bin have a unique ID
//           imageUrl: 'assets/images/Pagama.png',
//           type: 'Major',
//           name: 'Pagama ${i + 1}',
//           fillLevel: 30,
//           gasLevel: 0.2,
//           fillStatus: false,
//           isClosed: false,
//           isSub: false,
//           '',
//           location:
//               '', // If this is supposed to be a placeholder for some property, add that here
//         ),
//       );
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swms_administration/models/bin_model.dart';

class BinServices extends ChangeNotifier {
  final List<Bin> _allBins = [];
  final Map<String, Bin> _binMap = {};

  List<Bin> get allBins => _allBins;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String? error;
  StreamSubscription<QuerySnapshot>? _binsSubscription;

  // Constructor to start listening to Firestore
  BinServices() {
    _setupBinsListener();
  }
  void _setupBinListener() {
    _binsSubscription =
        _firestore.collection("Dustbins").snapshots().listen((snapshot) {
      final updatedBins =
          snapshot.docs.map((doc) => Bin.fromFirestore(doc)).toList();

      // Update only changed bins
      for (Bin newBin in updatedBins) {
        final existingIndex = _allBins.indexWhere((b) => b.id == newBin.id);
        if (existingIndex >= 0) {
          _allBins[existingIndex] = newBin;
        } else {
          _allBins.add(newBin);
        }
        _binMap[newBin.id] = newBin;
      }

      notifyListeners(); // This is crucial
    });
  }

  Bin? getBinByDocumentId(String documentId) => _binMap[documentId];
  // Setup a real-time listener for bin data
  void _setupBinsListener() {
    isLoading = true;
    error = null;
    notifyListeners();

    // Cancel any existing subscription
    _binsSubscription?.cancel();

    // Listen to the Dustbins collection
    _binsSubscription =
        _firestore.collection("Dustbins").snapshots().listen((snapshot) {
      // Clear existing bins
      allBins.clear();

      // Process each document
      for (var doc in snapshot.docs) {
        Map<String, dynamic> binData = doc.data() as Map<String, dynamic>;

        // Create a Bin object from the Firestore data
        Bin bin = Bin(
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

        allBins.add(bin);
      }

      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error in bins listener: $error');
      isLoading = false;
      this.error = error.toString();
      _populateDefaultBins();
      notifyListeners();
    });
  }

  // Clean up resources when no longer needed
  void dispose() {
    _binsSubscription?.cancel();
    super.dispose();
  }

  // Fallback method to populate with default data in case of errors
  void _populateDefaultBins() {
    allBins.clear();
    for (int i = 0; i < 5; i++) {
      allBins.add(
        Bin(
          '', // mainBin
          id: 'bin ${i + 1}',
          name: 'Pagama ${i + 1}',
          imageUrl: 'assets/images/Pagama.png',
          fillLevel: 30,
          gasLevel: 0.2,
          humidity: 0.43,
          temperature: 28,
          precipitation: 0.02,
          fillStatus: false,
          isClosed: false,
          isControllerOnClosed: false,
          type: 'Major',
          capacity: 45,
          isSub: false,
          location: '',
          latitude: 51.533114,
          longitude: -3.152321,
          networkStatus: true,
          isManual: true,
        ),
      );
    }
  }

  // Method to refresh data manually
  void refreshBins() {
    _setupBinsListener();
  }

  // Method to get a specific bin by ID
  Bin? getBinById(int id) {
    try {
      return allBins.firstWhere((bin) => bin.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to search bins by name, type, or location
  List<Bin> searchBins(String query) {
    if (query.isEmpty) {
      return allBins;
    }

    return allBins
        .where((bin) =>
            bin.name.toLowerCase().contains(query.toLowerCase()) ||
            bin.type.toLowerCase().contains(query.toLowerCase()) ||
            bin.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class BinHistoryTracker {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Timer? _hourlyTimer;
  static bool _isUpdating = false;

  static void startTracking() {
    _updateBinStats(); // Initial update
    _hourlyTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      // Test with 1 minute first
      if (!_isUpdating) _updateBinStats();
    });
  }

  static Future<void> _updateBinStats() async {
    _isUpdating = true;
    try {
      // 1. Get bins with null safety
      final bins = await _firestore.collection('Dustbins').get();
      if (kDebugMode) print('Fetched ${bins.docs.length} bins');

      int filled = 0, empty = 0;

      // 2. Calculate stats
      for (final doc in bins.docs) {
        final data = doc.data();
        final capacity =
            (data['capacity'] as num?)?.toInt() ?? 1; // Handle null
        final fillLevel = (data['fillLevel'] as num?)?.toInt() ?? 0;

        if (fillLevel > capacity - 1) filled++;
        if (fillLevel == 0) empty++;
      }

      // 3. Force UTC timestamp with server time
      await _firestore.collection('DustbinHistory').add({
        'timestamp': FieldValue.serverTimestamp(), // Critical change
        'filled': filled,
        'empty': empty,
      });

      // 4. Cleanup old docs
      final history = await _firestore
          .collection('DustbinHistory')
          .orderBy('timestamp', descending: false)
          .get();

      if (history.docs.length > 96) {
        final batch = _firestore.batch();
        history.docs
            .sublist(0, history.docs.length - 96)
            .forEach((doc) => batch.delete(doc.reference));
        await batch.commit();
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('ERROR: $e');
        print(stack);
      }
    } finally {
      _isUpdating = false;
    }
  }

  static void dispose() {
    _hourlyTimer?.cancel();
  }
}
