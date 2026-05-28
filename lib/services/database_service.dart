import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

/// Firestore 출석 데이터 처리를 모아둔 서비스 클래스입니다.
///
/// 현재 주요 화면에서는 attendance 컬렉션을 직접 사용하는 부분도 있지만,
/// 이 클래스는 모델 기반 출석 처리 로직을 분리해 재사용할 수 있도록 남겨둔 구조입니다.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 사전 명단 존재 여부와 중복 출석 여부를 확인한 뒤 출석 상태를 갱신합니다.
  Future<String> recordAttendance(AttendanceModel attendance) async {
    try {
      // 행사 ID와 사용자 ID를 조합해 한 사람의 출석 문서를 고유하게 식별합니다.
      String customDocId = "${attendance.eventId}_${attendance.userUid}";

      // 사전 등록된 출석 대상자인지 Attendance 컬렉션에서 먼저 확인합니다.
      DocumentReference docRef = _db.collection('Attendance').doc(customDocId);
      DocumentSnapshot doc = await docRef.get();

      // 문서가 없으면 사전 신청 명단에 없는 사용자로 판단합니다.
      if (!doc.exists) {
        return "not_registered";
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 이미 출석 완료 상태라면 중복 스캔으로 처리합니다.
      if (data['status'] == '출석 완료') {
        return "already_checked";
      }

      // 기존 문서의 상태만 갱신하고, 출석 시간은 Firestore 서버 시간을 사용합니다.
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
    // eventId가 같은 출석 문서만 가져와 AttendanceModel 목록으로 변환합니다.
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
