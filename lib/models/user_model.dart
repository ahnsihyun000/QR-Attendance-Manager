class UserModel {
  final String uid;
  final String studentId;
  final String name;
  final String role;
  final String lastCheckIn;

  UserModel({
    required this.uid,
    required this.studentId,
    required this.name,
    required this.role,
    this.lastCheckIn = "",
  });

  // 앱에서 쓰는 사용자 객체를 Firestore 저장용 Map으로 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'studentId': studentId,
      'name': name,
      'role': role,
      'lastCheckIn': lastCheckIn,
    };
  }

  // Firestore에서 읽은 Map 데이터를 사용자 객체로 변환합니다.
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
