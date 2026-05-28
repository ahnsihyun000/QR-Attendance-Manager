import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 사전 명단 존재 여부와 중복 출석 여부를 확인한 뒤 출석 상태를 갱신합니다.
  Future<String> recordAttendance(AttendanceModel attendance) async {
    try {
      String customDocId = "${attendance.eventId}_${attendance.userUid}";

      DocumentReference docRef = _db.collection('Attendance').doc(customDocId);
      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        return "not_registered";
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['status'] == '출석 완료') {
        return "already_checked";
      }

      await docRef.update({
        'status': '출석 완료',
        'attendanceTime': FieldValue.serverTimestamp(),
      });

      return "success";
    } catch (e) {
      return "error: $e";
    }
  }

  // 행사별 출석 데이터를 실시간 스트림으로 가져옵니다.
  Stream<List<AttendanceModel>> getAttendanceStream(String eventId) {
    return _db
        .collection('Attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList(),
        );
  }
}
