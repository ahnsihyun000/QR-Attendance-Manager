import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/attendance_model.dart';
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🚀 출석 판정 및 중복 방지 코어 로직 (사전 명단 대조)
  Future<String> recordAttendance(AttendanceModel attendance) async {
    try {
      // 1. 고유 문서 ID 생성 (유림이가 올린 데이터의 고유 ID와 완벽히 일치해야 함)
      String customDocId = "${attendance.eventId}_${attendance.userUid}";

      // 2. 해당 학생의 문서가 DB(사전 명단)에 존재하는지 검색
      DocumentReference docRef = _db.collection('attendance').doc(customDocId);
      DocumentSnapshot doc = await docRef.get();

      // [판정 1] 사전 명단에 없는 경우 (미신청자 컷!)
      if (!doc.exists) {
        return "not_registered"; // 화면에 "사전 신청 명단에 없습니다" 띄우기용
      }

      // 문서 데이터 읽어오기
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // [판정 2] 이미 출석 처리가 끝난 사람인 경우 (중복 스캔 방지)
      if (data['status'] == '출석 완료') {
        return "already_checked"; // 화면에 "이미 출석 완료된 학생입니다" 띄우기용
      }

      // [판정 3] 사전 명단에 있고, 아직 출석 전인 경우 -> 출석 처리!
      // 새로 생성(set)하는 게 아니라 기존 명단의 상태만 덮어쓰기(update) 합니다.
      await docRef.update({
        'status': '출석 완료',
        // Firestore 서버의 정확한 현재 시간을 찍어줍니다 (조작 불가)
        'attendanceTime': FieldValue.serverTimestamp(),
      });

      return "success"; // 화면에 초록색 체크마크 띄우기용
    } catch (e) {
      return "error: $e";
    }
  }

  // 📊 대시보드용 실시간 데이터 스트림 (유림이 담당 - 기존 코드 유지)
  Stream<List<AttendanceModel>> getAttendanceStream(String eventId) {
    return _db
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList(),
        );
  }
 
 //신청자 비교 명단(정유림)
  Future<List<Map<String, dynamic>>> getApplicants() async {
  final ref = FirebaseDatabase.instance.ref("attendance"); // 경로 수정
  final snapshot = await ref.get();

  List<Map<String, dynamic>> list = [];

  if (snapshot.exists && snapshot.value != null) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) {
      // key = "김서현_2303030" 형식
      final parts = key.split('_');
      String name = parts.isNotEmpty ? parts[0] : '';
      String studentId = parts.length > 1 ? parts[1] : '';

      list.add({
        'name': name,
        'studentId': studentId,
      });
    });
  }

  print("applicants: $list"); // 디버깅용
  return list;
}
  Future<List<Map<String, dynamic>>> getAttendance() async {
  var snapshot = await FirebaseFirestore.instance
      .collection('attendance')
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}
}
