import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminQrCameraTab extends StatefulWidget {
  const AdminQrCameraTab({super.key});

  @override
  State<AdminQrCameraTab> createState() => _AdminQrCameraTabState();
}

class _AdminQrCameraTabState extends State<AdminQrCameraTab> {
  final _eventIdController = TextEditingController(text: 'event01');
  bool _isProcessing = false;
  Color _overlayColor = Colors.white;

  @override
  void dispose() {
    _eventIdController.dispose();
    super.dispose();
  }

  // 출석 데이터 저장 로직
  Future<void> _saveAttendance(String rawValue) async {
    if (_isProcessing) return;

    final eventId = _eventIdController.text.trim();
    if (eventId.isEmpty || eventId.contains('/')) {
      _showFeedback(isSuccess: false, message: '올바른 행사 ID를 입력해주세요.');
      return;
    }

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
      if (uid.contains('/')) throw Exception('학번 형식이 올바르지 않습니다.');

      final result = await _markAttendance(
        eventId: eventId,
        studentId: uid,
        name: name,
      );

      if (!mounted) return;

      switch (result) {
        case _AttendanceResult.success:
          setState(() => _overlayColor = const Color(0xFF00AD5C));
          _showFeedback(isSuccess: true, message: '$name 학생 출석 완료!');
          break;
        case _AttendanceResult.notRegistered:
          setState(() => _overlayColor = const Color(0xFFF04452));
          _showFeedback(isSuccess: false, message: '사전 명단에 없는 학생입니다.');
          break;
        case _AttendanceResult.alreadyChecked:
          setState(() => _overlayColor = const Color(0xFFFF9800));
          _showFeedback(isSuccess: false, message: '이미 출석 완료된 학생입니다.');
          break;
      }

      // 3. 결과 표시 후 2초간 대기 (중복 스캔 방지)
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

  Future<_AttendanceResult> _markAttendance({
    required String eventId,
    required String studentId,
    required String name,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final docId = '${eventId}_$studentId';
    final docRef = firestore.collection('attendance').doc(docId);

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        return _AttendanceResult.notRegistered;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      if (data['status'] == '출석 완료') {
        return _AttendanceResult.alreadyChecked;
      }

      transaction.update(docRef, {
        'status': '출석 완료',
        'attendanceTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'checkedAt': FieldValue.serverTimestamp(),
        'eventId': eventId,
        'studentId': studentId,
        'userUid': studentId,
        'uid': studentId,
        'userName': name,
        'name': name,
      });

      return _AttendanceResult.success;
    });
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

          _buildEventIdPanel(),
          
          // 2. 스캔 가이드 Overlay
          _buildScannerOverlay(),

          // 3. 하단 안내 문구
          _buildBottomInstruction(),
        ],
      ),
    );
  }

  Widget _buildEventIdPanel() {
    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _eventIdController,
                enabled: !_isProcessing,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '행사 ID',
                  hintStyle: TextStyle(color: Color(0xFFB0B8C1)),
                ),
              ),
            ),
          ],
        ),
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

enum _AttendanceResult {
  success,
  notRegistered,
  alreadyChecked,
}
