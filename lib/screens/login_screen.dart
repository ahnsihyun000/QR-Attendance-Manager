import 'package:flutter/material.dart';
import 'admin_dashboard.dart'; // 관리자 화면 임포트
import 'qr_scan_screen.dart';   // QR 스캐너 화면 임포트

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경색: 연한 그레이 블루
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. 중앙 메인 콘텐츠 ---
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🏫 학교 로고 섹션 (흰 원형 배경 + 그림자)
                    SizedBox(
                      width: 150, // 요청하신 사이즈 최적화
                      height: 150,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/school_logo.png',
                          fit: BoxFit.cover,
                          // 이미지가 없을 경우 표시될 아이콘
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.school, size: 50, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 학교 이름 및 타이틀
                    const Text(
                      "배재대학교",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height:15),

                    // 인사
                    const Text(
                      "출석 확인을 위해\n아래 버튼을 눌러 스캔을 시작하세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.3),
                    ),
                    const SizedBox(height: 25),

                    // 🔍 메인 액션 버튼 (출석 스캔 시작하기)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QRScannerPage()),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 24),
                        label: const Text(
                          "출석 스캔 시작하기",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. 우측 하단 관리자 설정 버튼 (톱니바퀴) ---
            Positioned(
              right: 16,
              bottom: 16,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                  );
                },
                icon: const Icon(Icons.settings),
                iconSize: 28,
                color: Colors.grey.shade400, // 은은한 회색
                tooltip: "관리자 설정",
              ),
            ),
          ],
        ),
      ),
    );
  }
}