import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_screen.dart';

class QRScannerPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const QRScannerPage({super.key, required this.userData});

  // 스타일 상수
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);
  //static const _tossBg = Color(0xFFF2F4F6);

  @override
  Widget build(BuildContext context) {
    // 로그인 시 넘어온 데이터 파싱
    final String name = userData['name'] ?? "이름 없음";
    final String uid = userData['studentId'] ?? "000000";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "내 QR 학생증",
          style: TextStyle(color: _tossBlack, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: [
          TextButton(
            onPressed: () => _showLogoutDialog(context),
            child: const Text("로그아웃", style: TextStyle(color: _tossGrey, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 학생 이름 및 정보
            Text(
              name,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: _tossBlack,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "학번: $uid",
              style: const TextStyle(
                fontSize: 18,
                color: _tossGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 48),

            // QR 코드 영역 (인식률을 위해 흰 배경 박스로 감싸기)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                // 관리자 스캐너의 데이터 파싱 형식에 맞춤
                data: "UID:$uid, NAME:$name",
                version: QrVersions.auto,
                size: 220.0,
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _tossBlack,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _tossBlack,
                ),
              ),
            ),

            const SizedBox(height: 56),

            // 안내 문구
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _tossBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: _tossBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "출석 리더기에 QR을 스캔하세요",
                    style: TextStyle(
                      color: _tossBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: _tossGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("확인", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}