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
  // 스캔 성공 시 테두리 색상을 바꾸기 위한 변수
  Color _overlayColor = Colors.white;

  Future<void> _saveAttendance(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _overlayColor = const Color(0xFF3182F6); // 스캔 중 토스 블루색으로 변경
    });

    try {
      // QR 데이터 파싱 로직 최적화
      final parts = rawValue.split(',');
      if (parts.length < 2) throw Exception('잘못된 QR 형식');

      final uid = parts[0].replaceAll('UID:', '').trim();
      final name = parts[1].replaceAll('NAME:', '').trim();

      await FirebaseFirestore.instance.collection('attendance').add({
        'uid': uid,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showSuccessFeedback(name);
      
      // 2초 대기 후 원래 색상으로 복구 및 다시 스캔 가능 상태로
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      _showErrorFeedback(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _overlayColor = Colors.white;
        });
      }
    }
  }

  void _showSuccessFeedback(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        content: Text('✅ $name 학생 출석 완료', style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        content: Text('❌ 오류: $message'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 앱바 디자인을 이전 화면들과 통일
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('QR 출석 스캔', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isProcessing) return; // 처리 중이면 무시

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue == null) continue;

                // 유효성 검사 로직 간소화
                if (rawValue.contains('UID:') && rawValue.contains('NAME:')) {
                  _saveAttendance(rawValue);
                  break;
                }
              }
            },
          ),
          
          // QR 가이드 UI (중앙 박스)
          _buildScannerOverlay(),

          // 하단 안내 텍스트
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
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: _overlayColor,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: _isProcessing 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : null,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '이 사각형 안에 QR 코드를 맞춰주세요',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInstruction() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: const [
          Text(
            '학생의 QR을 비추면',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            '출석부가 자동으로 업데이트됩니다',
            style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 15),
          ),
        ],
      ),
    );
  }
}