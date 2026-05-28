import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/qr_manager.dart';
import 'login_screen.dart';

class QRScannerPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const QRScannerPage({super.key, required this.userData});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreyText = Color(0xFF8B95A1);
  static const _tossBg = Color(0xFFF2F4F6);
  static const _tossBlack = Color(0xFF191F28);
  static const _cardBorder = Color(0xFFE5E8EB);

  late String _qrData;
  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _refreshQR();
    // 남은 시간을 1초마다 줄이고, 만료되면 새 QR을 생성합니다.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
          } else {
            _refreshQR();
          }
        });
      }
    });
  }

  void _refreshQR() {
    final studentId = '${widget.userData['studentId'] ?? ''}'.trim();
    final name = '${widget.userData['name'] ?? ''}'.trim();
    setState(() {
      _qrData = DynamicQRManager.generate(studentId, name);
      _secondsLeft = 30;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            style: TextStyle(color: _tossBlack, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _tossGreyText,
                  fontWeight: FontWeight.w600,
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
    final name = '${widget.userData['name'] ?? '이름 없음'}'.trim();
    final studentId = '${widget.userData['studentId'] ?? '학번 누락'}'.trim();
    final department = '${widget.userData['department'] ?? '행사 참여자'}'.trim();

    return Scaffold(
      backgroundColor: _tossBg,
      appBar: AppBar(
        backgroundColor: _tossBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _tossGreyText),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _tossBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 200.0,
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '남은 시간: $_secondsLeft초',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '관리자에게 QR 코드를 보여주세요.',
                      style: TextStyle(fontSize: 14, color: _tossGreyText),
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
