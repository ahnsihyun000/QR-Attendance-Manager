import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerPage extends StatelessWidget {
  // 로그인 시 넘겨받은 유저 데이터를 저장할 변수
  final Map<String, dynamic> userData;

  // 생성자에서 'userData'를 필수로 받도록 설정
  const QRScannerPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 QR 학생증"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(userData['department'] ?? "학과 정보 없음", style: const TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 5),
            Text(userData['name'] ?? "이름 없음", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            Text("학번: ${userData['studentId']}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
            // QR 코드 생성
            QrImageView(
              data: "ID:${userData['studentId']}, NAME:${userData['name']}",
              version: QrVersions.auto,
              size: 260.0,
            ),
            const SizedBox(height: 40),
            const Text("출석 리더기에 QR을 스캔하세요"),
          ],
        ),
      ),
    );
  }
}