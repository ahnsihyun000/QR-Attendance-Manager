class UserModel {
  final String uid; // Firebase Auth에서 생성되는 고유 ID
  final String studentId; // 학번 (예: 20261234)
  final String name; // 이름 (예: 안시현)
  final String role; // 역할 (학생/관리자)
  final String lastCheckIn; // 마지막 출석 시간 (String 형태)

  UserModel({
    required this.uid,
    required this.studentId,
    required this.name,
    required this.role,
    this.lastCheckIn = "",
  });

  // 1. 객체를 파이어베이스(Map)에 저장할 수 있는 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'studentId': studentId,
      'name': name,
      'role': role,
      'lastCheckIn': lastCheckIn,
    };
  }

  // 2. 파이어베이스에서 가져온 데이터를 객체 형태로 변환
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      lastCheckIn: map['lastCheckIn'] ?? '',
    );
  }
}
