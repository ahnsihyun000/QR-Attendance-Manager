import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR 코드를 그리기 위한 패키지
import 'login_screen.dart'; 

class QRScannerPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const QRScannerPage({super.key, required this.userData});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  // 토스 스타일 색상 구성
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _cardBorder = Color(0xFFE5E8EB);

  // 🔔 로그아웃 확인 팝업창 함수
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              color: _tossBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            '로그아웃 하시겠습니까?',
            style: TextStyle(
              color: _tossBlack,
              fontSize: 15,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _tossGreyText,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 파이어베이스 데이터 안전 추출
    final name = '${widget.userData['name'] ?? '이름 없음'}'.trim();
    final studentId = '${widget.userData['studentId'] ?? '학번 누락'}'.trim();
    final department = '${widget.userData['department'] ?? '행사 참여자'}'.trim();

    // 행사 이름 정보를 제외하고 오직 관리자 매핑용 학번과 이름만 QR에 주입
    final String qrData = 'UID:$studentId,NAME:$name';

    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''), // 🎯 '나의 입장 QR' 텍스트 완전 제거
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _tossGreyText),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // 앱바 타이틀이 사라진 만큼 상단 여백 최적화
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👤 사용자 정보 카드 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _cardBorder, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      department,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _tossBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name, 
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _tossBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '학번: $studentId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _tossGreyText,
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: _cardBorder, height: 1),
                    ),

                    // 🏁 QR 코드 표시 영역
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _tossBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: QrImageView(
                        data: qrData, 
                        version: QrVersions.auto,
                        size: 200.0,
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
                    
                    const SizedBox(height: 24),
                    const Text(
                      '행사 관리자에게 QR 코드를 보여주세요.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _tossGreyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}