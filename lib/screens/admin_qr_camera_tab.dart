import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminQrCameraTab extends StatefulWidget {
  const AdminQrCameraTab({super.key});

  @override
  State<AdminQrCameraTab> createState() => _AdminQrCameraTabState();
}

class _AdminQrCameraTabState extends State<AdminQrCameraTab> {
  bool _isProcessing = false;
  Color _overlayColor = Colors.white;

  // 출석 데이터 저장 로직
  Future<void> _saveAttendance(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _overlayColor = const Color(0xFF3182F6); // 토스 블루색으로 피드백
    });

    try {
      // 1. QR 데이터 파싱 (형식: UID:12345,NAME:홍길동)
      final parts = rawValue.split(',');
      if (parts.length < 2) throw Exception('유효하지 않은 QR 형식입니다.');

      final uid = parts[0].replaceAll('UID:', '').trim();
      final name = parts[1].replaceAll('NAME:', '').trim();

      if (uid.isEmpty || name.isEmpty) throw Exception('데이터가 비어있습니다.');

      // 2. 파이어스토어 저장
      await FirebaseFirestore.instance.collection('attendance').add({
        'uid': uid,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showFeedback(isSuccess: true, message: '$name 학생 출석 완료!');

      // 3. 성공 시 2초간 대기 (중복 스캔 방지)
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      if (!mounted) return;
      _showFeedback(isSuccess: false, message: '오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _overlayColor = Colors.white; // 다시 원래 색상으로
        });
      }
    }
  }

  // 상단 스낵바 피드백
  void _showFeedback({required bool isSuccess, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('QR 출석 스캔', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. QR 스캐너 본체
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates, // 자체 중복 감지 억제
            ),
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.contains('UID:') && rawValue.contains('NAME:')) {
                  _saveAttendance(rawValue);
                  break;
                }
              }
            },
          ),
          
          // 2. 스캔 가이드 Overlay
          _buildScannerOverlay(),

          // 3. 하단 안내 문구
          _buildBottomInstruction(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: _overlayColor, width: 4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: _isProcessing 
              ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : null,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '사각형 안에 QR 코드를 비춰주세요',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInstruction() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Column(
        children: const [
          Text(
            '학생 QR 스캔 시',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            '출석부가 실시간으로 업데이트됩니다',
            style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 15),
          ),
        ],
      ),
    );
  }
}