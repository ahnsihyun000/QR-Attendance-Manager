import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminQrCameraTab extends StatefulWidget {
  const AdminQrCameraTab({super.key});

  @override
  State<AdminQrCameraTab> createState() => _AdminQrCameraTabState();
}

class _AdminQrCameraTabState extends State<AdminQrCameraTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  // 토스 스타일 상수 정의
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // QR 데이터 파싱 및 Firestore 업로드 처리 함수
  // QR 데이터 파싱 및 Firestore 업로드 처리 함수
  Future<void> _handleQrDetection(String qrRawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      String studentId = qrRawValue.trim();
      String userName = "확인된 학생";

      if (qrRawValue.contains(',')) {
        final parts = qrRawValue.split(',');
        studentId = parts[0].trim();
        userName = parts[1].trim();
      }

      // QR 코드 원본 데이터에 포함된 태그 제거
      studentId = studentId.replaceFirst('UID:', '').trim();
      userName = userName.replaceFirst('NAME:', '').trim();

      if (studentId.isEmpty) {
        throw Exception("유효하지 않은 QR 코드 데이터입니다.");
      }

      // 1. 오늘 날짜 구하기 (예: 20260526)
      final now = DateTime.now();
      // 🎯 오늘 날짜 문자열 생성 (예: "20260526")
      final todayStr =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

      // 🎯 고유한 문서 ID 생성 (학번_이름_날짜 조합으로 하루에 딱 한 번만 출석 가능하게 수정)
      final docId = "${studentId}_${userName}_$todayStr";

      // 파이어베이스 존재 여부 확인
      final docRef = _firestore.collection('attendance').doc(docId);
      final docSnapshot = await docRef.get();
      if (!mounted) return;

      // 이미 파일이 존재한다면 = 오늘 이미 출석을 한 학생!
      if (docSnapshot.exists) {
        _showResultSnackBar(
          context,
          "이름: $userName / 학번: $studentId\n이미 출석이 완료된 학생입니다.",
          isSuccess: false, // 빨간색 알림창
        );

        await Future.delayed(const Duration(seconds: 2));
        return;
      }

      // 🎯 4. 중복이 없을 때만 지정한 문서 ID로 파이어베이스 파일(문서) 생성!
      // 원하셨던 대로 딱 핵심 3가지 필드만 깔끔하게 저장됩니다.
      await docRef.set({
        'studentId': studentId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 첫 출석 성공 알림창 (초록색)
      _showResultSnackBar(
        context,
        "이름: $userName / 학번: $studentId\n출석 처리가 완료되었습니다.",
        isSuccess: true,
      );

      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (!mounted) return;
      _showResultSnackBar(
        context,
        "오류가 발생했습니다: ${e.toString()}",
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // 토스 느낌의 둥글고 입체감 있는 플로팅 스낵바 구현
  void _showResultSnackBar(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isSuccess
            ? _tossGreen
            : Colors.redAccent, // 👈 false일 때 투명도 없는 진한 빨간색 적용
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "출석 QR 스캔",
          style: TextStyle(
            color: _tossBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const Text(
                "학생들의 출석 QR 코드를 카메라 중앙에 맞춰주세요.",
                style: TextStyle(
                  color: _tossGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                height: MediaQuery.of(context).size.width * 0.85,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              _handleQrDetection(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildGuideCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "💡 스캔 가이드",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _tossBlack,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "• 인식 완료 시 하단 알림창과 함께 자동으로 실시간 출석 명단에 등록됩니다.",
            style: TextStyle(fontSize: 13, color: _tossGrey, height: 1.5),
          ),
          SizedBox(height: 6),
          Text(
            "• 인식이 잘 안 될 경우 스마트폰 화면의 밝기를 키우거나 카메라 거리를 조절해 주세요.",
            style: TextStyle(fontSize: 13, color: _tossGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
