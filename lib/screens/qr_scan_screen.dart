import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanCompleted = false;

  void _onDetect(BarcodeCapture capture) async {
    if (isScanCompleted) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue; // 행사 ID + 타임스탬프 포함
      setState(() => isScanCompleted = true);

      // Firebase Firestore에 출석 기록 (중복 방지 로직 포함)
      await FirebaseFirestore.instance.collection('attendance').add({
        'eventId': code,
        'studentId': '2237027', // 실제는 Auth 유저 정보 활용
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("출석이 완료되었습니다!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR 출석 스캔")),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}