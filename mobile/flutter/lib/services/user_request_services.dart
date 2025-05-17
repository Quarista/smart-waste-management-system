// import 'package:swms_administration/models/user_request_model.dart';

// class UserRequestServices {
//   final List<UserRequest> userRequests = [
//     UserRequest(
//       '',
//       content:
//           'I just wanted to reach out and say how much I appreciate the effort you’re putting into the tracking feature. I know these challenges can feel overwhelming at times, but each bump is a stepping stone and a chance to learn. I truly admire your dedication and ingenuity.\nIf you ever feel stuck or just want to chat about ideas, I’m here for you. Your work is important, and I have every confidence in your ability to find a way forward. Keep believing in yourself—you all are doing great.',
//       user: 'samanperera@gmail.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: false,
//       isReport: false,
//     ),
//     UserRequest(
//       '',
//       content:
//           'I just wanted to reach out and say how much I appreciate the effort you’re putting into the tracking feature. I know these challenges can feel overwhelming at times, but each bump is a stepping stone and a chance to learn. I truly admire your dedication and ingenuity.\nIf you ever feel stuck or just want to chat about ideas, I’m here for you. Your work is important, and I have every confidence in your ability to find a way forward. Keep believing in yourself—you all are doing great.',
//       user: 'samanperera@gmail.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: false,
//       isReport: false,
//     ),
//     UserRequest(
//       '',
//       content:
//           'I’m experiencing issues with the tracking feature on your website—it’s not displaying the correct information. Could you please look into this problem and assist me in resolving it? I appreciate your help.',
//       user: 'suniledealwis@slt.net',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: false,
//       isReport: true,
//     ),
//     UserRequest(
//       'Our application might have problems when running on old models. We apologize for the inconvinience.',
//       content: 'The app is not functioning on my phone',
//       user: 'pwpeires@onmicrosoft.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: true,
//     ),
//     UserRequest(
//       'Thank you for your message. Your support means a lot to us!',
//       content: 'Well Done!Great Work.....Functions really well!',
//       user: 'slthome@slt.net.lk',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: false,
//     ),
//     UserRequest(
//       'Yes......Except for weekends',
//       content: 'Do you do waste collection everyday',
//       user: 'npahasara@microsoft.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: false,
//     ),
//     UserRequest(
//       'Thank you sir!',
//       content: 'Well Done!',
//       user: 'yuvinducosta@outlook.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: false,
//     ),
//     UserRequest(
//       'Sorry for the inconvinience caused',
//       content: 'NOT WORKING',
//       user: 'lakhirulanka2018@gmail.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: false,
//     ),
//     UserRequest(
//       '',
//       content:
//           'I just wanted to reach out and say how much I appreciate the effort you’re putting into the tracking feature. I know these challenges can feel overwhelming at times, but each bump is a stepping stone and a chance to learn. I truly admire your dedication and ingenuity.\nIf you ever feel stuck or just want to chat about ideas, I’m here for you. Your work is important, and I have every confidence in your ability to find a way forward. Keep believing in yourself—you all are doing great.',
//       user: 'lahiruanjanap1999@gmail.com',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: false,
//       isReport: false,
//     ),
//     UserRequest(
//       'Thank you sir!',
//       content: 'Well Done!',
//       user: 'pomidus@yahoo.net',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: false,
//     ),
//     UserRequest(
//       'Try the new version of our mobile app',
//       content: 'NOT WORKING',
//       user: 'meetsl@hwb.cymru.net',
//       date: DateTime.now(),
//       time: DateTime.now(),
//       isReplied: true,
//       isReport: true,
//     ),
//   ];
//   void reply(UserRequest request) {
//     userRequests.removeWhere((request) => request == request);
//     userRequests.add(
//       UserRequest(request.reply,
//           content: request.content,
//           user: request.content,
//           date: request.date,
//           time: request.time,
//           isReplied: true,
//           isReport: request.isReport),
//     );
//   }
// }
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swms_administration/models/user_request_model.dart';

class UserRequestServices extends ChangeNotifier {
  final List<UserRequest> _allRequests = [];
  final Map<String, UserRequest> _requestsMap = {};
  List<UserRequest> get allRequests => _allRequests;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String? error;
  StreamSubscription<QuerySnapshot>? _requestsSubscription;

