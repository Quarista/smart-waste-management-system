import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

class UserRequest {
  final String id;
  final String content;
  final String user;
  final String? reply;
  final DateTime date;
  final DateTime time;
  final bool isReplied;
  final bool? isReport;
  final String email;

  UserRequest(
    this.reply, {
    required this.content,
    required this.user,
    required this.date,
    required this.time,
    required this.isReplied,
    required this.isReport,
    required this.email,
    required this.id,
  });
  factory UserRequest.fromFirestore(DocumentSnapshot doc) {
    Map userRequestData = doc.data() as Map;
    return UserRequest(
      userRequestData['reply']??'',
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
      isReplied: userRequestData['replied']?? false,
      email: userRequestData['email']?? '',
    );
  }
}
