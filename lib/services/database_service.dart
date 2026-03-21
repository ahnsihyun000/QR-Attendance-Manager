import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 출석 기록 및 중복 방지 로직 (김민겸 부팀장 담당 영역) [cite: 5]
  Future<String> recordAttendance(AttendanceModel attendance) async {
    try {
      // 1. 고유 문서 ID 생성: '행사ID_사용자ID' 조합 
      // 이렇게 하면 한 사람이 같은 행사에 여러 번 스캔해도 DB에는 하나만 남습니다.
      String customDocId = "${attendance.eventId}_${attendance.userUid}";
      
      // 2. 이미 출석했는지 문서 존재 여부 확인 
      DocumentSnapshot doc = await _db.collection('Attendance').doc(customDocId).get();
      
      if (doc.exists) {
        return "already_checked"; // 이미 출석 완료된 경우
      }

      // 3. 신규 출석 데이터 저장 
      await _db.collection('Attendance').doc(customDocId).set(attendance.toJson());
      return "success";
      
    } catch (e) {
      return "error: $e";
    }
  }
  Stream<List<AttendanceModel>> getAttendanceStream(String eventId) {
    return _db
        .collection('Attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }
}