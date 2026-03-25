// --- lib/qr_scan_screen.dart ---
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';// 민수님이 만드신 모델

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? qrCode;
  bool isProcessing = false;

  Future<void> _handleAttendance(String code) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final newRecord = AttendanceModel(
        eventId: "CAPSTONE_2026_01",
        userUid: "test_user_01",
        userName: "TestUser",
        timestamp: DateTime.now(),
        status: "출석",
      );

      await FirebaseFirestore.instance
          .collection('attendance')
          .add(newRecord.toJson());

      debugPrint("Firebase Write Success: $code");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("출석 정보가 서버에 기록되었습니다: $code"),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() => qrCode = code);
    } catch (e) {
      debugPrint("Firebase Write Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("서버 통신 오류가 발생했습니다."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 출석 관리 시스템'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !isProcessing) {
                    _handleAttendance(barcode.rawValue!);
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    qrCode != null ? '최근 인식: $qrCode' : '스캔 대기 중...',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}