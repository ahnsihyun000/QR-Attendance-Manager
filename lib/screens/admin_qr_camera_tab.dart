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
  static const _tossBlue = Color(0xFF3182F6);
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // QR 데이터 파싱 및 Firestore 업로드 처리 함수
  Future<void> _handleQrDetection(String qrRawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 데이터 예시 규격이 "학번,이름" 형태이거나 단일 학번 형태일 때를 유연하게 대응합니다.
      String studentId = qrRawValue.trim();
      String userName = "확인된 학생";

      if (qrRawValue.contains(',')) {
        final parts = qrRawValue.split(',');
        studentId = parts[0].trim();
        userName = parts[1].trim();
      }

      if (studentId.isEmpty) {
        throw Exception("유효하지 않은 QR 코드 데이터입니다.");
      }

      // 🎯 [중요] Firestore 실제 문서 형식에 맞춰 3가지 핵심 필드만 생성하여 업로드
      await _firestore.collection('attendance').add({
        'studentId': studentId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(), // 서버 표준 시간 입력
      });

      if (!mounted) return;
      _showResultSnackBar(context, "$userName($studentId) 출석 처리 완료", isSuccess: true);

      // 연속 스캔을 위한 짧은 딜레이 대기
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (!mounted) return;
      _showResultSnackBar(context, "오류가 발생했습니다: ${e.toString()}", isSuccess: false);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showResultSnackBar(BuildContext context, String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? _tossGreen : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
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
          style: TextStyle(color: _tossBlack, fontWeight: FontWeight.bold, fontSize: 18),
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
                style: TextStyle(color: _tossGrey, fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 🎯 에러가 발생하던 파라미터 구문을 패키지 표준 규격에 맞게 안전하게 변경
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
                    )
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
                      // 처리 중일 때 화면을 흐리게 덮어주는 오버레이 효과
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _tossBlack),
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