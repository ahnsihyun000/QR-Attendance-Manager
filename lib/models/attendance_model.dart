import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String eventId;
  final String userUid;
  final String userName;
  final DateTime timestamp;
  final String status;

  AttendanceModel({
    required this.eventId,
    required this.userUid,
    required this.userName,
    required this.timestamp,
    this.status = '출석',
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        eventId: json['eventId'] ?? '',
        userUid: json['userUid'] ?? '',
        userName: json['userName'] ?? '',
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        status: json['status'] ?? '출석',
      );
  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    return AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userUid': userUid,
    'userName': userName,
    'timestamp': timestamp,
    'status': status,
  };
}
