import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String eventId; // 행사 ID
  final String userUid; // 사용자 고유 ID
  final String userName; // 사용자 이름 (추가: 리스트 띄울 때 편함)
  final DateTime timestamp; // 출석 시간
  final String status; // 상태 (추가: 출석/지각/조퇴)

  AttendanceModel({
    required this.eventId,
    required this.userUid,
    required this.userName, // 추가
    required this.timestamp,
    this.status = '출석', // 추가
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        eventId: json['eventId'] ?? '',
        userUid: json['userUid'] ?? '',
        userName: json['userName'] ?? '', // 추가
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        status: json['status'] ?? '출석', // 추가
      );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userUid': userUid,
    'userName': userName, // 추가
    'timestamp': timestamp,
    'status': status, // 추가
  };
}
