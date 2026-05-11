import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_screen.dart';

class QRScannerPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const QRScannerPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final String name = userData['name'] ?? "이름 없음";
    final String uid = userData['studentId'] ?? "000000";

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 QR 학생증"),
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: [
          // [수정] 관리자 버튼 삭제하고 로그아웃 버튼만 깔끔하게 남김!
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // 쌓인 화면 모두 지우고 로그인 창으로
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "학번: $uid",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // 본인 정보가 담긴 고유 QR
            QrImageView(
              data: "UID:$uid, NAME:$name",
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 50),
            const Text(
              "출석 리더기에 QR을 스캔하세요",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
