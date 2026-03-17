import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String eventId;     // 행사 ID
  final String userUid;     // 사용자 고유 ID
  final DateTime timestamp; // 출석 시간

  AttendanceModel({
    required this.eventId,
    required this.userUid,
    required this.timestamp,
  });

  // DB에서 데이터를 가져올 때 (JSON -> 객체)
  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    eventId: json['eventId'] ?? '',
    userUid: json['userUid'] ?? '',
    timestamp: (json['timestamp'] as Timestamp).toDate(),
  );

  // DB에 데이터를 저장할 때 필수! (객체 -> JSON)
  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userUid': userUid,
    'timestamp': timestamp,
  };
}