import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/qr_manager.dart'; // 🎯 경로 확인하세요!

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
  static const _tossGreen = Color(0xFF00AD5C);
  static const _tossBlack = Color(0xFF191F28);
  static const _tossGrey = Color(0xFF8B95A1);

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // 🎯 동적 QR 데이터 검증 및 처리 로직
  Future<void> _handleQrDetection(String qrRawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1️⃣ DynamicQRManager를 통한 검증 실행
      final result = DynamicQRManager.verify(qrRawValue);

      if (!result['success']) {
        _showResultSnackBar(
          context,
          result['message'] ?? "유효하지 않은 QR입니다.",
          isSuccess: false,
        );
        await Future.delayed(const Duration(seconds: 2));
        return;
      }

      final studentId = result['studentId'];
      final userName = result['userName'];

      // 2️⃣ 오늘 날짜 기반 중복 체크 로직 (기존과 동일)
      final now = DateTime.now();
      final todayStr =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final docId = "${studentId}_${userName}_$todayStr";

      final docRef = _firestore.collection('attendance').doc(docId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        _showResultSnackBar(
          context,
          "$userName ($studentId)\n이미 출석 완료된 학생입니다.",
          isSuccess: false,
        );
        await Future.delayed(const Duration(seconds: 2));
        return;
      }

      // 3️⃣ 출석 데이터 업로드
      await docRef.set({
        'studentId': studentId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showResultSnackBar(
        context,
        "$userName ($studentId)\n출석 처리가 완료되었습니다.",
        isSuccess: true,
      );
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      _showResultSnackBar(context, "오류 발생: ${e.toString()}", isSuccess: false);
    } finally {
      if (mounted)
        setState(() {
          _isProcessing = false;
        });
    }
  }

  void _showResultSnackBar(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
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
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? _tossGreen : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
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
                "학생들의 동적 QR 코드를 스캔해 주세요.\n(30초마다 자동 갱신됩니다)",
                style: TextStyle(color: _tossGrey, fontSize: 14),
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
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
                          final barcode = capture.barcodes.first;
                          if (barcode.rawValue != null)
                            _handleQrDetection(barcode.rawValue!);
                        },
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
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
            "💡 동적 QR 스캔 가이드",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _tossBlack,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "• 30초가 지난 과거의 QR 코드는 자동으로 무효 처리됩니다.",
            style: TextStyle(fontSize: 13, color: _tossGrey, height: 1.5),
          ),
          Text(
            "• 위조되거나 변조된 QR 코드는 빨간색 알림창과 함께 차단됩니다.",
            style: TextStyle(fontSize: 13, color: _tossGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