  // Constructor to start listening to Firestore
  UserRequestServices() {
    _setupRequestsListener();
  }
  void _setupRequestListener() {
    _requestsSubscription = _firestore
        .collection('user_submissions')
        .snapshots()
        .listen((snapshot) {
      final updatedRequests =
          snapshot.docs.map((doc) => UserRequest.fromFirestore(doc)).toList();

      // Update only changed Requests
      for (UserRequest newRequest in updatedRequests) {
        final existingIndex =
            _allRequests.indexWhere((b) => b.id == newRequest.id);
        if (existingIndex >= 0) {
          _allRequests[existingIndex] = newRequest;
        } else {
          _allRequests.add(newRequest);
        }
        _requestsMap[newRequest.id] = newRequest;
      }

      notifyListeners(); // This is crucial
    });
  }

  UserRequest? getUserRequestByDocumentId(String documentId) =>
      _requestsMap[documentId];

  // Setup a real-time listener for Requests data
  void _setupRequestsListener() {
    isLoading = true;
    error = null;
    notifyListeners();

    // Cancel any existing subscription
    _requestsSubscription?.cancel();

    //Listen to user_submissions collection
    _requestsSubscription = _firestore
        .collection('user_submissions')
        .snapshots()
        .listen((snapshot) {
      //Clear existing Requests
      allRequests.clear();
      // _firestore.collection('user_submissions').orderBy(
      //       'timestamp',
      //       descending: true,
      //     );
      // Process each document
      for (var doc in snapshot.docs) {
        Map<String, dynamic> userRequestData =
            doc.data() as Map<String, dynamic>;

        // Create a Requests object from the Firestore data
        UserRequest request = UserRequest(
          userRequestData['reply'] ?? '',
          id: doc.id,
          content: userRequestData['message'] ?? '',
          user:
              '${userRequestData['firstname'] ?? ''} ${userRequestData['lastname'] ?? ''}',
          date: DateTime.parse((userRequestData['timestamp'])).toLocal(),
          time: DateTime.parse((userRequestData['timestamp'])).toLocal(),
          isReport: userRequestData['subject'] == 'bug'
              ? true
              : userRequestData['subject'] == 'support'
                  ? false
                  : null,
          isReplied: userRequestData['replied'] ?? false,
          email: userRequestData['email'] ?? '',
        );
        allRequests.add(request);
      }

      // // Sort the allRequests list based on the timestamp field
      // allRequests.sort((a, b) {
      //   final aTimestamp = (snapshot.docs
      //       .firstWhere((doc) => doc.id == a.id)
      //       .data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
      //   final bTimestamp = (snapshot.docs
      //       .firstWhere((doc) => doc.id == b.id)
      //       .data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
      //   return bTimestamp?.compareTo(aTimestamp ?? Timestamp.now()) ?? 0;
      // });
      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error in requests listener: $error');
      isLoading = false;
      this.error = error.toString();
      _populateDefaultRequests();
      notifyListeners();
    });
  }

  // Clean up resources when no longer needed
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }

  // Fallback method to populate with default data in case of errors
  void _populateDefaultRequests() {
    allRequests.clear();
    for (int i = 0; i < 5; i++) {
      allRequests.add(
        UserRequest(
          '',
          time: DateTime.now(),
          date: DateTime.now(),
          content:
              'Welcome to the Public Requests Page\nThis page is a transparent hub where you can see all the public requests and feedback regarding the Smart Dustbin System. Here, every user-submitted request is displayed with vital information such as the submission date, current status, and a brief description. This allows everyone to stay informed about the issues, ideas, and improvements that matter most to our community.\nA Space for Collective Insight\nOur goal with this page is to foster a collaborative environment. By displaying public requests openly, we invite you to view, comment on, or discuss the challenges and suggestions raised by other users. Whether you\'re interested in understanding community needs or tracking the progress of specific initiatives, this page serves as a real-time reflection of the collective voice driving the evolution of our smart waste management system.',
          isReplied: false,
          isReport: null,
          user: 'The Development Team',
          email: 'contact.quarista@gmail.com',
          id: '${i + 1}',
        ),
      );
    }
  }

  // Method to refresh data manually
  void refreshRequests() {
    _setupRequestsListener();
  }

  // Method to get a specific bin by ID
  UserRequest? getRequestById(String id) {
    try {
      return allRequests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to search request by user or email
  List<UserRequest> searchRequests(String query) {
    if (query.isEmpty) {
      return allRequests;
    }

    return allRequests
        .where((request) =>
            request.user.toLowerCase().contains(query.toLowerCase()) ||
            request.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
