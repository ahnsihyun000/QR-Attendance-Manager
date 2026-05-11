//정유림 (qr  스캔 페이지)


import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue == null) return;
    //고유 key 생기면 넣는 코드(정유림)
    /*import 'dart:convert';

final data = jsonDecode(rawValue);

if (data['key'] != 'MY_APP_QR') {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('유효하지 않은 QR입니다')),
  );
  return;
}

String uid = data['uid'];*/

    setState(() {
      _isProcessing = true;
    });

    try {
      // ✅ QR 안에는 uid만 들어있다고 가정
      String uid = rawValue;

      // ✅ 현재 시간 생성
      DateTime now = DateTime.now();

      // ✅ Firestore에 출석 기록
      await DatabaseService().recordAttendanceByUid(uid, now);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출석 완료: $uid')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생')),
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 인식 완료')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
