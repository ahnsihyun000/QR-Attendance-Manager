import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

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
  // 학번(studentId)으로 사용자 정보 가져오기 함수 추가
  Future<UserModel?> getUserData(String studentId) async {
    try {
      // 'users' 컬렉션에서 문서 ID가 스캔한 학번인 것을 찾습니다.
      DocumentSnapshot doc = await _db.collection('users').doc(studentId).get();

      if (doc.exists) {
        // 데이터가 있으면 UserModel 객체로 변환
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("사용자를 찾을 수 없습니다.");
        return null;
      }
    } catch (e) {
      print("사용자 조회 에러: $e");
      return null;
    }
  }
}