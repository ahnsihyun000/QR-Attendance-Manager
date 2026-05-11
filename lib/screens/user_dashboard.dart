import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // [수정] 스캐너 대신 QR 생성 패키지 임포트

// [학생용 고유 QR 대시보드]
class UserDashboard extends StatelessWidget {
  final String name;      // 로그인/정보입력에서 넘어온 이름
  final String studentId; // 로그인/정보입력에서 넘어온 학번

  const UserDashboard({
    super.key,
    required this.name,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    // QR 코드에 저장될 고유 데이터 조합
    final String qrData = "STUDENT_NAME:$name|STUDENT_ID:$studentId";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("나의 출석 QR"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. 학생 정보 표시 영역
            Text(
              "$name 님",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "학번: $studentId",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),

            // 2. [중요] QR 코드 생성 영역 (기존 MobileScanner 코드를 대체함)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,            // 이름과 학번이 담긴 데이터
                version: QrVersions.auto,
                size: 250.0,             // QR 코드 크기
              ),
            ),

            const SizedBox(height: 50),
            // 3. 안내 문구
            const Text(
              "출석 리더기에 QR 코드를 보여주세요.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // 정보가 틀렸을 경우 돌아가는 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("정보 수정하기"),
            ),
          ],
        ),
      ),
    );
  }
}